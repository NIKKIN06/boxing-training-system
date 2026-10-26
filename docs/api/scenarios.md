# Сценарії перевірки контракту через mock API (ЛР-4, кроки 11–12)

| Поле | Значення |
|---|---|
| Статус | **Чернетка** (не затверджено людиною; сценарії виконано проти mock 26.10.2026 — розділ 5) |
| Дата | 26.10.2026 |
| Підготував | Кодинговий агент (Claude Code, модель `claude-opus-5-5`) |
| Джерела | `spec/openapi.yaml` (операції, `x-req-ids`, `x-trace`, назви прикладів відповідей); `docs/api/resource-model.md` |

## 1. Mock API

| Поле | Значення |
|---|---|
| Інструмент | Stoplight Prism CLI 5.16.0 (`@stoplight/prism-cli@5`; версію повідомив власник, у стартовому виводі її немає) |
| Специфікація | `spec/openapi.yaml` |
| Адреса | `http://127.0.0.1:4010` (єдиний `servers` у специфікації, ADD-002 D-28) |
| Хто запускав | Власник репозиторію, у власному терміналі |

Команда запуску:

```
npx -y --registry=https://registry.npmjs.org/ @stoplight/prism-cli@5 mock spec/openapi.yaml -h 127.0.0.1 -p 4010
```

Стартовий вивід:

```
[1:52:41 PM] › [CLI] …  awaiting  Starting Prism…
[1:52:41 PM] › [CLI] ℹ  info      GET        http://127.0.0.1:4010/exercises
[1:52:41 PM] › [CLI] ℹ  info      POST       http://127.0.0.1:4010/exercises
[1:52:41 PM] › [CLI] ℹ  info      GET        http://127.0.0.1:4010/exercises/ex-1
[1:52:41 PM] › [CLI] ℹ  info      PUT        http://127.0.0.1:4010/exercises/ex-1
[1:52:41 PM] › [CLI] ℹ  info      GET        http://127.0.0.1:4010/dictionaries/equipment
[1:52:41 PM] › [CLI] ℹ  info      POST       http://127.0.0.1:4010/plan-generations
[1:52:41 PM] › [CLI] ℹ  info      POST       http://127.0.0.1:4010/open-plans
[1:52:41 PM] › [CLI] ℹ  info      GET        http://127.0.0.1:4010/open-plans/open-1
[1:52:41 PM] › [CLI] ℹ  info      PATCH      http://127.0.0.1:4010/open-plans/open-1
[1:52:41 PM] › [CLI] ℹ  info      POST       http://127.0.0.1:4010/open-plans/open-1/items
[1:52:41 PM] › [CLI] ℹ  info      PUT        http://127.0.0.1:4010/open-plans/open-1/items/item-3
[1:52:41 PM] › [CLI] ℹ  info      PATCH      http://127.0.0.1:4010/open-plans/open-1/items/item-3
[1:52:41 PM] › [CLI] ℹ  info      DELETE     http://127.0.0.1:4010/open-plans/open-1/items/item-3
[1:52:41 PM] › [CLI] ℹ  info      GET        http://127.0.0.1:4010/training-plans
[1:52:41 PM] › [CLI] ℹ  info      POST       http://127.0.0.1:4010/training-plans
[1:52:41 PM] › [CLI] ℹ  info      GET        http://127.0.0.1:4010/training-plans/plan-1
[1:52:41 PM] › [CLI] ℹ  info      PUT        http://127.0.0.1:4010/training-plans/plan-1
[1:52:41 PM] › [CLI] ℹ  info      DELETE     http://127.0.0.1:4010/training-plans/plan-1
[1:52:41 PM] › [CLI] ℹ  info      POST       http://127.0.0.1:4010/current-session
[1:52:41 PM] › [CLI] ℹ  info      GET        http://127.0.0.1:4010/current-session
[1:52:41 PM] › [CLI] ℹ  info      DELETE     http://127.0.0.1:4010/current-session
[1:52:41 PM] › [CLI] ℹ  info      PATCH      http://127.0.0.1:4010/current-session/executed-plan/items/item-3
[1:52:41 PM] › [CLI] ℹ  info      DELETE     http://127.0.0.1:4010/current-session/executed-plan/items/item-3
[1:52:41 PM] › [CLI] ℹ  info      POST       http://127.0.0.1:4010/completed-trainings
[1:52:41 PM] › [CLI] ℹ  info      GET        http://127.0.0.1:4010/completed-trainings
[1:52:41 PM] › [CLI] ℹ  info      GET        http://127.0.0.1:4010/completed-trainings/training-1
[1:52:41 PM] › [CLI] ℹ  info      GET        http://127.0.0.1:4010/analytics
[1:52:41 PM] › [CLI] ▶  start     Prism is listening on http://127.0.0.1:4010
```

Стартовий вивід містить 27 маршрутів — по одному на кожну операцію специфікації.

### Обмеження mock

- **Стану між запитами немає.** Prism не зберігає дані: створення, зміна чи видалення не впливають на наступні запити. Тому сценарії перевіряють відповідність окремої відповіді контракту, а не послідовність дій (наприклад, «завершити → повторно завершити»).
- **Відповіді беруться з прикладів специфікації.** Prism не виконує логіку системи: не формує план, не рахує тривалість, не перевіряє правила предметної області. Очікуваний результат у сценаріях — поля відповідного іменованого прикладу з `spec/openapi.yaml`.
- **Вибір відповіді — заголовок `Prefer`.** `Prefer: code=<статус>` вибирає відповідь із цим кодом стану; `example=<назва>` вибирає іменований приклад (назва — ключ у `examples` відповіді). Без `Prefer` Prism повертає першу успішну відповідь і перший приклад.
- **Перевірка запиту відбувається до вибору відповіді.** Якщо запит порушує схему, Prism відхиляє його незалежно від `Prefer`. Тому в усіх сценаріях із `Prefer` запит відповідає схемі, а негативні сценарії з порушенням схеми (розділ 3.2) надсилаються без `Prefer`.
- **Тексти помилок** у відповідях відсутні за контрактом (REQ-NF-005): перевіряються лише статус і `code`.
- **Тіло відповіді на невалідний запит не описує фактичного порушення** (виявлено на кроці 13, NEG-32…34). Prism 5.16.0 повертає `422` з першим іменованим прикладом відповіді `422` цієї операції, тобто тіло формату `Error` зі специфікації. Фактичне порушення схеми Prism передає лише в заголовку `sl-violations`. Наприклад, для `hours: -1` і для відсутнього `level` тіло однакове: `details[0]` = `targetDuration` / `TOTAL_GREATER_THAN_ZERO` (приклад для 0 год 0 хв). Статус і `code` відповідають контракту, а `details[]` — ні. Реальна система має заповнювати `details[]` за фактичним порушенням; mock цього не перевіряє.
- **Без `example=` mock повертає перший приклад коду стану** (POS-17). Тому відповідь на перенесення елемента має склад етапів із прикладу `roundsChanged`, а не з перенесення.

## 2. Позитивні сценарії (крок 11)

Сценарії покривають усі 27 операцій. Для операцій із кількома суттєвими успішними прикладами (план із попередженнями, порожній перелік, вправа без відеоданих, застаріла вправа тощо) є окремий сценарій на кожен такий приклад.

| ID | operationId | REQ-ID | AC / BDD | Запит | Очікуваний статус | Очікуваний результат (ключові поля прикладу) |
|---|---|---|---|---|---|---|
| POS-01 | `listExercises` | REQ-F-001, REQ-F-003 | AC-F-003; BDD-001, BDD-004 | `GET /exercises?stage=warm-up&level=level-beginner`; `Prefer: example=catalog` | 200 | `items` — 3 вправи (`ex-1`, `ex-2`, `ex-5`), у кожної `id`, `name`, `type`, `origin` |
| POS-02 | `listExercises` | REQ-F-003 | AC-F-003 | `GET /exercises?loadCharacter=general-physical&equipment=equipment-bag`; `Prefer: example=emptySelection` | 200 | `items: []` — стан порожньої вибірки |
| POS-03 | `createExercise` | REQ-F-002, REQ-F-004 | AC-F-002, AC-F-004; BDD-002, BDD-024 | `POST /exercises`, власна вправа без відеоданих | 201 | `id: ex-5`, `origin: custom`, `deprecated: false`, `videoUrl`/`videoAuthorName`/`authorPageUrl: null`; заголовок `Location` |
| POS-04 | `getExercise` | REQ-F-002, REQ-F-004 | AC-F-004; BDD-005 | `GET /exercises/ex-1`; `example=initialExercise` | 200 | `origin: initial`, HTTPS-посилання `videoUrl`, `authorPageUrl`, `videoAuthorName` заповнено; варіант `var-1`, `mode: time` |
| POS-05 | `getExercise` | REQ-F-002, REQ-F-004 | AC-F-004; BDD-024 | `GET /exercises/ex-5`; `example=customWithoutVideo` | 200 | `origin: custom`; усі три відеополя `null` (D-07) |
| POS-06 | `getExercise` | REQ-F-002 | D-06 | `GET /exercises/ex-9`; `example=deprecatedExercise` | 200 | `deprecated: true` — картка застарілої вправи доступна |
| POS-07 | `updateExercise` | REQ-F-002, REQ-F-004 | AC-F-002; BDD-002; ADD-002 D-33 | `PUT /exercises/ex-5`, новий опис, варіант з `id: var-1` | 200 | `description` оновлено; варіант зберіг `id: var-1` |
| POS-08 | `getDictionary` | REQ-F-003, REQ-F-005 | — | `GET /dictionaries/training-levels` | 200 | `dictionary: training-levels`; `values` — `level-beginner`, `level-intermediate` |
| POS-09 | `generatePlan` | REQ-F-005…009 | AC-F-005…008; BDD-007 | `POST /plan-generations`, ціль 1 год 30 хв | 201 | `name: null`, `sourcePlanId: null`; `targetDurationSeconds: 5400`; `durationTolerance` 4860–5940; три непорожні етапи `warm-up`, `main`, `cool-down`; `estimatedDurationSeconds: 5310`; `warnings: []`; `Location` |
| POS-10 | `openSavedPlan` | REQ-F-011, REQ-F-012 | AC-F-011; BDD-015 | `POST /open-plans`, `sourcePlanId: plan-1` | 201 | `id: open-2`, `sourcePlanId: plan-1`, `name: План від 30.06.2026 17:45` |
| POS-11 | `getOpenPlan` | REQ-F-007, REQ-F-010 | AC-F-007, AC-F-010 | `GET /open-plans/open-1`; `example=generated` | 200 | як POS-09: 5310 с, без попереджень |
| POS-12 | `getOpenPlan` | REQ-F-007, REQ-F-010 | AC-F-007 | `GET /open-plans/open-2`; `example=openedFromSaved` | 200 | `sourcePlanId: plan-1`, назва збереженого плану |
| POS-13 | `renameOpenPlan` | REQ-F-011 | ADD-002 D-32 | `PATCH /open-plans/open-1`, `name: [TEST] Ранкове тренування` | 200 | `name: [TEST] Ранкове тренування`, `sourcePlanId: null` |
| POS-14 | `addOpenPlanItem` | REQ-F-010 | AC-F-010; BDD-013 | `POST /open-plans/open-1/items`, `ex-1` / `var-1` до `cool-down` | 201 | новий `item-5` у `cool-down`, `estimatedDurationSeconds: 5430`; попередження `STAGE_NOT_IN_EXERCISE` для `item-5`; `Location` |
| POS-15 | `replaceOpenPlanItem` | REQ-F-010 | AC-F-010 | `PUT /open-plans/open-1/items/item-3`, `ex-5` / `var-1` | 200 | `item-3` тепер `ex-5`; `estimatedDurationSeconds: 5280`; `FILTER_MISMATCH` для `intensity`, `availableEquipment`, `emphasis` і `STAGE_NOT_IN_EXERCISE` |
| POS-16 | `updateOpenPlanItem` | REQ-F-010 | AC-F-010; BDD-013 | `PATCH /open-plans/open-1/items/item-2`, `rounds: 10` | 200 | `item-2.parameters.rounds: 10`, `estimatedDurationSeconds: 2340`; план 4830 с < 4860 с — попередження `DURATION_OUT_OF_TOLERANCE`; інші елементи без змін |
| POS-17 | `updateOpenPlanItem` | REQ-F-010 | AC-F-010; BDD-023 | `PATCH /open-plans/open-1/items/item-3`, `stage: warm-up`, `position: 1` | 200 | запит на перенесення приймається (статус 200, тіло — `OpenPlan`). В специфікації один приклад відповіді (`roundsChanged`), тому склад етапів у відповіді mock не відображає саме перенесення |
| POS-18 | `deleteOpenPlanItem` | REQ-F-010 | AC-F-010; BDD-033 | `DELETE /open-plans/open-1/items/item-1` | 200 | `warm-up.items: []`; попередження `STAGE_EMPTY` (`warm-up`) і `DURATION_OUT_OF_TOLERANCE`; `estimatedDurationSeconds: 4650` |
| POS-19 | `listTrainingPlans` | REQ-F-011 | D-16 | `GET /training-plans`; `example=plans` | 200 | 2 плани, `modifiedAt` спадає: `plan-2` (01.07.2026) перед `plan-1` (30.06.2026) |
| POS-20 | `listTrainingPlans` | REQ-F-011 | D-16 | `GET /training-plans`; `example=empty` | 200 | `items: []` |
| POS-21 | `saveNewTrainingPlan` | REQ-F-011, REQ-NF-002, REQ-NF-003 | AC-F-011, AC-NF-003; BDD-023; ADD-002 D-32 | `POST /training-plans`, `openPlanId: open-1` | 201 | `id: plan-1`, `name: План від 30.06.2026 17:45` (момент збереження = `modifiedAt` 17:45); `Location` |
| POS-22 | `getTrainingPlan` | REQ-F-011 | AC-F-011; BDD-015 | `GET /training-plans/plan-1` | 200 | збережені етапи, порядок і параметри; `estimatedDurationSeconds: 5310` |
| POS-23 | `overwriteTrainingPlan` | REQ-F-011, REQ-NF-003 | AC-F-011, AC-NF-003; BDD-014 | `PUT /training-plans/plan-1`, `openPlanId: open-2` | 200 | `modifiedAt` 17:55; план 4830 с поза допуском — `DURATION_OUT_OF_TOLERANCE`, але збереження дозволене |
| POS-24 | `deleteTrainingPlan` | REQ-F-011 | D-16 | `DELETE /training-plans/plan-1` | 204 | без тіла |
| POS-25 | `startCurrentSession` | REQ-F-012 | AC-F-012; BDD-016 | `POST /current-session`, `openPlanId: open-1` | 201 | `startedAt: 2026-06-30T18:00:00+03:00`, `localStartDate: 2026-06-30`; `executedPlan` — три етапи; `Location` |
| POS-26 | `getCurrentSession` | REQ-F-012 | D-18 | `GET /current-session` | 200 | як POS-25 |
| POS-27 | `updateExecutedPlanItem` | REQ-F-013 | AC-F-013; BDD-016; D-19 | `PATCH /current-session/executed-plan/items/item-3`, `sets: 6` | 200 | `item-3.parameters.sets: 6` — понад максимум варіанта 5 приймається; `estimatedDurationSeconds: 330` |
| POS-28 | `deleteExecutedPlanItem` | REQ-F-013 | AC-F-013; BDD-028 | `DELETE /current-session/executed-plan/items/item-3` | 200 | `main.items` — лише `item-2` |
| POS-29 | `abortCurrentSession` | REQ-F-013 | AC-F-013; BDD-026 | `DELETE /current-session` | 204 | без тіла |
| POS-30 | `completeTraining` | REQ-F-013, REQ-NF-002, REQ-NF-003 | AC-F-013; BDD-016 | `POST /completed-trainings`, `note` задано; `example=completedWithNote` | 201 | `id: training-1`, `startedAt` 18:00, `note` заповнено; `executedPlan` з уточненими підходами; `Location` |
| POS-31 | `completeTraining` | REQ-F-013 | AC-F-013 | `POST /completed-trainings`, тіло `{}`; `example=completedWithoutNote` | 201 | `note: null` |
| POS-32 | `listCompletedTrainings` | REQ-F-014 | AC-F-014 | `GET /completed-trainings`; `example=history` | 200 | 2 записи, `startedAt` спадає: `training-2` перед `training-1` |
| POS-33 | `listCompletedTrainings` | REQ-F-014 | AC-F-014; BDD-020 | `GET /completed-trainings`; `example=emptyHistory` | 200 | `items: []` |
| POS-34 | `getCompletedTraining` | REQ-F-014 | AC-F-014; BDD-016, BDD-017 | `GET /completed-trainings/training-1` | 200 | `startedAt`, `localStartDate`, `executedPlan` (копії назв і параметрів), `note` |
| POS-35 | `getAnalytics` | REQ-F-015, REQ-F-016 | AC-F-015, AC-F-016; BDD-018 | `GET /analytics?from=2026-06-01&to=2026-06-30`; `example=june2026` | 200 | `completedTrainingCount: 2`; `dailyCounts` — 30 днів, сума 2, зокрема дні з 0; `exerciseFrequencies` — `ex-1`, `trainingCount: 2` |
| POS-36 | `getAnalytics` | REQ-F-015, REQ-F-016 | AC-F-016; BDD-020 | `GET /analytics?from=2026-06-29&to=2026-06-30`; `example=noData` | 200 | `completedTrainingCount: 0`; `dailyCounts` — 2 дні з 0; `exerciseFrequencies: []` |

### Команди позитивних сценаріїв

#### POS-01
```bash
curl -i -s 'http://127.0.0.1:4010/exercises?stage=warm-up&level=level-beginner' -H 'Prefer: code=200, example=catalog'
```

#### POS-02
```bash
curl -i -s 'http://127.0.0.1:4010/exercises?loadCharacter=general-physical&equipment=equipment-bag' -H 'Prefer: code=200, example=emptySelection'
```

#### POS-03
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/exercises' -H 'Content-Type: application/json' -H 'Prefer: code=201, example=customCreated' -d '{"name":"[TEST] Стрибки на скакалці","description":"[TEST] Опис стрибків на скакалці.","type":"simple","allowedStages":["warm-up"],"allowedLevels":["level-beginner"],"allowedIntensities":["intensity-high"],"emphases":["emphasis-endurance"],"loadCharacter":"general-physical","variants":[{"executionMeans":"means-apparatus","equipment":["equipment-rope"],"mode":"time","rounds":{"min":1,"max":5,"recommended":3},"intervalSeconds":{"min":60,"max":180,"recommended":120},"restSeconds":{"min":30,"max":90,"recommended":60}}]}'
```

#### POS-04
```bash
curl -i -s 'http://127.0.0.1:4010/exercises/ex-1' -H 'Prefer: code=200, example=initialExercise'
```

#### POS-05
```bash
curl -i -s 'http://127.0.0.1:4010/exercises/ex-5' -H 'Prefer: code=200, example=customWithoutVideo'
```

#### POS-06
```bash
curl -i -s 'http://127.0.0.1:4010/exercises/ex-9' -H 'Prefer: code=200, example=deprecatedExercise'
```

#### POS-07
```bash
curl -i -s -X PUT 'http://127.0.0.1:4010/exercises/ex-5' -H 'Content-Type: application/json' -H 'Prefer: code=200, example=updated' -d '{"name":"[TEST] Стрибки на скакалці","description":"[TEST] Оновлений опис стрибків на скакалці.","type":"simple","allowedStages":["warm-up"],"allowedLevels":["level-beginner"],"allowedIntensities":["intensity-high"],"emphases":["emphasis-endurance"],"loadCharacter":"general-physical","variants":[{"id":"var-1","executionMeans":"means-apparatus","equipment":["equipment-rope"],"mode":"time","rounds":{"min":1,"max":5,"recommended":3},"intervalSeconds":{"min":60,"max":180,"recommended":120},"restSeconds":{"min":30,"max":90,"recommended":60}}],"videoUrl":null,"videoAuthorName":null,"authorPageUrl":null}'
```

#### POS-08
```bash
curl -i -s 'http://127.0.0.1:4010/dictionaries/training-levels' -H 'Prefer: code=200, example=trainingLevels'
```

#### POS-09
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/plan-generations' -H 'Content-Type: application/json' -H 'Prefer: code=201, example=generated' -d '{"targetDuration":{"hours":1,"minutes":30},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
```

#### POS-10
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/open-plans' -H 'Content-Type: application/json' -H 'Prefer: code=201, example=openedFromSaved' -d '{"sourcePlanId":"plan-1"}'
```

#### POS-11
```bash
curl -i -s 'http://127.0.0.1:4010/open-plans/open-1' -H 'Prefer: code=200, example=generated'
```

#### POS-12
```bash
curl -i -s 'http://127.0.0.1:4010/open-plans/open-2' -H 'Prefer: code=200, example=openedFromSaved'
```

#### POS-13
```bash
curl -i -s -X PATCH 'http://127.0.0.1:4010/open-plans/open-1' -H 'Content-Type: application/json' -H 'Prefer: code=200, example=renamed' -d '{"name":"[TEST] Ранкове тренування"}'
```

#### POS-14
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/open-plans/open-1/items' -H 'Content-Type: application/json' -H 'Prefer: code=201, example=itemAdded' -d '{"exerciseId":"ex-1","variantId":"var-1","stage":"cool-down","parameters":{"rounds":1,"intervalSeconds":120,"restSeconds":30}}'
```

#### POS-15
```bash
curl -i -s -X PUT 'http://127.0.0.1:4010/open-plans/open-1/items/item-3' -H 'Content-Type: application/json' -H 'Prefer: code=200, example=itemReplaced' -d '{"exerciseId":"ex-5","variantId":"var-1","parameters":{"rounds":1,"intervalSeconds":120,"restSeconds":60}}'
```

#### POS-16
```bash
curl -i -s -X PATCH 'http://127.0.0.1:4010/open-plans/open-1/items/item-2' -H 'Content-Type: application/json' -H 'Prefer: code=200, example=roundsChanged' -d '{"parameters":{"rounds":10}}'
```

#### POS-17
```bash
curl -i -s -X PATCH 'http://127.0.0.1:4010/open-plans/open-1/items/item-3' -H 'Content-Type: application/json' -H 'Prefer: code=200' -d '{"stage":"warm-up","position":1}'
```

#### POS-18
```bash
curl -i -s -X DELETE 'http://127.0.0.1:4010/open-plans/open-1/items/item-1' -H 'Prefer: code=200, example=warmUpEmptied'
```

#### POS-19
```bash
curl -i -s 'http://127.0.0.1:4010/training-plans' -H 'Prefer: code=200, example=plans'
```

#### POS-20
```bash
curl -i -s 'http://127.0.0.1:4010/training-plans' -H 'Prefer: code=200, example=empty'
```

#### POS-21
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/training-plans' -H 'Content-Type: application/json' -H 'Prefer: code=201, example=saved' -d '{"openPlanId":"open-1"}'
```

#### POS-22
```bash
curl -i -s 'http://127.0.0.1:4010/training-plans/plan-1' -H 'Prefer: code=200, example=saved'
```

#### POS-23
```bash
curl -i -s -X PUT 'http://127.0.0.1:4010/training-plans/plan-1' -H 'Content-Type: application/json' -H 'Prefer: code=200, example=overwrittenOutOfTolerance' -d '{"openPlanId":"open-2"}'
```

#### POS-24
```bash
curl -i -s -X DELETE 'http://127.0.0.1:4010/training-plans/plan-1' -H 'Prefer: code=204'
```

#### POS-25
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/current-session' -H 'Content-Type: application/json' -H 'Prefer: code=201, example=started' -d '{"openPlanId":"open-1"}'
```

#### POS-26
```bash
curl -i -s 'http://127.0.0.1:4010/current-session' -H 'Prefer: code=200, example=started'
```

#### POS-27
```bash
curl -i -s -X PATCH 'http://127.0.0.1:4010/current-session/executed-plan/items/item-3' -H 'Content-Type: application/json' -H 'Prefer: code=200, example=itemUpdated' -d '{"parameters":{"sets":6}}'
```

#### POS-28
```bash
curl -i -s -X DELETE 'http://127.0.0.1:4010/current-session/executed-plan/items/item-3' -H 'Prefer: code=200, example=itemRemoved'
```

#### POS-29
```bash
curl -i -s -X DELETE 'http://127.0.0.1:4010/current-session' -H 'Prefer: code=204'
```

#### POS-30
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/completed-trainings' -H 'Content-Type: application/json' -H 'Prefer: code=201, example=completedWithNote' -d '{"note":"[TEST] Зроблено додаткові підходи віджимань."}'
```

#### POS-31
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/completed-trainings' -H 'Content-Type: application/json' -H 'Prefer: code=201, example=completedWithoutNote' -d '{}'
```

#### POS-32
```bash
curl -i -s 'http://127.0.0.1:4010/completed-trainings' -H 'Prefer: code=200, example=history'
```

#### POS-33
```bash
curl -i -s 'http://127.0.0.1:4010/completed-trainings' -H 'Prefer: code=200, example=emptyHistory'
```

#### POS-34
```bash
curl -i -s 'http://127.0.0.1:4010/completed-trainings/training-1' -H 'Prefer: code=200, example=completedWithNote'
```

#### POS-35
```bash
curl -i -s 'http://127.0.0.1:4010/analytics?from=2026-06-01&to=2026-06-30' -H 'Prefer: code=200, example=june2026'
```

#### POS-36
```bash
curl -i -s 'http://127.0.0.1:4010/analytics?from=2026-06-29&to=2026-06-30' -H 'Prefer: code=200, example=noData'
```

## 3. Негативні сценарії (крок 12)

### 3.1. Сценарії за кодами `Error`

Покриття: кожен із 22 кодів enum `Error.code` і кожна з трьох причин `PLAN_GENERATION_IMPOSSIBLE` (`reasons[].code`). Для `VALIDATION_FAILED` і `NO_CURRENT_SESSION` додано сценарії в кількох операціях, бо ці коди мають різний зміст залежно від операції. Запити відповідають схемі; відповідь вибирається заголовком `Prefer`.

| ID | operationId | REQ-ID | AC / BDD | Запит | Очікуваний статус | Очікуваний code |
|---|---|---|---|---|---|---|
| NEG-01 | `generatePlan` | REQ-F-005 | AC-F-005 | `POST /plan-generations`; `Prefer: code=400, example=badRequest` | 400 | `BAD_REQUEST` |
| NEG-02 | `getExercise` | REQ-F-002 | — | `GET /exercises/ex-404`; `code=404, example=notFound` | 404 | `NOT_FOUND` |
| NEG-03 | `createExercise` | REQ-F-002 | AC-F-002; BDD-003 | `POST /exercises`; `code=422, example=validationFailed` | 422 | `VALIDATION_FAILED` (`details[0].field: variants[0].rounds.min`, `constraint: MIN_LE_MAX`) |
| NEG-04 | `generatePlan` | REQ-F-005 | AC-F-005; BDD-006 | `POST /plan-generations`, `hours: 0`, `minutes: 0`; `code=422, example=validationFailed` | 422 | `VALIDATION_FAILED` (`details[0].constraint: TOTAL_GREATER_THAN_ZERO`) |
| NEG-05 | `listExercises` | REQ-F-003 | AC-F-003 | `GET /exercises?level=level-unknown`; `code=422, example=unknownDictionaryValue` | 422 | `UNKNOWN_DICTIONARY_VALUE` |
| NEG-06 | `updateExercise` | REQ-F-002 | AC-F-002; D-05 | `PUT /exercises/ex-1`; `code=403, example=initialReadOnly` | 403 | `INITIAL_EXERCISE_READ_ONLY` |
| NEG-07 | `completeTraining` | REQ-NF-003 | AC-NF-003; BDD-021 | `POST /completed-trainings`; `code=500, example=storageWriteFailed` | 500 | `STORAGE_WRITE_FAILED` |
| NEG-08 | `generatePlan` | REQ-F-009 | AC-F-009; BDD-011 | `POST /plan-generations`; `code=422, example=impossibleNoCandidates` | 422 | `PLAN_GENERATION_IMPOSSIBLE`, `reasons[0]`: `NO_CANDIDATES_FOR_STAGE`, `stage: cool-down` |
| NEG-09 | `generatePlan` | REQ-F-009 | AC-F-009; BDD-012 | `POST /plan-generations`, ціль 2 год 0 хв; `code=422, example=impossibleMaxVolume` | 422 | `PLAN_GENERATION_IMPOSSIBLE`, `reasons[0]`: `MAX_VOLUME_BELOW_LOWER_BOUND` |
| NEG-10 | `generatePlan` | REQ-F-009 | AC-F-009; D-10 | `POST /plan-generations`; `code=422, example=impossibleMinVolume` | 422 | `PLAN_GENERATION_IMPOSSIBLE`, `reasons[0]`: `MIN_VOLUME_ABOVE_UPPER_BOUND` |
| NEG-11 | `generatePlan` | REQ-F-009 | AC-F-009 | `POST /plan-generations`; `code=500, example=generationFailed` | 500 | `GENERATION_FAILED` |
| NEG-12 | `generatePlan` | REQ-F-009 | AC-F-009; D-13, D-25 | `POST /plan-generations`; `code=503, example=searchLimitReached` | 503 | `GENERATION_SEARCH_LIMIT_REACHED`, `limitSeconds: 3` |
| NEG-13 | `openSavedPlan` | REQ-F-011 | AC-F-011 | `POST /open-plans`, `sourcePlanId: plan-404`; `code=422, example=planNotFound` | 422 | `PLAN_NOT_FOUND` |
| NEG-14 | `addOpenPlanItem` | REQ-F-010 | AC-F-010 | `POST /open-plans/open-1/items`, `exerciseId: ex-404`; `code=422, example=exerciseNotFound` | 422 | `EXERCISE_NOT_FOUND` |
| NEG-15 | `addOpenPlanItem` | REQ-F-010 | AC-F-010; ADD-002 D-33 | `POST /open-plans/open-1/items`, `variantId: var-404`; `code=422, example=variantNotFound` | 422 | `VARIANT_NOT_FOUND` |
| NEG-16 | `addOpenPlanItem` | REQ-F-010 | AC-F-010; D-06 | `POST /open-plans/open-1/items`, `exerciseId: ex-9`; `code=422, example=exerciseDeprecated` | 422 | `EXERCISE_DEPRECATED` |
| NEG-17 | `addOpenPlanItem` | REQ-F-010 | AC-F-010; BDD-032 | `POST /open-plans/open-1/items`, `rounds: 6` при максимумі 5; `code=422, example=outOfVariantRange` | 422 | `VALIDATION_FAILED` (`constraint: WITHIN_VARIANT_RANGE`) |
| NEG-18 | `updateOpenPlanItem` | REQ-F-010 | AC-F-010; D-08 | `PATCH /open-plans/open-1/items/item-3`, `repetitionTimeSeconds: 5`; `code=422, example=repetitionTimeNotEditable` | 422 | `VALIDATION_FAILED` (`field: parameters.repetitionTimeSeconds`) |
| NEG-19 | `saveNewTrainingPlan` | REQ-F-011 | AC-F-011; D-16 | `POST /training-plans`, `openPlanId: open-2`; `code=409, example=alreadySaved` | 409 | `OPEN_PLAN_ALREADY_SAVED` |
| NEG-20 | `saveNewTrainingPlan` | REQ-F-011 | AC-F-011 | `POST /training-plans`, `openPlanId: open-404`; `code=422, example=openPlanNotFound` | 422 | `OPEN_PLAN_NOT_FOUND` |
| NEG-21 | `saveNewTrainingPlan` | REQ-F-011 | AC-F-011; BDD-033 | `POST /training-plans`; `code=422, example=planEmpty` | 422 | `PLAN_EMPTY` |
| NEG-22 | `overwriteTrainingPlan` | REQ-F-011 | AC-F-011 | `PUT /training-plans/plan-2`, `openPlanId: open-2`; `code=409, example=sourceMismatch` | 409 | `OPEN_PLAN_SOURCE_MISMATCH` |
| NEG-23 | `startCurrentSession` | REQ-F-012 | AC-F-012; BDD-025 | `POST /current-session`; `code=409, example=sessionAlreadyActive` | 409 | `SESSION_ALREADY_ACTIVE` |
| NEG-24 | `getCurrentSession` | REQ-F-012 | D-18 | `GET /current-session`; `code=404, example=noCurrentSession` | 404 | `NO_CURRENT_SESSION` |
| NEG-25 | `completeTraining` | REQ-F-013 | AC-F-013; BDD-016 | `POST /completed-trainings` (повторне завершення); `code=409, example=noCurrentSession` | 409 | `NO_CURRENT_SESSION` |
| NEG-26 | `completeTraining` | REQ-F-013 | AC-F-013; BDD-028 | `POST /completed-trainings`; `code=422, example=executedPlanEmpty` | 422 | `EXECUTED_PLAN_EMPTY` |
| NEG-27 | `getAnalytics` | REQ-F-015 | AC-F-015; BDD-030 | `GET /analytics?from=2026-06-30&to=2026-06-01`; `code=422, example=fromAfterTo` | 422 | `INVALID_PERIOD` (`constraint: NOT_AFTER_TO`) |
| NEG-28 | `getAnalytics` | REQ-F-015 | AC-F-015; ADD-002 D-35 | `GET /analytics?from=2026-06-01`; `code=422, example=onlyOneDate` | 422 | `INVALID_PERIOD` (`constraint: REQUIRED_WITH_FROM`) |
| NEG-29 | `getAnalytics` | REQ-F-015 | AC-F-015; D-21 | `GET /analytics?from=2026-06-01&to=2099-01-01`; `code=422, example=endDateInFuture` | 422 | `END_DATE_IN_FUTURE` |
| NEG-30 | `deleteExecutedPlanItem` | REQ-F-013 | AC-F-013 | `DELETE /current-session/executed-plan/items/item-404`; `code=404, example=itemNotFound` | 404 | `NOT_FOUND` |
| NEG-31 | `abortCurrentSession` | REQ-F-013 | AC-F-013 | `DELETE /current-session`; `code=404, example=noCurrentSession` | 404 | `NO_CURRENT_SESSION` |

### 3.2. Сценарії з фактичним порушенням схеми (без `Prefer`)

Ці запити справді порушують схему `spec/openapi.yaml`. Вони перевіряють, як mock валідує вхідні дані. Заголовка `Prefer` немає.

За контрактом (розділ 4.0 і 4.6 моделі; `info.description` специфікації) очікується `422 VALIDATION_FAILED`. Prism відхиляє запит до вибору прикладу, тому фактичний статус і формат тіла (власний формат Prism чи приклад зі специфікації) треба зафіксувати на кроці 13 і порівняти з очікуваним.

| ID | operationId | REQ-ID | AC / BDD | Запит (порушення схеми) | Очікуваний статус | Очікуваний code |
|---|---|---|---|---|---|---|
| NEG-32 | `generatePlan` | REQ-F-005 | AC-F-005; BDD-006 | `POST /plan-generations`, `hours: -1`, `minutes: 30` — порушено `minimum: 0` | 422 | `VALIDATION_FAILED` |
| NEG-33 | `generatePlan` | REQ-F-005 | AC-F-005 | `POST /plan-generations` без обов'язкового поля `level` — порушено `required` | 422 | `VALIDATION_FAILED` |
| NEG-34 | `updateExecutedPlanItem` | REQ-F-013 | AC-F-013; D-19 | `PATCH /current-session/executed-plan/items/item-3`, `sets: 0` — порушено `minimum: 1` | 422 | `VALIDATION_FAILED` |

### Команди негативних сценаріїв

#### NEG-01
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/plan-generations' -H 'Content-Type: application/json' -H 'Prefer: code=400, example=badRequest' -d '{"targetDuration":{"hours":1,"minutes":30},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
```

#### NEG-02
```bash
curl -i -s 'http://127.0.0.1:4010/exercises/ex-404' -H 'Prefer: code=404, example=notFound'
```

#### NEG-03
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/exercises' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=validationFailed' -d '{"name":"[TEST] Стрибки на скакалці","description":"[TEST] Опис стрибків на скакалці.","type":"simple","allowedStages":["warm-up"],"allowedLevels":["level-beginner"],"allowedIntensities":["intensity-high"],"emphases":["emphasis-endurance"],"loadCharacter":"general-physical","variants":[{"executionMeans":"means-apparatus","equipment":["equipment-rope"],"mode":"time","rounds":{"min":5,"max":3,"recommended":3},"intervalSeconds":{"min":60,"max":180,"recommended":120},"restSeconds":{"min":30,"max":90,"recommended":60}}]}'
```

#### NEG-04
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/plan-generations' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=validationFailed' -d '{"targetDuration":{"hours":0,"minutes":0},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
```

#### NEG-05
```bash
curl -i -s 'http://127.0.0.1:4010/exercises?level=level-unknown' -H 'Prefer: code=422, example=unknownDictionaryValue'
```

#### NEG-06
```bash
curl -i -s -X PUT 'http://127.0.0.1:4010/exercises/ex-1' -H 'Content-Type: application/json' -H 'Prefer: code=403, example=initialReadOnly' -d '{"name":"[TEST] Бій з тінню","description":"[TEST] Змінений опис.","type":"simple","allowedStages":["warm-up"],"allowedLevels":["level-beginner"],"allowedIntensities":["intensity-medium"],"emphases":["emphasis-technique"],"loadCharacter":"special-physical","variants":[{"id":"var-1","executionMeans":"means-no-equipment","equipment":[],"mode":"time","rounds":{"min":1,"max":5,"recommended":3},"intervalSeconds":{"min":60,"max":300,"recommended":180},"restSeconds":{"min":30,"max":120,"recommended":60}}]}'
```

#### NEG-07
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/completed-trainings' -H 'Content-Type: application/json' -H 'Prefer: code=500, example=storageWriteFailed' -d '{"note":null}'
```

#### NEG-08
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/plan-generations' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=impossibleNoCandidates' -d '{"targetDuration":{"hours":1,"minutes":0},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":[],"intensity":"intensity-medium"}'
```

#### NEG-09
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/plan-generations' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=impossibleMaxVolume' -d '{"targetDuration":{"hours":2,"minutes":0},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
```

#### NEG-10
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/plan-generations' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=impossibleMinVolume' -d '{"targetDuration":{"hours":0,"minutes":10},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
```

#### NEG-11
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/plan-generations' -H 'Content-Type: application/json' -H 'Prefer: code=500, example=generationFailed' -d '{"targetDuration":{"hours":1,"minutes":30},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
```

#### NEG-12
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/plan-generations' -H 'Content-Type: application/json' -H 'Prefer: code=503, example=searchLimitReached' -d '{"targetDuration":{"hours":1,"minutes":30},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
```

#### NEG-13
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/open-plans' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=planNotFound' -d '{"sourcePlanId":"plan-404"}'
```

#### NEG-14
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/open-plans/open-1/items' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=exerciseNotFound' -d '{"exerciseId":"ex-404","variantId":"var-1","stage":"main","parameters":{"rounds":3,"intervalSeconds":180,"restSeconds":60}}'
```

#### NEG-15
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/open-plans/open-1/items' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=variantNotFound' -d '{"exerciseId":"ex-1","variantId":"var-404","stage":"main","parameters":{"rounds":3,"intervalSeconds":180,"restSeconds":60}}'
```

#### NEG-16
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/open-plans/open-1/items' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=exerciseDeprecated' -d '{"exerciseId":"ex-9","variantId":"var-1","stage":"main","parameters":{"rounds":3,"intervalSeconds":180,"restSeconds":60}}'
```

#### NEG-17
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/open-plans/open-1/items' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=outOfVariantRange' -d '{"exerciseId":"ex-1","variantId":"var-1","stage":"warm-up","parameters":{"rounds":6,"intervalSeconds":180,"restSeconds":60}}'
```

#### NEG-18
```bash
curl -i -s -X PATCH 'http://127.0.0.1:4010/open-plans/open-1/items/item-3' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=repetitionTimeNotEditable' -d '{"parameters":{"repetitionTimeSeconds":5}}'
```

#### NEG-19
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/training-plans' -H 'Content-Type: application/json' -H 'Prefer: code=409, example=alreadySaved' -d '{"openPlanId":"open-2"}'
```

#### NEG-20
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/training-plans' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=openPlanNotFound' -d '{"openPlanId":"open-404"}'
```

#### NEG-21
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/training-plans' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=planEmpty' -d '{"openPlanId":"open-1"}'
```

#### NEG-22
```bash
curl -i -s -X PUT 'http://127.0.0.1:4010/training-plans/plan-2' -H 'Content-Type: application/json' -H 'Prefer: code=409, example=sourceMismatch' -d '{"openPlanId":"open-2"}'
```

#### NEG-23
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/current-session' -H 'Content-Type: application/json' -H 'Prefer: code=409, example=sessionAlreadyActive' -d '{"openPlanId":"open-1"}'
```

#### NEG-24
```bash
curl -i -s 'http://127.0.0.1:4010/current-session' -H 'Prefer: code=404, example=noCurrentSession'
```

#### NEG-25
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/completed-trainings' -H 'Content-Type: application/json' -H 'Prefer: code=409, example=noCurrentSession' -d '{"note":"[TEST] Повторне завершення."}'
```

#### NEG-26
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/completed-trainings' -H 'Content-Type: application/json' -H 'Prefer: code=422, example=executedPlanEmpty' -d '{}'
```

#### NEG-27
```bash
curl -i -s 'http://127.0.0.1:4010/analytics?from=2026-06-30&to=2026-06-01' -H 'Prefer: code=422, example=fromAfterTo'
```

#### NEG-28
```bash
curl -i -s 'http://127.0.0.1:4010/analytics?from=2026-06-01' -H 'Prefer: code=422, example=onlyOneDate'
```

#### NEG-29
```bash
curl -i -s 'http://127.0.0.1:4010/analytics?from=2026-06-01&to=2099-01-01' -H 'Prefer: code=422, example=endDateInFuture'
```

#### NEG-30
```bash
curl -i -s -X DELETE 'http://127.0.0.1:4010/current-session/executed-plan/items/item-404' -H 'Prefer: code=404, example=itemNotFound'
```

#### NEG-31
```bash
curl -i -s -X DELETE 'http://127.0.0.1:4010/current-session' -H 'Prefer: code=404, example=noCurrentSession'
```

#### NEG-32
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/plan-generations' -H 'Content-Type: application/json' -d '{"targetDuration":{"hours":-1,"minutes":30},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
```

#### NEG-33
```bash
curl -i -s -X POST 'http://127.0.0.1:4010/plan-generations' -H 'Content-Type: application/json' -d '{"targetDuration":{"hours":1,"minutes":30},"emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
```

#### NEG-34
```bash
curl -i -s -X PATCH 'http://127.0.0.1:4010/current-session/executed-plan/items/item-3' -H 'Content-Type: application/json' -d '{"parameters":{"sets":0}}'
```

## 4. Покриття

Підраховано скриптом за цим документом і `spec/openapi.yaml`:

- позитивних сценаріїв — 36, покрито всі 27 операцій;
- негативних сценаріїв — 34 (31 за кодами `Error` і 3 з порушенням схеми); покрито всі 22 коди `Error.code` і всі 3 причини `PLAN_GENERATION_IMPOSSIBLE`.

## 5. Результати перевірки mock (крок 13)

| Поле | Значення |
|---|---|
| Дата | 26.10.2026 |
| Mock | Stoplight Prism CLI 5.16.0, `http://127.0.0.1:4010`, специфікація `spec/openapi.yaml` (запустив власник) |
| Виконав | Кодинговий агент (Claude Code, модель `claude-opus-5-5`). Скрипт виконав усі 70 команд curl з розділів 2 і 3 без змін і розібрав статус, `Content-Type` і `code` з тіла |
| Додаткова перевірка | Тіло кожної відповіді порівняно з іменованим прикладом специфікації: для запитів з `example=` — із цим прикладом, без нього — з першим прикладом коду стану |

### 5.1. Таблиця результатів

| ID | Очікуваний статус | Фактичний статус | Очікуваний code | Фактичний code | Збіг |
|---|---|---|---|---|---|
| POS-01 | 200 | 200 | — | — | так |
| POS-02 | 200 | 200 | — | — | так |
| POS-03 | 201 | 201 | — | — | так |
| POS-04 | 200 | 200 | — | — | так |
| POS-05 | 200 | 200 | — | — | так |
| POS-06 | 200 | 200 | — | — | так |
| POS-07 | 200 | 200 | — | — | так |
| POS-08 | 200 | 200 | — | — | так |
| POS-09 | 201 | 201 | — | — | так |
| POS-10 | 201 | 201 | — | — | так |
| POS-11 | 200 | 200 | — | — | так |
| POS-12 | 200 | 200 | — | — | так |
| POS-13 | 200 | 200 | — | — | так |
| POS-14 | 201 | 201 | — | — | так |
| POS-15 | 200 | 200 | — | — | так |
| POS-16 | 200 | 200 | — | — | так |
| POS-17 | 200 | 200 | — | — | так |
| POS-18 | 200 | 200 | — | — | так |
| POS-19 | 200 | 200 | — | — | так |
| POS-20 | 200 | 200 | — | — | так |
| POS-21 | 201 | 201 | — | — | так |
| POS-22 | 200 | 200 | — | — | так |
| POS-23 | 200 | 200 | — | — | так |
| POS-24 | 204 | 204 | — | — | так |
| POS-25 | 201 | 201 | — | — | так |
| POS-26 | 200 | 200 | — | — | так |
| POS-27 | 200 | 200 | — | — | так |
| POS-28 | 200 | 200 | — | — | так |
| POS-29 | 204 | 204 | — | — | так |
| POS-30 | 201 | 201 | — | — | так |
| POS-31 | 201 | 201 | — | — | так |
| POS-32 | 200 | 200 | — | — | так |
| POS-33 | 200 | 200 | — | — | так |
| POS-34 | 200 | 200 | — | — | так |
| POS-35 | 200 | 200 | — | — | так |
| POS-36 | 200 | 200 | — | — | так |
| NEG-01 | 400 | 400 | BAD_REQUEST | BAD_REQUEST | так |
| NEG-02 | 404 | 404 | NOT_FOUND | NOT_FOUND | так |
| NEG-03 | 422 | 422 | VALIDATION_FAILED | VALIDATION_FAILED | так |
| NEG-04 | 422 | 422 | VALIDATION_FAILED | VALIDATION_FAILED | так |
| NEG-05 | 422 | 422 | UNKNOWN_DICTIONARY_VALUE | UNKNOWN_DICTIONARY_VALUE | так |
| NEG-06 | 403 | 403 | INITIAL_EXERCISE_READ_ONLY | INITIAL_EXERCISE_READ_ONLY | так |
| NEG-07 | 500 | 500 | STORAGE_WRITE_FAILED | STORAGE_WRITE_FAILED | так |
| NEG-08 | 422 | 422 | PLAN_GENERATION_IMPOSSIBLE | PLAN_GENERATION_IMPOSSIBLE | так |
| NEG-09 | 422 | 422 | PLAN_GENERATION_IMPOSSIBLE | PLAN_GENERATION_IMPOSSIBLE | так |
| NEG-10 | 422 | 422 | PLAN_GENERATION_IMPOSSIBLE | PLAN_GENERATION_IMPOSSIBLE | так |
| NEG-11 | 500 | 500 | GENERATION_FAILED | GENERATION_FAILED | так |
| NEG-12 | 503 | 503 | GENERATION_SEARCH_LIMIT_REACHED | GENERATION_SEARCH_LIMIT_REACHED | так |
| NEG-13 | 422 | 422 | PLAN_NOT_FOUND | PLAN_NOT_FOUND | так |
| NEG-14 | 422 | 422 | EXERCISE_NOT_FOUND | EXERCISE_NOT_FOUND | так |
| NEG-15 | 422 | 422 | VARIANT_NOT_FOUND | VARIANT_NOT_FOUND | так |
| NEG-16 | 422 | 422 | EXERCISE_DEPRECATED | EXERCISE_DEPRECATED | так |
| NEG-17 | 422 | 422 | VALIDATION_FAILED | VALIDATION_FAILED | так |
| NEG-18 | 422 | 422 | VALIDATION_FAILED | VALIDATION_FAILED | так |
| NEG-19 | 409 | 409 | OPEN_PLAN_ALREADY_SAVED | OPEN_PLAN_ALREADY_SAVED | так |
| NEG-20 | 422 | 422 | OPEN_PLAN_NOT_FOUND | OPEN_PLAN_NOT_FOUND | так |
| NEG-21 | 422 | 422 | PLAN_EMPTY | PLAN_EMPTY | так |
| NEG-22 | 409 | 409 | OPEN_PLAN_SOURCE_MISMATCH | OPEN_PLAN_SOURCE_MISMATCH | так |
| NEG-23 | 409 | 409 | SESSION_ALREADY_ACTIVE | SESSION_ALREADY_ACTIVE | так |
| NEG-24 | 404 | 404 | NO_CURRENT_SESSION | NO_CURRENT_SESSION | так |
| NEG-25 | 409 | 409 | NO_CURRENT_SESSION | NO_CURRENT_SESSION | так |
| NEG-26 | 422 | 422 | EXECUTED_PLAN_EMPTY | EXECUTED_PLAN_EMPTY | так |
| NEG-27 | 422 | 422 | INVALID_PERIOD | INVALID_PERIOD | так |
| NEG-28 | 422 | 422 | INVALID_PERIOD | INVALID_PERIOD | так |
| NEG-29 | 422 | 422 | END_DATE_IN_FUTURE | END_DATE_IN_FUTURE | так |
| NEG-30 | 404 | 404 | NOT_FOUND | NOT_FOUND | так |
| NEG-31 | 404 | 404 | NO_CURRENT_SESSION | NO_CURRENT_SESSION | так |
| NEG-32 | 422 | 422 | VALIDATION_FAILED | VALIDATION_FAILED | так |
| NEG-33 | 422 | 422 | VALIDATION_FAILED | VALIDATION_FAILED | так |
| NEG-34 | 422 | 422 | VALIDATION_FAILED | VALIDATION_FAILED | так |

### 5.2. Відповіді на запити з порушенням схеми (NEG-32…34)

| ID | Фактичне порушення | Фактичний статус | Content-Type | Заголовок `sl-violations` (від Prism) | Тіло (структура `Error`) |
|---|---|---|---|---|---|
| NEG-32 | `targetDuration.hours: -1` (`minimum: 0`) | 422 | `application/json` | `code: minimum`, `location: request.body.targetDuration.hours`, «Request body property targetDuration.hours must be >= 0» | `code: VALIDATION_FAILED`, `details[0]`: `field: targetDuration`, `constraint: TOTAL_GREATER_THAN_ZERO` — перший приклад `validationFailed`, а не фактичне порушення |
| NEG-33 | немає `level` (`required`) | 422 | `application/json` | `code: required`, `location: request.body`, «Request body must have required property 'level'» | те саме тіло, що в NEG-32 — перший приклад `validationFailed` |
| NEG-34 | `parameters.sets: 0` (`minimum: 1`) | 422 | `application/json` | `code: minimum`, `location: request.body.parameters.sets`, «Request body property parameters.sets must be >= 1» | `code: VALIDATION_FAILED`, `details[0]`: `field: parameters.sets`, `constraint: MINIMUM` — єдиний приклад `zeroSets`, що випадково відповідає порушенню |

### 5.3. Підсумок

- **Позитивні сценарії: 36 із 36 збіглися.**
- **Негативні сценарії: 34 із 34 збіглися** за статусом і `code`.
- Тіла всіх 68 відповідей із тілом за JSON збігаються з відповідними прикладами `spec/openapi.yaml`. Відповіді POS-24 і POS-29 (`204`) тіла не мають, як і визначено контрактом.
- **Розбіжностей зі специфікацією не виявлено**, тому помилок у специфікації немає. Дві особливості mock (тіло на невалідний запит не описує порушення; без `example=` береться перший приклад) описано в розділі «Обмеження mock». Вони не впливають на збіг статусів і кодів.
