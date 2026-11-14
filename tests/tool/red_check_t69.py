#!/usr/bin/env python3
"""Check of the red run of T-69 (ADD-003, nameContains) before TEST-GATE.

Reads the output of `dart test --file-reporter json:…` (JSON lines) and
proves that:
- there are no load failures («Failed to load», errors of `loading …`);
- every test outside the T-69 suite passes (the approved tests, 326);
- every test of the T-69 suite either fails for the expected reason — the
  first error is a `TestFailure` of an item assertion with the reason
  «listExercises items (ADD-003)», i.e. the composition of `items` differs
  because the parameter is still ignored — or passes (listed for a human).

Usage (from tests/):
    python3 -I tool/red_check_t69.py ../logs/app/control-red-t69-20261114.jsonl

Exit code: 0 — no load failures, no other reasons and the expected number
of approved tests passes; 1 — otherwise.
"""

import collections
import json
import sys

T69_SUITE = "test/exercises/catalog_name_search_test.dart"
ITEMS_REASON = "listExercises items (ADD-003)"
APPROVED_TESTS = 326


def main(argv):
    if len(argv) != 2:
        print(__doc__)
        return 2
    events = []
    with open(argv[1], encoding="utf-8") as source:
        for line in source:
            if line.strip().startswith("{"):
                events.append(json.loads(line))

    suites = {e["suite"]["id"]: e["suite"]["path"] for e in events if e["type"] == "suite"}
    tests, errors, done = {}, collections.defaultdict(list), {}
    for e in events:
        if e["type"] == "testStart":
            tests[e["test"]["id"]] = e["test"]
        elif e["type"] == "error":
            errors[e["testID"]].append(e)
        elif e["type"] == "testDone":
            done[e["testID"]] = e

    load_failures = []
    approved = collections.Counter()
    approved_failed = []
    new_expected, new_passing, new_other = [], [], []
    for test_id, test in tests.items():
        name = test["name"]
        suite = suites.get(test["suiteID"], "?")
        result = done.get(test_id)
        messages = [x["error"] for x in errors.get(test_id, [])]
        if name.startswith("loading "):
            if (result and result["result"] != "success") or messages:
                load_failures.append((suite, [m[:200] for m in messages]))
            continue
        if result is None or result.get("hidden"):
            continue
        if any("Failed to load" in m for m in messages):
            load_failures.append((suite, name))
        if suite != T69_SUITE:
            approved[result["result"]] += 1
            if result["result"] != "success":
                approved_failed.append((suite, name, [m.splitlines()[0][:160] for m in messages]))
            continue
        if result["result"] == "success":
            new_passing.append(name)
            continue
        first = errors[test_id][0] if errors.get(test_id) else None
        if first and first["isFailure"] and ITEMS_REASON in first["error"]:
            new_expected.append((name, first["error"]))
        else:
            reason = first["error"].splitlines()[0][:200] if first else "no error"
            new_other.append((name, reason))

    print("suites:", len(suites))
    print("load failures:", load_failures or "none")
    print("approved tests (other suites):", dict(approved), "expected", APPROVED_TESTS)
    for suite, name, reason in approved_failed:
        print("  APPROVED-FAILED", suite, "|", name, "|", reason)
    total_new = len(new_expected) + len(new_passing) + len(new_other)
    print("T-69 tests:", total_new)
    print("  failed for the expected reason (items):", len(new_expected))
    for name, message in new_expected:
        actual = next((l.strip() for l in message.splitlines() if l.strip().startswith("Actual:")), "")
        expected = next((l.strip() for l in message.splitlines() if l.strip().startswith("Expected:")), "")
        print("    RED", name)
        print("       ", expected[:150])
        print("       ", actual[:150])
    print("  passed:", len(new_passing))
    for name in new_passing:
        print("    PASS", name)
    print("  other reasons:", len(new_other))
    for name, reason in new_other:
        print("    OTHER", name, "|", reason)

    ok = (
        not load_failures
        and not new_other
        and not approved_failed
        and approved["success"] == APPROVED_TESTS
    )
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
