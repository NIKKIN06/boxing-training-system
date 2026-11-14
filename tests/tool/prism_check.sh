#!/usr/bin/env bash
# Contract check of the real API through the Prism proxy (ЛР-5, крок 3, п. 4).
#
# Calls each of the 27 operations of spec/openapi.yaml at least once through
# the Prism proxy and collects the `sl-violations` response headers (request
# and response violations of the contract found by Prism). Positive calls
# follow docs/api/scenarios.md (POS-xx) with state prepared by earlier calls:
# real ids are taken from the responses with python3. Negative calls
# (NEG-xx) are those that need no state.
#
# Prerequisites (run by a human; the agent does not run this script):
#   1. The API on 127.0.0.1:8080 with a fresh in-memory database and the
#      test catalog, from src/:
#        dart run bin/server.dart --db=:memory: --port=8080
#   2. The Prism proxy on 127.0.0.1:4010, from the repository root:
#        npx -y --registry=https://registry.npmjs.org/ @stoplight/prism-cli@5.16.0 \
#          proxy spec/openapi.yaml http://127.0.0.1:8080 -h 127.0.0.1 -p 4010
#   3. curl and python3.
#
# Usage, from any directory:
#   tests/tool/prism_check.sh
# Environment: PRISM_URL (default http://127.0.0.1:4010).
# Output: logs/app/contract-prism-YYYYMMDD.log (local date), summary on stdout.
# Exit code: 0 — no unexpected violations and every status as expected;
#            1 — otherwise; 2 — Prism is not reachable.
#
# Request bodies contain only `[TEST]` placeholder texts (D-01).

set -u

BASE="${PRISM_URL:-http://127.0.0.1:4010}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LOG="$ROOT/logs/app/contract-prism-$(date +%Y%m%d).log"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# The 27 operationIds of spec/openapi.yaml.
OPERATIONS=(
  listExercises createExercise getExercise updateExercise getDictionary
  generatePlan openSavedPlan getOpenPlan renameOpenPlan addOpenPlanItem
  replaceOpenPlanItem updateOpenPlanItem deleteOpenPlanItem
  listTrainingPlans saveNewTrainingPlan getTrainingPlan overwriteTrainingPlan
  deleteTrainingPlan startCurrentSession getCurrentSession abortCurrentSession
  updateExecutedPlanItem deleteExecutedPlanItem completeTraining
  listCompletedTrainings getCompletedTraining getAnalytics
)

CALLS=0
STATUS_MISMATCHES=0
UNEXPECTED_VIOLATIONS=0
EXPECTED_VIOLATIONS=0
CALLED=" "
LAST_BODY="$WORK/last-body.json"
LAST_HEADERS="$WORK/last-headers.txt"

# json FILE PATH — a value of the JSON in FILE by a dotted path
# (`stages.1.items.0.id`); prints nothing when absent.
json() {
  python3 -I - "$1" "$2" <<'PY'
import json, sys
try:
    value = json.load(open(sys.argv[1], encoding="utf-8"))
    for key in sys.argv[2].split("."):
        value = value[int(key)] if isinstance(value, list) else value[key]
    print(value if not isinstance(value, (dict, list)) else json.dumps(value))
except Exception:
    pass
PY
}

# location — the last path segment of the `Location` header of the last call.
location_id() {
  tr -d '\r' <"$LAST_HEADERS" | awk 'tolower($1) == "location:" {print $2}' |
    sed 's#.*/##'
}

# call ID OPERATION_ID EXPECTED_STATUS VIOLATION METHOD PATH [BODY]
# VIOLATION: "none" — no violation expected; "request" — the request breaks
# the schema on purpose (NEG-32, NEG-33), a request violation is expected.
call() {
  local id="$1" op="$2" expected="$3" violation="$4" method="$5" path="$6"
  local body="${7-}"
  local args=(-s -o "$LAST_BODY" -D "$LAST_HEADERS" -w '%{http_code}' -X "$method")
  if [ -n "$body" ]; then
    args+=(-H 'Content-Type: application/json' --data-binary "$body")
  fi
  local status
  status="$(curl "${args[@]}" "$BASE$path")"
  CALLS=$((CALLS + 1))
  CALLED="$CALLED$op "
  local violations
  violations="$(tr -d '\r' <"$LAST_HEADERS" |
    awk 'tolower($1) == "sl-violations:" {sub(/^[^:]*: */, ""); print}')"
  local note=""
  if [ "$status" != "$expected" ]; then
    STATUS_MISMATCHES=$((STATUS_MISMATCHES + 1))
    note=" STATUS-MISMATCH(expected $expected)"
  fi
  if [ -n "$violations" ]; then
    if [ "$violation" = "request" ]; then
      EXPECTED_VIOLATIONS=$((EXPECTED_VIOLATIONS + 1))
      note="$note EXPECTED-VIOLATION"
    else
      UNEXPECTED_VIOLATIONS=$((UNEXPECTED_VIOLATIONS + 1))
      note="$note UNEXPECTED-VIOLATION"
    fi
  elif [ "$violation" = "request" ]; then
    note="$note NO-VIOLATION-REPORTED"
  fi
  {
    printf '[%02d] %-7s %-23s %-6s %s -> %s%s\n' \
      "$CALLS" "$id" "$op" "$method" "$path" "$status" "$note"
    printf '     sl-violations: %s\n' "${violations:-none}"
    # Only the error code of the body (no field contents, REQ-NF-004).
    local code
    code="$(json "$LAST_BODY" code)"
    [ -n "$code" ] && printf '     code: %s\n' "$code"
  } >>"$LOG"
  printf '%-7s %-23s %s%s\n' "$id" "$op" "$status" "$note"
}

if ! curl -s -o /dev/null "$BASE/training-plans"; then
  echo "Prism proxy is not reachable at $BASE" >&2
  exit 2
fi

mkdir -p "$(dirname "$LOG")"
{
  echo "# Prism proxy contract check — $(date '+%d.%m.%Y %H:%M:%S')"
  echo "# Script: tests/tool/prism_check.sh; proxy: $BASE; spec: spec/openapi.yaml"
  echo "# Upstream: the API with --db=:memory: and the test catalog (fresh start)"
} >"$LOG"

TODAY="$(python3 -I -c 'import datetime; print(datetime.date.today())')"
FROM30="$(python3 -I -c 'import datetime; print(datetime.date.today() - datetime.timedelta(days=29))')"

EXERCISE_BODY='{"name":"[TEST] Стрибки на скакалці","description":"[TEST] Опис стрибків на скакалці.","type":"simple","allowedStages":["warm-up"],"allowedLevels":["level-beginner"],"allowedIntensities":["intensity-high"],"emphases":["emphasis-endurance"],"loadCharacter":"general-physical","variants":[{"executionMeans":"means-apparatus","equipment":["equipment-rope"],"mode":"time","rounds":{"min":1,"max":5,"recommended":3},"intervalSeconds":{"min":60,"max":180,"recommended":120},"restSeconds":{"min":30,"max":90,"recommended":60}}]}'
GENERATION_BODY='{"targetDuration":{"hours":1,"minutes":30},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'

# --- Negative scenarios without state (before any session exists) ---------
call NEG-24 getCurrentSession 404 none GET /current-session
call NEG-31 abortCurrentSession 404 none DELETE /current-session
call NEG-25 completeTraining 409 none POST /completed-trainings '{}'
call NEG-30 deleteExecutedPlanItem 404 none DELETE /current-session/executed-plan/items/item-404
call NEG-02 getExercise 404 none GET /exercises/ex-404
call NEG-05 listExercises 422 none GET '/exercises?level=level-unknown'
call NEG-06 updateExercise 403 none PUT /exercises/ex-1 "$EXERCISE_BODY"
call NEG-04 generatePlan 422 none POST /plan-generations \
  '{"targetDuration":{"hours":0,"minutes":0},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
call NEG-32 generatePlan 422 request POST /plan-generations \
  '{"targetDuration":{"hours":-1,"minutes":30},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
call NEG-33 generatePlan 422 request POST /plan-generations \
  '{"targetDuration":{"hours":1,"minutes":30},"emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
call NEG-13 openSavedPlan 422 none POST /open-plans '{"sourcePlanId":"plan-404"}'
call NEG-20 saveNewTrainingPlan 422 none POST /training-plans '{"openPlanId":"open-404"}'
call NEG-27 getAnalytics 422 none GET '/analytics?from=2026-06-30&to=2026-06-01'
call NEG-28 getAnalytics 422 none GET '/analytics?from=2026-06-01'
call NEG-29 getAnalytics 422 none GET '/analytics?from=2026-06-01&to=2099-01-01'

# --- Catalog (POS-01…POS-08) -------------------------------------------------
call POS-01 listExercises 200 none GET '/exercises?stage=warm-up&level=level-beginner'
call POS-03 createExercise 201 none POST /exercises "$EXERCISE_BODY"
EX_ID="$(json "$LAST_BODY" id)"
VAR_ID="$(json "$LAST_BODY" variants.0.id)"
call POS-04 getExercise 200 none GET /exercises/ex-1
call POS-05 getExercise 200 none GET "/exercises/$EX_ID"
UPDATE_BODY="$(python3 -I - "$EXERCISE_BODY" "$VAR_ID" <<'PY'
import json, sys
body = json.loads(sys.argv[1])
body["description"] = "[TEST] Оновлений опис стрибків на скакалці."
body["variants"][0]["id"] = sys.argv[2]
body.update(videoUrl=None, videoAuthorName=None, authorPageUrl=None)
print(json.dumps(body, ensure_ascii=False))
PY
)"
call POS-07 updateExercise 200 none PUT "/exercises/$EX_ID" "$UPDATE_BODY"
call POS-08 getDictionary 200 none GET /dictionaries/training-levels

# --- ADD-003: search by a part of the name, nameContains (POS-37…42, NEG-35) -
# Values are URL-encoded: удар, УДАР, «  удар  », аперкот, «   » (ordinary
# spaces, Q-ADD3-03). Prism proxy checks the schema of real responses only;
# the composition of items is checked by dart test (scenarios.md, «ADD-003»).
call POS-37 listExercises 200 none GET '/exercises?nameContains=%D1%83%D0%B4%D0%B0%D1%80'
call POS-38 listExercises 200 none GET '/exercises?nameContains=%D0%A3%D0%94%D0%90%D0%A0'
call POS-39 listExercises 200 none GET '/exercises?nameContains=%20%20%D1%83%D0%B4%D0%B0%D1%80%20%20'
call POS-40 listExercises 200 none GET '/exercises?nameContains=%D1%83%D0%B4%D0%B0%D1%80&type=combination'
call POS-41 listExercises 200 none GET '/exercises?nameContains=%D0%B0%D0%BF%D0%B5%D1%80%D0%BA%D0%BE%D1%82'
call POS-42 listExercises 200 none GET '/exercises?nameContains=%20%20%20'
call NEG-35 listExercises 422 none GET '/exercises?nameContains=%D1%83%D0%B4%D0%B0%D1%80&level=level-unknown'

# --- Generation and the open plan (POS-09, POS-11, POS-13…POS-18) ----------
call POS-09 generatePlan 201 none POST /plan-generations "$GENERATION_BODY"
OPEN1="$(json "$LAST_BODY" id)"
call POS-11 getOpenPlan 200 none GET "/open-plans/$OPEN1"
call POS-13 renameOpenPlan 200 none PATCH "/open-plans/$OPEN1" '{"name":"[TEST] Ранкове тренування"}'
call POS-14 addOpenPlanItem 201 none POST "/open-plans/$OPEN1/items" \
  "{\"exerciseId\":\"$EX_ID\",\"variantId\":\"$VAR_ID\",\"stage\":\"cool-down\",\"parameters\":{\"rounds\":1,\"intervalSeconds\":120,\"restSeconds\":30}}"
NEW_ITEM="$(location_id)"
call POS-15 replaceOpenPlanItem 200 none PUT "/open-plans/$OPEN1/items/$NEW_ITEM" \
  "{\"exerciseId\":\"$EX_ID\",\"variantId\":\"$VAR_ID\",\"parameters\":{\"rounds\":2,\"intervalSeconds\":120,\"restSeconds\":60}}"
call POS-16 updateOpenPlanItem 200 none PATCH "/open-plans/$OPEN1/items/$NEW_ITEM" '{"parameters":{"rounds":3}}'
call POS-17 updateOpenPlanItem 200 none PATCH "/open-plans/$OPEN1/items/$NEW_ITEM" '{"stage":"warm-up","position":0}'
call POS-18 deleteOpenPlanItem 200 none DELETE "/open-plans/$OPEN1/items/$NEW_ITEM"

# --- Saved plans (POS-19…POS-23, POS-10, POS-12) ----------------------------
call POS-20 listTrainingPlans 200 none GET /training-plans
call POS-21 saveNewTrainingPlan 201 none POST /training-plans "{\"openPlanId\":\"$OPEN1\"}"
PLAN1="$(json "$LAST_BODY" id)"
call POS-19 listTrainingPlans 200 none GET /training-plans
call POS-22 getTrainingPlan 200 none GET "/training-plans/$PLAN1"
call POS-10 openSavedPlan 201 none POST /open-plans "{\"sourcePlanId\":\"$PLAN1\"}"
OPEN2="$(json "$LAST_BODY" id)"
call POS-12 getOpenPlan 200 none GET "/open-plans/$OPEN2"
call POS-23 overwriteTrainingPlan 200 none PUT "/training-plans/$PLAN1" "{\"openPlanId\":\"$OPEN2\"}"

# --- Current session and completion (POS-25…POS-28, POS-30) -----------------
call POS-25 startCurrentSession 201 none POST /current-session "{\"openPlanId\":\"$OPEN2\"}"
MAIN_ITEM="$(json "$LAST_BODY" executedPlan.stages.1.items.0.id)"
WARM_ITEM="$(json "$LAST_BODY" executedPlan.stages.0.items.0.id)"
# Actual value of the main item: one more round or set than recommended,
# in the field of the item's mode (D-19).
EXEC_BODY="$(python3 -I - "$LAST_BODY" <<'PY'
import json, sys
item = json.load(open(sys.argv[1], encoding="utf-8"))["executedPlan"]["stages"][1]["items"][0]
p = item["parameters"]
key = "rounds" if "rounds" in p else "sets"
print(json.dumps({"parameters": {key: p[key] + 1}}))
PY
)"
call POS-26 getCurrentSession 200 none GET /current-session
call POS-27 updateExecutedPlanItem 200 none PATCH "/current-session/executed-plan/items/$MAIN_ITEM" "$EXEC_BODY"
call POS-28 deleteExecutedPlanItem 200 none DELETE "/current-session/executed-plan/items/$WARM_ITEM"
call POS-30 completeTraining 201 none POST /completed-trainings '{"note":"[TEST] Зроблено додаткові підходи віджимань."}'
TRAINING1="$(json "$LAST_BODY" id)"

# --- History and analytics (POS-32, POS-34, POS-35) --------------------------
call POS-32 listCompletedTrainings 200 none GET /completed-trainings
call POS-34 getCompletedTraining 200 none GET "/completed-trainings/$TRAINING1"
call POS-35 getAnalytics 200 none GET "/analytics?from=$FROM30&to=$TODAY"
call POS-35 getAnalytics 200 none GET /analytics

# --- Abort and deletion (POS-29, POS-24) ------------------------------------
call POS-25 startCurrentSession 201 none POST /current-session "{\"openPlanId\":\"$OPEN2\"}"
call POS-29 abortCurrentSession 204 none DELETE /current-session
call POS-24 deleteTrainingPlan 204 none DELETE "/training-plans/$PLAN1"

# --- Summary -----------------------------------------------------------------
MISSING=()
for op in "${OPERATIONS[@]}"; do
  case "$CALLED" in
    *" $op "*) ;;
    *) MISSING+=("$op") ;;
  esac
done
COVERED=$(( ${#OPERATIONS[@]} - ${#MISSING[@]} ))
{
  echo
  echo "# Summary"
  echo "calls: $CALLS"
  echo "operations covered: $COVERED of ${#OPERATIONS[@]}"
  echo "operations not called: ${MISSING[*]:-none}"
  echo "status mismatches: $STATUS_MISMATCHES"
  echo "expected request violations (NEG-32, NEG-33): $EXPECTED_VIOLATIONS"
  echo "unexpected violations: $UNEXPECTED_VIOLATIONS"
} | tee -a "$LOG"
echo "log: $LOG"

if [ "$STATUS_MISMATCHES" -eq 0 ] && [ "$UNEXPECTED_VIOLATIONS" -eq 0 ] &&
  [ "${#MISSING[@]}" -eq 0 ]; then
  exit 0
fi
exit 1
