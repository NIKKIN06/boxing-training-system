#!/usr/bin/env python3
"""Check of a red run before TEST-GATE (lab 5, stage 7).

Reads the output of `dart test --reporter json` (JSON lines) and proves that
every test fails for the expected reason:
- `TestFailure` of the contract validator «<operationId>: status 501 is not
  declared» (stub of the T-10 skeleton), or
- `UnimplementedError`.
It also reports load failures («Failed to load»), tests that unexpectedly
pass and failures for any other reason.

Usage (from tests/):
    python3 -I tool/red_check.py ../logs/app/control-red-20261113.jsonl [rows.json]

Exit code: 0 — no load failures and no other reasons; 1 — otherwise.
Passing tests are listed but do not change the exit code (they are reviewed
by a human).
"""

import collections
import json
import re
import sys

PATTERN_501 = re.compile(r"(\w+): status 501 is not declared")


def main(argv):
    if len(argv) not in (2, 3):
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

    load_failures, rows, passing, other = [], [], [], []
    for test_id, test in tests.items():
        name = test["name"]
        suite = suites.get(test["suiteID"], "?")
        result = done.get(test_id)
        if name.startswith("loading "):
            if (result and result["result"] != "success") or errors.get(test_id):
                load_failures.append((suite, [x["error"][:200] for x in errors[test_id]]))
            continue
        if result is None or result.get("hidden"):
            continue
        messages = [x["error"] for x in errors.get(test_id, [])]
        if any("Failed to load" in m for m in messages):
            load_failures.append((suite, name))
        if result["result"] == "success":
            passing.append((suite, name))
            rows.append((suite, name, "success", "-"))
            continue
        reasons = []
        for x in errors.get(test_id, []):
            message = x["error"]
            match = PATTERN_501.search(message)
            if x["isFailure"] and match:
                reasons.append("TestFailure 501 " + match.group(1))
            elif "UnimplementedError" in message:
                reasons.append("UnimplementedError")
            else:
                reasons.append("OTHER: " + message.splitlines()[0][:160])
        if not reasons or any(r.startswith("OTHER") for r in reasons):
            other.append((suite, name, reasons))
        rows.append((suite, name, result["result"], reasons[0] if reasons else "no error"))

    print("suites:", len(suites), "visible tests:", len(rows))
    print("results:", dict(collections.Counter(r[2] for r in rows)))
    classes = collections.Counter(
        "TestFailure 501" if r[3].startswith("TestFailure 501") else r[3] for r in rows
    )
    print("first reason:", dict(classes))
    print("load failures:", load_failures or "none")
    print("passing:", len(passing))
    for suite, name in passing:
        print("  PASS", suite, "|", name)
    print("other reasons:", len(other))
    for suite, name, reasons in other:
        print("  OTHER", suite, "|", name, "|", reasons)
    first_501 = collections.Counter(r[3].split()[-1] for r in rows if r[3].startswith("TestFailure"))
    print("operation that answered 501 first:", dict(sorted(first_501.items())))
    print("tests per suite:")
    for suite, count in sorted(collections.Counter(r[0] for r in rows).items()):
        print(f"  {count:4} {suite}")
    if len(argv) == 3:
        with open(argv[2], "w", encoding="utf-8") as out:
            json.dump(rows, out, ensure_ascii=False, indent=0)
    return 1 if load_failures or other else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
