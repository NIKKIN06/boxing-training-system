# Простежуваність «REQ-ID → операції API» (ЛР-4, частина 2)

| Поле | Значення |
|---|---|
| Статус | **Чернетка** (не затверджено людиною) |
| Дата | 26.10.2026 |
| Підготував | Кодинговий агент (Claude Code, модель `claude-opus-5-5`) |
| Джерела | `spec/openapi.yaml` (розширення `x-req-ids`, `x-trace`); `spec/acceptance.feature` (теги BDD); `docs/api/resource-model.md`, розділ 1 |
| Спосіб побудови | Таблицю згенеровано скриптом з `spec/openapi.yaml` і `spec/acceptance.feature`, вручну не редагувалася |

## Правила заповнення

- **REQ-ID → operationId:** рядок для кожної операції, у `x-req-ids` якої є ця вимога. `x-req-ids` об'єднує REQ-ID з розділу 3.1 і розділу 4 `resource-model.md`.
- **AC:** критерій цієї вимоги, якщо він є в `x-trace.ac` операції; інакше «—».
- **BDD:** сценарії з `x-trace.bdd` операції, які в `spec/acceptance.feature` мають тег цієї вимоги; інакше «—». Попередні BDD-034…052 з ADD-001 і ADD-002 ще не внесено до `acceptance.feature`, тому вони тут не враховуються.
- **D-xx:** усі рішення з `x-trace.decisions` операції.

## Таблиця

| REQ-ID | operationId | Метод і URI | AC | BDD | D-xx |
|---|---|---|---|---|---|
| REQ-F-001 | `listExercises` | `GET /exercises` | — | BDD-001 | D-06, D-09, ADD-002 D-34 |
| REQ-F-002 | `createExercise` | `POST /exercises` | AC-F-002 | BDD-002, BDD-024 | D-05, D-07, D-08 |
| REQ-F-002 | `getExercise` | `GET /exercises/{exerciseId}` | — | BDD-024 | D-06, D-07 |
| REQ-F-002 | `updateExercise` | `PUT /exercises/{exerciseId}` | AC-F-002 | BDD-002, BDD-003 | D-05, D-08, ADD-002 D-33 |
| REQ-F-003 | `listExercises` | `GET /exercises` | AC-F-003 | BDD-004 | D-06, D-09, ADD-002 D-34 |
| REQ-F-003 | `getDictionary` | `GET /dictionaries/{dictionaryName}` | — | — | — |
| REQ-F-004 | `createExercise` | `POST /exercises` | AC-F-004 | BDD-024 | D-05, D-07, D-08 |
| REQ-F-004 | `getExercise` | `GET /exercises/{exerciseId}` | AC-F-004 | BDD-005, BDD-024 | D-06, D-07 |
| REQ-F-004 | `updateExercise` | `PUT /exercises/{exerciseId}` | — | — | D-05, D-08, ADD-002 D-33 |
| REQ-F-005 | `getDictionary` | `GET /dictionaries/{dictionaryName}` | — | — | — |
| REQ-F-005 | `generatePlan` | `POST /plan-generations` | AC-F-005 | BDD-006, BDD-007 | D-06, D-10, D-11, D-12, D-13, D-14, D-25, ADD-002 D-30, ADD-002 D-31, ADD-002 D-32 |
| REQ-F-006 | `generatePlan` | `POST /plan-generations` | AC-F-006 | BDD-007 | D-06, D-10, D-11, D-12, D-13, D-14, D-25, ADD-002 D-30, ADD-002 D-31, ADD-002 D-32 |
| REQ-F-007 | `generatePlan` | `POST /plan-generations` | AC-F-007 | — | D-06, D-10, D-11, D-12, D-13, D-14, D-25, ADD-002 D-30, ADD-002 D-31, ADD-002 D-32 |
| REQ-F-007 | `getOpenPlan` | `GET /open-plans/{openPlanId}` | AC-F-007 | — | ADD-002 D-30 |
| REQ-F-008 | `generatePlan` | `POST /plan-generations` | AC-F-008 | BDD-007, BDD-010, BDD-012 | D-06, D-10, D-11, D-12, D-13, D-14, D-25, ADD-002 D-30, ADD-002 D-31, ADD-002 D-32 |
| REQ-F-009 | `generatePlan` | `POST /plan-generations` | AC-F-009 | BDD-011, BDD-012 | D-06, D-10, D-11, D-12, D-13, D-14, D-25, ADD-002 D-30, ADD-002 D-31, ADD-002 D-32 |
| REQ-F-010 | `getOpenPlan` | `GET /open-plans/{openPlanId}` | AC-F-010 | — | ADD-002 D-30 |
| REQ-F-010 | `addOpenPlanItem` | `POST /open-plans/{openPlanId}/items` | AC-F-010 | BDD-013, BDD-032 | D-06, D-08, D-14, D-15, ADD-002 D-33 |
| REQ-F-010 | `replaceOpenPlanItem` | `PUT /open-plans/{openPlanId}/items/{itemId}` | AC-F-010 | — | D-06, D-08, D-15, ADD-002 D-33 |
| REQ-F-010 | `updateOpenPlanItem` | `PATCH /open-plans/{openPlanId}/items/{itemId}` | AC-F-010 | BDD-013, BDD-023, BDD-032 | D-08 |
| REQ-F-010 | `deleteOpenPlanItem` | `DELETE /open-plans/{openPlanId}/items/{itemId}` | AC-F-010 | BDD-033 | — |
| REQ-F-011 | `openSavedPlan` | `POST /open-plans` | AC-F-011 | BDD-015 | D-06, D-16, D-17, ADD-002 D-30 |
| REQ-F-011 | `renameOpenPlan` | `PATCH /open-plans/{openPlanId}` | — | — | D-16, ADD-002 D-32 |
| REQ-F-011 | `listTrainingPlans` | `GET /training-plans` | — | — | D-16 |
| REQ-F-011 | `saveNewTrainingPlan` | `POST /training-plans` | AC-F-011 | BDD-014, BDD-023, BDD-033 | D-14, D-16, ADD-002 D-32 |
| REQ-F-011 | `getTrainingPlan` | `GET /training-plans/{planId}` | AC-F-011 | BDD-015 | D-06, D-16 |
| REQ-F-011 | `overwriteTrainingPlan` | `PUT /training-plans/{planId}` | AC-F-011 | BDD-014, BDD-033 | D-16, ADD-002 D-32 |
| REQ-F-011 | `deleteTrainingPlan` | `DELETE /training-plans/{planId}` | — | — | D-16 |
| REQ-F-012 | `openSavedPlan` | `POST /open-plans` | — | — | D-06, D-16, D-17, ADD-002 D-30 |
| REQ-F-012 | `getCurrentSession` | `GET /current-session` | — | — | D-18 |
| REQ-F-012 | `startCurrentSession` | `POST /current-session` | AC-F-012 | BDD-016, BDD-025, BDD-026 | D-17, D-18 |
| REQ-F-013 | `abortCurrentSession` | `DELETE /current-session` | AC-F-013 | BDD-026, BDD-027, BDD-028 | — |
| REQ-F-013 | `updateExecutedPlanItem` | `PATCH /current-session/executed-plan/items/{itemId}` | AC-F-013 | BDD-016 | D-19 |
| REQ-F-013 | `deleteExecutedPlanItem` | `DELETE /current-session/executed-plan/items/{itemId}` | AC-F-013 | BDD-028 | D-19 |
| REQ-F-013 | `completeTraining` | `POST /completed-trainings` | AC-F-013 | BDD-016, BDD-028, BDD-029 | — |
| REQ-F-014 | `listCompletedTrainings` | `GET /completed-trainings` | AC-F-014 | BDD-020 | D-20 |
| REQ-F-014 | `getCompletedTraining` | `GET /completed-trainings/{trainingId}` | AC-F-014 | BDD-016, BDD-017 | D-06, D-20 |
| REQ-F-015 | `getAnalytics` | `GET /analytics` | AC-F-015 | BDD-018, BDD-030 | D-21, D-22, ADD-002 D-35 |
| REQ-F-016 | `getAnalytics` | `GET /analytics` | AC-F-016 | BDD-018, BDD-019, BDD-020, BDD-026 | D-21, D-22, ADD-002 D-35 |
| REQ-NF-001 | — | — | — | — | Операцій немає. Це вимога до середовища роботи, а не операція. API у MVP не розгортається як мережевий сервер; mock запускається лише локально (ADD-002 D-28) |
| REQ-NF-002 | `saveNewTrainingPlan` | `POST /training-plans` | — | — | D-14, D-16, ADD-002 D-32 |
| REQ-NF-002 | `completeTraining` | `POST /completed-trainings` | — | — | — |
| REQ-NF-003 | `saveNewTrainingPlan` | `POST /training-plans` | AC-NF-003 | — | D-14, D-16, ADD-002 D-32 |
| REQ-NF-003 | `overwriteTrainingPlan` | `PUT /training-plans/{planId}` | AC-NF-003 | — | D-16, ADD-002 D-32 |
| REQ-NF-003 | `completeTraining` | `POST /completed-trainings` | AC-NF-003 | BDD-021 | — |
| REQ-NF-004 | — | — | — | — | Операцій немає. Це заборона на передавання даних, а не операція. Тому API є проєктним контрактом і не розгортається як мережевий сервер (ADD-002 D-28). Відкриття посилань виконує клієнт |
| REQ-NF-005 | — | — | — | — | Операцій немає. Тексти інтерфейсу й локалізація належать клієнту. У контракті: API повертає машинні коди помилок і попереджень та назви полів, а не готові українські тексти; тексти D-13 зберігаються в мовному файлі клієнта |
| REQ-NF-006 | — | — | — | — | Операцій немає. Це вимога до процесу. У контракті: кожна операція має `x-req-ids` і `x-trace`; упроваджувані джерело випадковості й годинник (D-11) — внутрішня властивість генератора, а не параметри API |

REQ-NF-002 і REQ-NF-003 у розділі 1 моделі позначено як «ні» (власних операцій немає). Тут вони пов'язані з операціями, бо є властивостями їхніх записувальних відповідей (розділ 4 моделі).

## Підсумок

- Рядків у таблиці — 48: 44 пари «вимога — операція» і 4 вимоги без операцій (REQ-NF-001, REQ-NF-004, REQ-NF-005, REQ-NF-006).
- Усі 16 функціональних вимог мають щонайменше одну операцію.
