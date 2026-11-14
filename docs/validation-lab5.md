# Чек-лист валідації людиною — ЛР-5, API-частина (чернетка)

| Поле | Значення |
|---|---|
| Статус | Чернетка (draft); колонки «Фактичний результат», «Відповідає задуму», «Коментар» заповнює людина |
| Дата підготовки | 14.11.2026 |
| Еталон | SRS v1.2 (`spec/srs.md`), `spec/openapi.yaml` 1.1.0, ADD-003 |
| Обсяг | API-частина: 10 основних сценаріїв використання по черзі й оцінка потреби ADD-003. Екрани, тексти інтерфейсу, відкриття відео, Android — поза обсягом ЛР-5 |
| Підготував | Кодинговий агент (Claude Sonnet 5.5). Команди й очікувані результати агент перевірив на чистому сервері 14.11.2026 (тестовий каталог `test-1`); значення в колонці «Фактичний результат» не заповнено |

Валідація відповідає на питання «чи система робить те, що задумано», а не «чи код відповідає специфікації» (це верифікація, `logs/verification-lab5.md`). Тому в «Коментарі» варто писати, зручно й логічно це з погляду користувача, навіть якщо специфікація дотримана.

## 0. Підготовка

Каталог — тестовий (`src/assets/catalog/test-catalog.json`, версія `test-1`, назви з позначкою `[TEST]`, `placeholder: true`): початкові вправи `ex-1`, `ex-2`, `ex-3`, `ex-4`, `ex-6`, `ex-7`, `ex-8`; `ex-9` «[TEST] Застаріла вправа» застаріла й не показується (D-06). Реального каталогу в репозиторії немає, тож сценарії перевіряють поведінку, а не зміст тренувань.

**Запуск сервера** (термінал 1, з каталогу `src/`; база — файл у `.data/`, його ігнорує git):

```bash
cd src
rm -f .data/validation.sqlite .data/validation.sqlite-wal .data/validation.sqlite-shm
dart run bin/server.dart --db=.data/validation.sqlite --port=8080
```

У лозі має з'явитися `listening host=127.0.0.1 port=8080`. Сервер слухає лише `127.0.0.1`. Зупинка — Ctrl+C. Усі команди нижче — з іншого терміналу, з будь-якого каталогу. Лог застосунку пишеться в `logs/app/api-<дата>-<час>.log` (git його не відстежує).

**Як підставляти id із попередньої відповіді.** Відповіді сервера — JSON в один рядок. Знайдіть у відповіді поле, назване в кроці, скопіюйте значення й збережіть у змінну командою `export`, наприклад `export EX_ID=custom-19ffe…`. Наступні команди використовують змінні як `$EX_ID`. Якщо в терміналі встановлено `jq`, відповідь можна форматувати так: додайте `| jq .` в кінець будь-якої команди (за бажанням). Змінні живуть, доки відкрито термінал; якщо термінал закрито, збережені id треба взяти з відповідей `GET /training-plans`, `GET /completed-trainings`.

Українські значення в query передаються через `curl -G --data-urlencode`, у тілах — `-d '{…}'` (UTF-8). Базова адреса: `http://127.0.0.1:8080`.

```bash
export B=http://127.0.0.1:8080
export H='Content-Type: application/json'
```

Значення довідників (потрібні в тілах): етапи `warm-up`, `main`, `cool-down`; рівні `level-beginner`, `level-intermediate`, `level-advanced`; інтенсивності `intensity-low`, `intensity-medium`, `intensity-high`; акценти `emphasis-technique`, `emphasis-endurance`; обладнання `equipment-bag`, `equipment-rope`. Повний перелік: `curl -s $B/dictionaries/training-levels` (ще `intensities`, `emphases`, `equipment`, `execution-means`).

---

## Сценарій 1. Перегляд каталогу з фільтром

Вимоги: REQ-F-001, REQ-F-003; AC-F-003; BDD-004; операція `listExercises`.

```bash
# 1.1 Увесь каталог
curl -s $B/exercises
# 1.2 Розминка для початківців
curl -s -G $B/exercises --data-urlencode stage=warm-up --data-urlencode level=level-beginner
# 1.3 Основна частина для середнього рівня
curl -s -G $B/exercises --data-urlencode stage=main --data-urlencode level=level-intermediate
# 1.4 Комбінація з несумісних ознак (порожня вибірка)
curl -s -G $B/exercises --data-urlencode stage=cool-down --data-urlencode type=single-punch
# 1.5 Невідоме значення довідника
curl -s -w '\n%{http_code}\n' -G $B/exercises --data-urlencode level=level-unknown
```

| Крок | Очікуваний результат за специфікацією | Фактичний результат | Відповідає задуму (так/ні) | Коментар |
|---|---|---|---|---|
| 1.1 | `{"items":[…]}` із 7 вправ `ex-1`, `ex-2`, `ex-3`, `ex-4`, `ex-6`, `ex-7`, `ex-8`; кожна має `id`, `name`, `type`, `origin: "initial"`; застарілої `ex-9` немає | | | |
| 1.2 | Рівно `ex-1`, `ex-3`, `ex-8` (різні фільтри поєднуються через «І») | | | |
| 1.3 | Рівно `ex-6` («[TEST] Прямий удар») | | | |
| 1.4 | `{"items":[]}` зі статусом 200: порожня вибірка — не помилка | | | |
| 1.5 | Статус 422, `code: UNKNOWN_DICTIONARY_VALUE` | | | |

---

## Сценарій 2. Пошук вправи за частиною назви (потреба ADD-003)

Вимоги: REQ-F-003; ADD-003 D-36…D-39; AC-F-003; BDD-053; `listExercises`, параметр `nameContains`. Перед кроком 2.9 виконайте сценарій 3 (створення власної вправи); у цьому сценарії — лише початкові вправи.

```bash
# 2.1 Частина назви
curl -s -G $B/exercises --data-urlencode 'nameContains=удар'
# 2.2 Інший регістр
curl -s -G $B/exercises --data-urlencode 'nameContains=УДАР'
# 2.3 Пробіли на початку й у кінці
curl -s -G $B/exercises --data-urlencode 'nameContains=  удар  '
# 2.4 Пошук разом з фільтром (збіг є)
curl -s -G $B/exercises --data-urlencode 'nameContains=удар' --data-urlencode type=single-punch
# 2.5 Пошук разом з фільтром (збігу немає)
curl -s -G $B/exercises --data-urlencode 'nameContains=удар' --data-urlencode type=combination
# 2.6 Застаріла вправа
curl -s -G $B/exercises --data-urlencode 'nameContains=застаріла'
# 2.7 Назви, якої немає
curl -s -G $B/exercises --data-urlencode 'nameContains=аперкот'
# 2.8 Лише пробіли
curl -s -G $B/exercises --data-urlencode 'nameContains=   '
# 2.9 Власна вправа після сценарію 3 (назва «Стрибки на скакалці»)
curl -s -G $B/exercises --data-urlencode 'nameContains=стрибки'
```

| Крок | Очікуваний результат за специфікацією | Фактичний результат | Відповідає задуму (так/ні) | Коментар |
|---|---|---|---|---|
| 2.1 | Рівно `ex-6` «[TEST] Прямий удар» (D-36, D-37) | | | |
| 2.2 | Те саме, що 2.1: регістр не враховується (D-37) | | | |
| 2.3 | Те саме, що 2.1: пробіли на краях відкидаються (D-38) | | | |
| 2.4 | Рівно `ex-6` (пошук і фільтр за «І», D-39) | | | |
| 2.5 | `{"items":[]}`, статус 200 (D-39) | | | |
| 2.6 | `{"items":[]}`: застарілі вправи за пошуком не показуються (D-36, D-06) | | | |
| 2.7 | `{"items":[]}`, статус 200 | | | |
| 2.8 | Усі 7 незастарілих вправ: значення, порожнє після відкидання пробілів, вибірку не обмежує (D-38) | | | |
| 2.9 | Після сценарію 3: рівно одна власна вправа (`origin: "custom"`): пошук охоплює й власні вправи (D-36) | | | |

---

## Сценарій 3. Створення власної вправи

Вимоги: REQ-F-002, REQ-F-004; AC-F-002; BDD-002, BDD-024; операції `createExercise`, `getExercise`.

```bash
# 3.1 Створення (одна вправа за часом, один варіант)
curl -s -i -X POST $B/exercises -H "$H" -d '{"name":"Стрибки на скакалці","description":"Розминка зі скакалкою.","type":"simple","allowedStages":["warm-up"],"allowedLevels":["level-beginner"],"allowedIntensities":["intensity-medium"],"emphases":["emphasis-technique"],"loadCharacter":"general-physical","variants":[{"executionMeans":"means-apparatus","equipment":["equipment-rope"],"mode":"time","rounds":{"min":1,"max":5,"recommended":3},"intervalSeconds":{"min":60,"max":180,"recommended":120},"restSeconds":{"min":30,"max":90,"recommended":60}}]}'
# Збережіть: id вправи → EX_ID, variants[0].id → VAR_ID
export EX_ID=<id із відповіді>
export VAR_ID=<variants[0].id із відповіді>
# 3.2 Читання створеної вправи
curl -s $B/exercises/$EX_ID
# 3.3 Порожня назва
curl -s -w '\n%{http_code}\n' -X POST $B/exercises -H "$H" -d '{"name":"","description":"x","type":"simple","allowedStages":["warm-up"],"allowedLevels":["level-beginner"],"allowedIntensities":["intensity-medium"],"emphases":["emphasis-technique"],"loadCharacter":"general-physical","variants":[{"executionMeans":"means-apparatus","equipment":["equipment-rope"],"mode":"time","rounds":{"min":1,"max":5,"recommended":3},"intervalSeconds":{"min":60,"max":180,"recommended":120},"restSeconds":{"min":30,"max":90,"recommended":60}}]}'
```

| Крок | Очікуваний результат за специфікацією | Фактичний результат | Відповідає задуму (так/ні) | Коментар |
|---|---|---|---|---|
| 3.1 | Статус 201; заголовок `location: /exercises/custom-…`; у тілі `origin: "custom"`, нові `id` вправи (`custom-…`) і варіанта (`var-…`), `deprecated: false`, поля відео й автора `null` | | | |
| 3.2 | Статус 200, ті самі дані, що в 3.1 | | | |
| 3.3 | Статус 422, `code: VALIDATION_FAILED`, `details`: поле `name`, `constraint: MIN_LENGTH`; вправа не створюється | | | |
| 3.4 | Повторіть 2.9: власна вправа з'явилася в пошуку | | | |

---

## Сценарій 4. Формування плану на 1 годину

Вимоги: REQ-F-005…REQ-F-009; AC-F-005…AC-F-009; BDD-006, BDD-007; операція `generatePlan`.

```bash
# 4.1 Ціль 1 год 0 хв, початківець, акцент на техніку, обладнання — мішок, середня інтенсивність
curl -s -X POST $B/plan-generations -H "$H" -d '{"targetDuration":{"hours":1,"minutes":0},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
# Збережіть id відкритого плану:
export OPEN_ID=<id із відповіді>
# 4.2 Читання відкритого плану
curl -s $B/open-plans/$OPEN_ID
# 4.3 Ціль 0 год 0 хв
curl -s -w '\n%{http_code}\n' -X POST $B/plan-generations -H "$H" -d '{"targetDuration":{"hours":0,"minutes":0},"level":"level-beginner","emphasis":"emphasis-technique","availableEquipment":["equipment-bag"],"intensity":"intensity-medium"}'
```

| Крок | Очікуваний результат за специфікацією | Фактичний результат | Відповідає задуму (так/ні) | Коментар |
|---|---|---|---|---|
| 4.1 | Статус 201; `targetDurationSeconds: 3600`; `durationTolerance`: 3240…3960 с (±10 %); три етапи `warm-up`, `main`, `cool-down`, у кожному щонайменше один елемент; `estimatedDurationSeconds` у межах 3240…3960; `warnings: []`; `name: null`, `sourcePlanId: null`. Склад вправ і параметри щоразу різні (випадковий вибір), тому перевіряйте властивості, а не конкретні вправи. У цьому каталозі в усіх спробах агента вийшло 3240 с; якщо отримаєте 422 `PLAN_GENERATION_IMPOSSIBLE`, повторіть і запишіть у «Коментарі» | | | |
| 4.2 | Статус 200, той самий план, що в 4.1 | | | |
| 4.3 | Статус 422, `code: VALIDATION_FAILED` (загальна тривалість має бути більшою за 0), план не створюється | | | |

---

## Сценарій 5. Редагування елемента плану

Вимоги: REQ-F-010; AC-F-010; BDD-013, BDD-032; операції `addOpenPlanItem`, `updateOpenPlanItem`, `getOpenPlan`. Власна вправа зі сценарію 3 потребує канату, а в параметрах формування лише мішок, тож очікується попередження про невідповідність фільтру.

```bash
# 5.1 Додати власну вправу в розминку (2 раунди)
curl -s -i -X POST $B/open-plans/$OPEN_ID/items -H "$H" -d "{\"exerciseId\":\"$EX_ID\",\"variantId\":\"$VAR_ID\",\"stage\":\"warm-up\",\"parameters\":{\"rounds\":2,\"intervalSeconds\":120,\"restSeconds\":60}}"
# Збережіть id нового елемента (останній сегмент заголовка location, також поле id елемента в тілі):
export ITEM_ID=<id нового елемента>
# 5.2 Змінити число раундів на 4
curl -s -X PATCH $B/open-plans/$OPEN_ID/items/$ITEM_ID -H "$H" -d '{"parameters":{"rounds":4}}'
# 5.3 Значення поза межами варіанта (максимум 5)
curl -s -w '\n%{http_code}\n' -X PATCH $B/open-plans/$OPEN_ID/items/$ITEM_ID -H "$H" -d '{"parameters":{"rounds":9}}'
```

| Крок | Очікуваний результат за специфікацією | Фактичний результат | Відповідає задуму (так/ні) | Коментар |
|---|---|---|---|---|
| 5.1 | Статус 201, `location: /open-plans/<OPEN_ID>/items/item-…`; у тілі весь відкритий план: нова вправа останньою в `warm-up` (`position` на одиницю більше за попередню); `estimatedDurationSeconds` зріс на 300 с (2 × 120 + 1 × 60); у `warnings` є `FILTER_MISMATCH` для цього елемента, `attribute: availableEquipment` | | | |
| 5.2 | Статус 200; у елемента `parameters.rounds: 4`, його `estimatedDurationSeconds: 660` (4 × 120 + 3 × 60); загальний час зріс ще на 360 с; решта елементів без змін | | | |
| 5.3 | Статус 422, `VALIDATION_FAILED`, `details`: `parameters.rounds`, `constraint: WITHIN_VARIANT_RANGE`; план не змінився | | | |

---

## Сценарій 6. Збереження плану й повторне відкриття (зокрема після перезапуску)

Вимоги: REQ-F-011, REQ-NF-002; AC-F-011, AC-NF-002; BDD-014, BDD-015; операції `renameOpenPlan`, `saveNewTrainingPlan`, `listTrainingPlans`, `getTrainingPlan`, `openSavedPlan`.

```bash
# 6.1 Назвати відкритий план
curl -s -X PATCH $B/open-plans/$OPEN_ID -H "$H" -d '{"name":"Мій план на годину"}'
# 6.2 Зберегти як новий план
curl -s -w '\n%{http_code}\n' -X POST $B/training-plans -H "$H" -d "{\"openPlanId\":\"$OPEN_ID\"}"
export PLAN_ID=<id збереженого плану>
# 6.3 Перелік збережених планів і читання
curl -s $B/training-plans
curl -s $B/training-plans/$PLAN_ID
# 6.4 Повторно відкрити збережений план
curl -s -X POST $B/open-plans -H "$H" -d "{\"sourcePlanId\":\"$PLAN_ID\"}"
export OPEN2_ID=<id нового відкритого плану>
# 6.5 Перезапуск: у терміналі 1 натисніть Ctrl+C і запустіть сервер тією самою командою
#     (без rm — база має лишитися), потім:
curl -s $B/training-plans
curl -s $B/completed-trainings
curl -s -G $B/exercises --data-urlencode 'nameContains=стрибки'
curl -s -w '\n%{http_code}\n' $B/open-plans/$OPEN2_ID
curl -s -w '\n%{http_code}\n' $B/current-session
```

| Крок | Очікуваний результат за специфікацією | Фактичний результат | Відповідає задуму (так/ні) | Коментар |
|---|---|---|---|---|
| 6.1 | Статус 200, `name: "Мій план на годину"` | | | |
| 6.2 | Статус 201; у тілі `id` (`plan-…`), `modifiedAt`, `name: "Мій план на годину"`, п'ять параметрів формування в `generationParameters`, ті самі етапи й елементи в тому самому порядку, що в відкритому плані; в розминці є «Стрибки на скакалці» | | | |
| 6.3 | Перелік: один запис `id`, `name`, `modifiedAt`; читання: повний план, `estimatedDurationSeconds` такий самий, як після кроку 5.2 | | | |
| 6.4 | Статус 201; новий відкритий план з іншим `id`, `sourcePlanId: <PLAN_ID>`, `name: "Мій план на годину"`, ті самі елементи | | | |
| 6.5 | Після перезапуску: збережений план, власна вправа на місці з тими самими даними; історія порожня (тренувань ще немає); `GET /open-plans/<OPEN2_ID>` → 404 `NOT_FOUND` (відкриті плани не переживають перезапуск, D-18); `GET /current-session` → 404 `NO_CURRENT_SESSION`. Після перезапуску збережений план потрібно відкрити знову (крок 6.4) і оновити `OPEN2_ID` | | | |

---

## Сценарій 7. Початок заняття

Вимоги: REQ-F-012; AC-F-012; BDD-016, BDD-025; операції `startCurrentSession`, `getCurrentSession`.

```bash
# 7.1 Старт із відкритого плану (після перезапуску спершу повторіть крок 6.4)
curl -s -i -X POST $B/current-session -H "$H" -d "{\"openPlanId\":\"$OPEN2_ID\"}"
# Збережіть id «Стрибків на скакалці» з executedPlan (він збігається з ITEM_ID, якщо сервер не перезапускали):
export EXEC_ITEM_ID=<id елемента «Стрибки на скакалці» у executedPlan>
# 7.2 Поточне заняття
curl -s -w '\n%{http_code}\n' $B/current-session
# 7.3 Повторний старт під час заняття
curl -s -w '\n%{http_code}\n' -X POST $B/current-session -H "$H" -d "{\"openPlanId\":\"$OPEN2_ID\"}"
```

| Крок | Очікуваний результат за специфікацією | Фактичний результат | Відповідає задуму (так/ні) | Коментар |
|---|---|---|---|---|
| 7.1 | Статус 201, `location: /current-session`; `startedAt` — зараз (UTC, суфікс `Z`), `localStartDate` — сьогоднішня локальна дата; `executedPlan.stages` — копія плану з тими самими елементами | | | |
| 7.2 | Статус 200, ті самі `startedAt`, `localStartDate`, `executedPlan` | | | |
| 7.3 | Статус 409, `code: SESSION_ALREADY_ACTIVE`; поточне заняття не змінилось | | | |

---

## Сценарій 8. Завершення заняття з приміткою

Вимоги: REQ-F-013; AC-F-013, D-19; BDD-017, BDD-028; операції `updateExecutedPlanItem`, `completeTraining`.

```bash
# 8.1 Уточнити фактичне виконання: 6 раундів замість 4 (більше за максимум варіанта 5 — це допустимо, D-19)
curl -s -X PATCH $B/current-session/executed-plan/items/$EXEC_ITEM_ID -H "$H" -d '{"parameters":{"rounds":6}}'
# 8.2 Збережений план не змінився
curl -s $B/training-plans/$PLAN_ID
# 8.3 Нуль раундів
curl -s -w '\n%{http_code}\n' -X PATCH $B/current-session/executed-plan/items/$EXEC_ITEM_ID -H "$H" -d '{"parameters":{"rounds":0}}'
# 8.4 Завершити з приміткою
curl -s -w '\n%{http_code}\n' -X POST $B/completed-trainings -H "$H" -d '{"note":"Було важко, але зробив усе."}'
export TRAINING_ID=<id із відповіді>
# 8.5 Поточного заняття більше немає
curl -s -w '\n%{http_code}\n' $B/current-session
```

| Крок | Очікуваний результат за специфікацією | Фактичний результат | Відповідає задуму (так/ні) | Коментар |
|---|---|---|---|---|
| 8.1 | Статус 200; у `executedPlan` у цього елемента `rounds: 6`, інші значення без змін | | | |
| 8.2 | У збереженому плані в цього елемента лишається `rounds: 4` (виконаний план — незалежна копія) | | | |
| 8.3 | Статус 422, `VALIDATION_FAILED`; значення 6 лишилося | | | |
| 8.4 | Статус 201; у тілі `id` (`training-…`), `note: "Було важко, але зробив усе."`, `startedAt`, `localStartDate`, `executedPlan` з `rounds: 6` | | | |
| 8.5 | Статус 404, `NO_CURRENT_SESSION` | | | |

---

## Сценарій 9. Історія тренувань

Вимоги: REQ-F-014; AC-F-014; BDD-017, BDD-020; операції `listCompletedTrainings`, `getCompletedTraining`. Для перевірки порядку додайте друге заняття без примітки.

```bash
# 9.1 Друге заняття без примітки (той самий збережений план)
curl -s -X POST $B/open-plans -H "$H" -d "{\"sourcePlanId\":\"$PLAN_ID\"}"
export OPEN3_ID=<id із відповіді на попередню команду>
curl -s -o /dev/null -w '%{http_code}\n' -X POST $B/current-session -H "$H" -d "{\"openPlanId\":\"$OPEN3_ID\"}"
curl -s -w '\n%{http_code}\n' -X POST $B/completed-trainings
# 9.2 Перелік
curl -s $B/completed-trainings
# 9.3 Деталі першого заняття
curl -s $B/completed-trainings/$TRAINING_ID
```

| Крок | Очікуваний результат за специфікацією | Фактичний результат | Відповідає задуму (так/ні) | Коментар |
|---|---|---|---|---|
| 9.1 | Відкриття — 201; старт — 201; завершення без тіла — 201 з `note: null` | | | |
| 9.2 | `{"items":[…]}` із двох записів `id`, `startedAt`; новіше заняття першим | | | |
| 9.3 | Статус 200; повні дані: `note` «Було важко, але зробив усе.», `startedAt`, `localStartDate`, `executedPlan` з фактичним `rounds: 6`. Операцій редагування й видалення записів історії в контракті немає (REQ-F-014, D-20) | | | |

---

## Сценарій 10. Аналітика

Вимоги: REQ-F-015, REQ-F-016; AC-F-015, AC-F-016; BDD-018, BDD-030, BDD-048; операція `getAnalytics`.

```bash
# 10.1 Без періоду (сьогодні й 29 попередніх днів)
curl -s $B/analytics
# 10.2 Лише сьогодні
curl -s "$B/analytics?from=$(date +%F)&to=$(date +%F)"
# 10.3 Кінцева дата в майбутньому
curl -s -w '\n%{http_code}\n' "$B/analytics?from=$(date +%F)&to=2099-01-01"
# 10.4 Початок пізніше кінця
curl -s -w '\n%{http_code}\n' "$B/analytics?from=2026-11-10&to=2026-11-01"
# 10.5 Лише початкова дата
curl -s -w '\n%{http_code}\n' "$B/analytics?from=2026-11-01"
```

| Крок | Очікуваний результат за специфікацією | Фактичний результат | Відповідає задуму (так/ні) | Коментар |
|---|---|---|---|---|
| 10.1 | `period`: 30 днів, `to` — сьогодні; `completedTrainingCount: 2`; `dailyCounts` — 30 записів, дні без занять `count: 0`, сьогодні `count: 2`; `exerciseFrequencies`: кожна вправа з обох занять (`ex-1`, `ex-2`, `ex-4`, власна «Стрибки на скакалці», якщо план мав такий склад) з `trainingCount: 2` (вправа рахується один раз за заняття). Склад вправ залежить від випадкового вибору у сценарії 4 | | | |
| 10.2 | `period` з однією датою, `dailyCounts` з одним записом, `completedTrainingCount: 2` | | | |
| 10.3 | Статус 422, `END_DATE_IN_FUTURE` | | | |
| 10.4 | Статус 422, `INVALID_PERIOD` | | | |
| 10.5 | Статус 422, `INVALID_PERIOD` (період із однією датою не приймається) | | | |

---

## Оцінка потреби ADD-003 (пошук за частиною назви)

Це не перевірка відповідності, а оцінка людиною, чи потрібна зміна, внесена ADD-003 (SRS v1.2, REQ-F-003, D-36…D-40), після того як вона працює. Клієнтської частини (поле пошуку на екрані каталогу) в ЛР-5 немає (Q-ADD3-08); оцінюється поведінка API й задум.

| № | Питання для оцінки | Фактичний результат | Потрібно (так/ні) | Коментар |
|---|---|---|---|---|
| A-1 | Проблема ADD-003 (§1): користувач пам'ятає назву, але мусить переглядати весь каталог або підбирати ознаки. Чи в сценарії 2 пошук справді швидше веде до потрібної вправи, ніж фільтри зі сценарію 1? | | | |
| A-2 | Чи достатньо пошуку лише за назвою (опис виконання не враховується, D-36)? Чи не знадобиться пошук за описом чи автором? | | | |
| A-3 | Чи зрозуміла поведінка щодо регістру й пробілів (кроки 2.2, 2.3, 2.8)? Чи природно, що «прямий  удар» з двома пробілами не знаходить «Прямий удар» (D-37)? | | | |
| A-4 | Чи зручне поєднання пошуку з фільтрами за «І» (кроки 2.4, 2.5) і порожня вибірка без помилки (D-39)? | | | |
| A-5 | Чи потрібен пошук серед власних вправ (крок 2.9, 3.4) і чи природно, що застарілі вправи не знаходяться (крок 2.6)? | | | |
| A-6 | Чи потрібно доповнити поведінку (наприклад, пошук без урахування апострофів, сортування за релевантністю, обмеження довжини), або поточна достатня? Що з відкладеного (повторений параметр, апострофи й NFC / NFD, `İ`) має значення для користувача? | | | |
| A-7 | Підсумок: чи виправдана зміна ADD-003 з погляду потреби користувача? | | | |

**Висновок людини за валідацією** (заповнює людина): ______________________________

## Після виконання

- Зупиніть сервер (Ctrl+C). Файл бази `src/.data/validation.sqlite` можна видалити — git його не відстежує.
- Рядки, де «Відповідає задуму» = ні, потребують рішення людини: це або недолік реалізації, або вимога до специфікації. Агент не вирішує GO / REVISE і не змінює `spec/` без вказівки.
- Невідповідності специфікації й коду — у `logs/verification-lab5.md` (V-001…V-004); відкладені питання — там само, розділ 6.
