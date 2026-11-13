# Журнал взаємодії з кодинговим агентом — ЛР-5

## Етап 1. Аналіз вхідних артефактів — 12.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Лише аналіз, нічого не змінювати й не комітити:
   - перевірити вхідні артефакти ЛР-5 (SRS, AC, BDD, OpenAPI і GO на API-GATE, POS/NEG-сценарії, матриця, тікети, план, ризики);
   - визначити, що з ADD-001 і ADD-002 не внесено в spec/ (T-58, API-REV-008);
   - класифікувати тікети T-58, T-59, T-10, T-11–T-29, T-30–T-48, T-61, T-62, T-65 за стосунком до REST API з operationId;
   - запропонувати стек, структуру /src і /tests, компоненти, спосіб «червоних» тестів без помилок компіляції та контрактні перевірки з урахуванням Prism 5.16.0 і docs/api/scenarios.md;
   - перевірити доступність `dart` і мережі для `dart pub get`.

**Пропозиція агента та дії:**
- Вхідні артефакти знайдено:
  - spec/srs.md — v1.0, ADD-001 і ADD-002 не внесено;
  - spec/acceptance.feature — 33 сценарії;
  - spec/openapi.yaml — 27 operationId;
  - logs/api-gate.md — GO 26.10.2026;
  - docs/api/scenarios.md — 36 POS і 34 NEG, статус «Чернетка»;
  - spec/traceability.md — без рядків CON;
  - docs/plan/decomposition.md і docs/plan/risks.md — затверджено;
  - docs/plan/plan.md — статус «draft», хоча PLAN-GATE дав GO;
  - logs/test-gate.md — відсутній.
- Невнесені зміни адендумів порахував скриптом за розділами 3 обох адендумів:
  - SRS — 31 + 14 пунктів;
  - AC — 17 + 5;
  - змінити 3 + 3 BDD, додати 17 + 2 BDD;
  - матриця — 8 рядків CON.
  - У плані на T-58 закладено 2 год агента і 1,5 год людини. Оцінка агента — 4–6 год (судження, не розрахунок).
- Тікети розподілено на (а) REST API, (б) лише Flutter/Android і (в) частково. Скрипт перевірив, що всі 27 операцій покриті Feature-тікетами (а) і (в).
- Агент запропонував:
  - стек: Dart 3.14.0, shelf 1.4.3, shelf_router 1.1.5, drift 2.35.3, drift_dev 2.35.2, build_runner 2.17.1, sqlite3 3.8.0, test 1.33.0, logging 1.3.0, yaml 3.1.4, json_schema 5.2.2, http 1.6.0;
  - окремі пакети в src/ і tests/;
  - каркас із `UnimplementedError` перед тестами;
  - валідатор відповідей за spec/openapi.yaml у тестах і Prism 5.16.0 у режимі proxy як другу лінію перевірки.
- Перевірка середовища:
  - `dart` і `flutter` не встановлено;
  - pub.dev і архів Dart SDK доступні (HTTP 200);
  - npm-реєстр недоступний (curl 35, Broken pipe).
- Агент сформулював 7 питань до специфікації та два блокери процесу: T-58, T-59 і T-29 відкриті; частина документів має статус «Чернетка».
- Файлів не змінено, комітів не створено.

**Повний діалог:** не збережено агентом
**Рішення людини (12.11.2026):**
- Обсяг ЛР-5: лише REST API за spec/openapi.yaml — тікети (а) і API-частини тікетів (в). Тікети (б) і клієнтські частини (в) у ЛР-5 не виконуються й лишаються відкритими. T-29 TEST-GATE і T-65 IMPL-GATE у ЛР-5 охоплюють лише API-тести й API-реалізацію.
- Порядок: T-58 → T-59 → T-57 (дані [TEST]) → T-10 (каркас API) → тести → T-29 → реалізація.
- Відповіді на питання:
  1. D-28: ADD-003 не потрібен. API запускається лише на 127.0.0.1 для розробки, тестів і валідації, як mock у ЛР-4. Він не розгортається й не входить в Android-збірку.
  2. CON-001: стек клієнта не змінюється. Dart і Drift — за CON-001. shelf, shelf_router, test, logging, yaml, json_schema і http — допоміжні засоби API-шару й тестів. Адендум не потрібен.
  3. Логування обов'язкове за умовою ЛР-5:
     - кожен запит — метод, operationId, статус, тривалість;
     - ключові операції сервісів — ID сутностей і результат;
     - помилки валідації — `code`, рівень WARNING;
     - винятки — рівень ERROR зі стеком;
     - вміст полів користувача (назви, примітки) не логується;
     - файли пишуться лише локально в logs/app/ (REQ-NF-004).
  4. Перезапуск застосунку = перезапуск процесу сервера. Незбережені відкриті плани й поточне заняття зберігаються лише в пам'яті.
  5. Годинник, джерело випадковості й генератор ID підставляються лише в composition root. Тестових ендпоінтів і заголовків не додавати.
  6. Каталог для ЛР-5 — плейсхолдери [TEST] за T-57 (D-27).
  7. `details[].code` — лише коди з контракту. Якщо для порушення коду немає, агент зупиняється й повідомляє людину; контракт не змінюється.
- Стек — як запропонував агент. Dart SDK людина встановлює самостійно.

## Етап 2. T-58: внесення ADD-001 і ADD-002 у специфікацію (SRS v1.1) — 12.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Пряма вказівка змінити spec/: внести затверджені ADD-001 (D-01…D-27) і ADD-002 (D-28…D-35) у spec/srs.md, spec/acceptance.feature і spec/traceability.md строго за розділами 3 обох адендумів:
   - SRS — версія 1.1 із записом в історії версій;
   - AC — за розділами 3.2;
   - BDD — змінити наявні й додати BDD-034…052 з остаточними ID;
   - матриця — за розділами 3.5 і рядки CON-001…CON-008;
   - у шапках ADD-001 і ADD-002 зазначити внесення.
   Нічого поза адендумами не додавати; неоднозначне — у список питань.
2. Перевірити скриптом відображення D-01…D-35, унікальність ID, відповідність BDD у матриці й feature, збіг ID BDD у docs/plan/decomposition.md. Показати `git diff --stat`, не комітити.

**Пропозиція агента та дії:**
- spec/srs.md:
  - версія 1.1, новий статус, рядок «Адендуми» і розділ «Історія версій» (v1.0 — 28.09.2026, коміт `533ee59`; v1.1 — 12.11.2026);
  - внесено всі пункти таблиць 3.1 і 3.2 обох адендумів; біля кожного внесеного положення стоїть позначка `(D-xx)`;
  - новий підрозділ «План тренування» отримав номер §4.3.6, щоб не змінювати номери §4.3.4 і §4.3.5, на які посилається spec/openapi.yaml;
  - нові пункти AC дописано в кінець списків, щоб зберегти нумерацію пунктів, на яку посилаються тікети (наприклад, AC-F-004 пп. 5–10, AC-NF-004 пп. 2–3);
  - пункти, які адендуми просять змінити на місці, змінено на місці: AC-F-001 п. 3, AC-F-004 пп. 1–2, AC-NF-004 п. 1, AC-NF-005 п. 9.
- spec/acceptance.feature:
  - змінено BDD-011, 015, 017 (ADD-001, 3.3) і BDD-030 (ADD-002, 3.3);
  - додано BDD-034…052 з остаточними ID; у BDD-037 і BDD-042 враховано уточнення ADD-002 (D-34, D-32).
- spec/traceability.md:
  - версія 1.1;
  - для змінених вимог оновлено колонки «Критерій» (позначки D-xx), «BDD» і «Додатковий спосіб перевірки»;
  - BDD-051 додано до REQ-F-011 і REQ-NF-002, BDD-052 — до REQ-F-002, BDD-050 — до REQ-NF-004;
  - додано рядки CON-001…CON-008 і оновлено «Межі поточної матриці»;
  - колонку «Тікет» не змінено.
- У шапках ADD-001 і ADD-002 зазначено внесення в SRS v1.1 від 12.11.2026.
- Скрипт перевірки (Python, поза репозиторієм):
  - D-01…D-35: відсутніх 0. Усі рішення є в srs.md і traceability.md; у feature посилань на D-xx немає за конвенцією тегів;
  - дублікатів ID немає: REQ — 22, AC — 22, BDD — 52 (неперервно 001…052; сценаріїв 52);
  - рядків CON — 8;
  - BDD у матриці й у feature збігаються в обидва боки; теги REQ кожного сценарію збігаються з рядками матриці;
  - docs/plan/decomposition.md: усі згадані там BDD є у feature; BDD-051 і BDD-052 у decomposition не згадано; позначок «попер.» немає; пари «D-xx (BDD-…)» збігаються з таблицями 3.4 адендумів.
- `git diff --stat`: 5 файлів, +494 / −63 (acceptance.feature 196, ADD-001 2, ADD-002 2, srs.md 305, traceability.md 52).
- docs/plan/decomposition.md, spec/openapi.yaml і docs/api/ не змінено; комітів не створено.

**Питання до специфікації (передано людині):**
1. Статус у шапці SRS — «Редакція 1.1 із внесеними адендумами ADD-001 і ADD-002; очікує SPEC-GATE v1.1 (T-59)»: чи прийнятне формулювання?
2. ADD-002 3.1, §2.3/§4.2 і §10 — «за потреби»: примітку D-28 додано в §4.2 і §10.3, у §2.3 — ні.
3. ADD-001 3.1, §4.3 — «фільтри, D, режим»: застосовано уточнення D-31 (п'ять параметрів REQ-F-005, без «режиму»).
4. §5.2 — речення «Збільшення обсягу здійснюється…» залишено без змін, хоча §5.7 перейменовано на «Коригування обсягу»: §5.2 у таблиці 3.1 для цього не вказано.
5. BDD-036 (D-07) — «автор» трактовано як ім'я й посилання на сторінку разом; випадок «ім'я без посилання на сторінку» адендумом не визначено.
6. Тестові дані в нових BDD (рівні «початковий», «середній»; назви вправ; URL на `example.com` і `youtube.com`; дати) — приклади, а не значення довідників чи навантаження (CON-005).
7. Рядки CON у матриці — у «Додатковому способі перевірки» вказано «Інспекція: <обмеження>»; метод перевірки адендуми не визначають.
8. Поза обсягом T-58:
   - тікети в docs/plan/decomposition.md не посилаються на BDD-051 і BDD-052 (умова GO T-59);
   - spec/openapi.yaml (`info.description`, `x-trace`) і docs/api/req-api-traceability.md посилаються на SRS v1.0 і не містять BDD-034…052 (API-REV-008).

**Повний діалог:** не збережено агентом
**Рішення людини (12.11.2026):**
1. Формулювання статусу SRS прийнято.
2. Примітка D-28 — лише в §4.2 і §10.3, як є.
3. Застосування D-31 замість «режиму» з ADD-001 — правильно.
4. «Збільшення обсягу» в §5.2 не змінювати: це загальне твердження, не посилання на §5.7.
5. BDD-036 залишити як є: випадок «ім'я без посилання» покривається другим реченням D-07.
6. Тестові значення в BDD — ілюстративні приклади, прийнято.
7. «Інспекція: <обмеження>» для рядків CON прийнято.

Поза обсягом T-58:
- BDD-051 і BDD-052: агент пропонує тікети в docs/plan/decomposition.md за REQ-ID з таблиці 3.4 ADD-002. Після погодження людиною зміни вносяться в docs/plan/decomposition.md і в тіла відповідних issues (`gh issue edit`); номери issues беруться лише з виводу `gh`.
- spec/openapi.yaml і docs/api/req-api-traceability.md не змінюються: контракт затверджено на API-GATE, `x-trace` — метадані. Простежуваність «тест → код» зводиться в spec/traceability.md на кроці 8 ЛР-5.

## Етап 3. BDD-051 і BDD-052 у тікетах і issues — 12.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Запропонувати тікети docs/plan/decomposition.md для BDD-051 і BDD-052 за REQ-ID з таблиці 3.4 ADD-002.
2. Після погодження внести зміни в docs/plan/decomposition.md і в тіла issues (`gh issue edit`); номери issues брати лише з виводу `gh`.

**Пропозиція агента та дії:**
- Кандидатів знайдено пошуком REQ-F-002, REQ-F-011 і REQ-NF-002 у decomposition.md. Номери issues взято з виводу `gh issue list --state all --limit 200 --json number,title`.
- Запропоновано:
  - BDD-051 (D-30) → T-23 (#24) і T-42 (#43);
  - BDD-052 (D-33) → T-11 (#12) і T-30 (#31).
- Не запропоновано:
  - T-12 і T-31 — вони про відновлення збережених даних, а не про відсутність незбереженого плану;
  - T-07, T-28, T-50, T-67 — документація, `integration_test` і верифікація;
  - T-16, T-35, T-43, T-61 — тікети клієнта (б).
- Шапка decomposition.md має статус «Затверджено людиною 17.10.2026» (RISK-22).
- docs/plan/decomposition.md: у колонку джерел рядків T-11, T-30 дописано `; ADD-002 D-33 (BDD-052)`, рядків T-23, T-42 — `; ADD-002 D-30 (BDD-051)`. `git diff --stat`: 1 файл, +4 / −4.
- Тіла issues вивантажено (`gh issue view <n> --json body --jq .body`) і відредаговано в копіях поза репозиторієм. Diff кожного тіла — один рядок розділу «Джерело» — показано людині, після чого виконано `gh issue edit <n> --body-file`. Оновлено #12, #24, #31, #43.
- Перевірка після оновлення:
  - повторне `gh issue view` дав той самий текст, що й надісланий; відрізняється лише кінцевий перенос рядка, який додає `--jq`;
  - `gh issue list --state all --search "BDD-051 OR BDD-052 in:body"` повертає саме #24, #43, #12, #31.
- Назви, критерії готовності, залежності й мітки issues не змінено. Комітів не створено.

**Повний діалог:** не збережено агентом
**Рішення людини:** Розподіл BDD-051 → T-23 (#24), T-42 (#43); BDD-052 → T-11 (#12), T-30 (#31) погоджено 12.11.2026.

## Етап 4. T-59: незалежна перевірка для SPEC-GATE v1.1 — 12.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code; нова сесія без контексту етапів 1–3
**Запити:**
1. Незалежна перевірка для T-59 SPEC-GATE v1.1, spec/ не змінювати. Прочитати spec/srs.md (v1.1), spec/acceptance.feature, spec/traceability.md, ADD-001, ADD-002 і умову GO T-59 у docs/plan/plan.md, розділ 1.1.
2. Для кожної умови GO дати результат і доказ; підрахунки й звірки виконати скриптом.
3. Окремо перелічити суперечності, невизначені терміни, неперевірювані формулювання та вимоги без критерію прийняття.
4. Додати в logs/spec-gate.md розділ «SPEC-GATE v1.1» як чернетку за структурою v1.0: з фактичною датою, відхиленням від plan.md §6.4 і порожнім «Остаточним рішенням». Запис v1.0 не змінювати.
5. Додати етап у цей журнал. Запит назвав його «етап 3», але етап 3 уже зайнятий, тому запис має номер 4.

**Пропозиція агента та дії:**
- Скрипт `spec_gate_v11_check.py` (Python, поза репозиторієм, лише читання):
  - D-01…D-27 — 0 відсутніх у srs.md і traceability.md; за рядками ADD-001 §3.1/§3.2 — 0 розбіжностей; для ADD-002 так само 0;
  - версія SRS 1.1, історія версій 1.0 / 1.1;
  - REQ 22, AC 22, BDD 52 без дублікатів і пропусків; §10.1 (16 / 6 / 22 / 8) збігається з фактом;
  - BDD у матриці й у feature збігаються в обидва боки; теги нових BDD-034…052 збігаються з §3.4 адендумів;
  - тексти повідомлень D-13 дослівно однакові в SRS §5.7, BDD-011 і BDD-040;
  - ADD-001 §4: 13 Q, усі з відповіддю, «Відкритих питань немає»;
  - CON-001…CON-008 — 8 рядків у матриці;
  - decomposition.md: 52 BDD у 68 тікетах; немає BDD поза feature і немає BDD без тікета;
  - `gh issue list --state all --limit 200 --json number,title,body` → 68 issues; розбіжність BDD лише одна: T-05 ↔ #6.
- Дві хибні тривоги скрипта перевірено вручну: «попер.» — це збіги зі словом «попередження»; рядки CON не збіглися через регістр першої літери, а за змістом відповідають §9.
- Відхилення від plan.md §6.4: T-59 заплановано на 27.10.2026, перевірка — 12.11.2026, тобто +16 днів (скрипт).
- logs/spec-gate.md: доданий розділ «SPEC-GATE v1.1» (чернетка) містить:
  - таблицю 7 умов GO з доказами;
  - зауваження REV-004…REV-013;
  - 5 питань до специфікації;
  - залежності наступного етапу;
  - порожнє «Остаточне рішення».
- Блокувальних зауважень агент не виявив. Найсуттєвіше зауваження — REV-004: правило «не застосовна» за однозначного характеру навантаження (D-34) надлишкове або дає порожній фільтр, а BDD-037 його не перевіряє.
- spec/, docs/plan/ та issues не змінено.
- Після першого рішення людини агент перевірив кожне питання до специфікації на вплив на API, звіривши його з spec/openapi.yaml:
  - REV-010 і REV-006 не впливають;
  - REV-009 впливає: тлумачення `modifiedAt` визначає порядок `listTrainingPlans` (spec/openapi.yaml:596), а ні SRS, ні контракт не кажуть, коли поле встановлюється.
- Агент зупинився до редагування й коміту та запропонував тлумачення А.
- Після другого рішення внесено статуси й вирішення REV-004…REV-013 і таблицю питань з колонкою «Впливає на API?». «Остаточне рішення» лишилося порожнім.

**Повний діалог:** не збережено агентом
**Рішення людини (12.11.2026):**
1. ADD-002 входить в обсяг SPEC-GATE v1.1: T-58 вносив обидва адендуми; умова GO згадує лише ADD-001, бо план складено до ADD-002.
2. REV-004: D-09 застосовується буквально; фільтр `not-applicable` повертає 200 і порожній список; специфікація не змінюється.
3. REV-009 (тлумачення А): `modifiedAt` збереженого плану встановлюється в момент успішного `saveNewTrainingPlan` або `overwriteTrainingPlan`. `renameOpenPlan` та інші зміни відкритого плану його не змінюють (D-30, D-32). Порядок для однакового `modifiedAt` не визначається й не перевіряється. Статус: «Закрито тлумаченням людини».
4. REV-005…REV-008, REV-010…REV-013 — неблокувальні, «Відкладено»; v1.1 не змінюється.
5. Нумерацію «етап 4» прийнято.
6. Коміт `docs: [agent] add SPEC-GATE v1.1 review draft` — після показу `git diff --cached`.

## Етап 5. T-57 (обсяг API ЛР-5): склад довідників і каталогу [TEST] — 13.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. За SRS v1.1 §4.4 і перелічуваннями spec/openapi.yaml запропонувати склад спільних довідників і плейсхолдер-каталогу [TEST] (D-01, D-26, D-27, CON-005). Каталог має бути мінімально достатнім для BDD про каталог, фільтрацію, формування й редагування плану. Показати таблицею й чекати погодження до створення файлів.

**Пропозиція агента та дії:**
- ID значень довідників і вправи ex-1…ex-4, ex-9 взято з `components/examples` spec/openapi.yaml, які пройшли API-GATE. Межі нових вправ ex-6…ex-8 скопійовано з наборів меж цих прикладів (Shadow, Bag, Rope). Нових значень навантаження агент не вводив (CON-005).
- Довідники:
  - training-levels — level-beginner, level-intermediate, level-advanced (нове);
  - intensities — intensity-low, -medium, -high;
  - emphases — emphasis-technique, emphasis-endurance;
  - equipment — equipment-bag, equipment-rope, equipment-pads (нове);
  - execution-means — means-no-equipment, means-apparatus, means-pads (нове), means-pairs (нове).
- Каталог:
  - 7 незастарілих початкових вправ — ex-1, ex-2, ex-3, ex-4, ex-6, ex-7, ex-8;
  - застаріла ex-9;
  - ID ex-5 не використано, бо в контракті він належить прикладу власної вправи.
- Покриття:
  - BDD-004 — ex-6: два варіанти, лапи без мішка і мішок без лап;
  - BDD-037 — A = ex-3 (ЗФП), B = ex-6 (СФП), C = ex-4 (не застосовна); ex-3 — єдина ЗФП-вправа;
  - BDD-032 — ex-1, не більше 5 раундів;
  - BDD-023 — ex-2, лише main;
  - BDD-034 — будь-яка початкова вправа;
  - D-06 — ex-9.
- Скрипт `catalog_check.py` (Python, поза репозиторієм) порахував тривалості варіантів за SRS §5.4 і кандидатів за §5.1:
  - для параметрів beg / med / technique / [bag] є кандидати на всіх трьох етапах, ціль 3600 с досяжна;
  - для beg / high / technique / [bag] кандидатів для заминки немає (BDD-011).
- Для BDD-007, 012, 035, 038, 039, 040 базового каталогу недостатньо. Агент запропонував окремі каталоги-фікстури.
- Примітка щодо D-26 і D-28: правило D-26 «релізна збірка не містить вправ [TEST]» на API ЛР-5 не поширюється. За D-28 API запускається лише локально (127.0.0.1) для розробки, тестів і валідації та не входить у релізну Android-збірку. Каталог [TEST] — ресурс постачання API, а не релізний контент.
- Файлів на цьому етапі не створено.

**Повний діалог:** не збережено агентом
**Рішення людини (12.11.2026):**
1. Нові значення level-advanced, equipment-pads, means-pads, means-pairs і вправи ex-6…ex-8 погоджено.
2. Назви вправ — як у прикладах контракту, з префіксом [TEST].
3. ID власних вправ — префікс `custom-`. Генератор підставляється в composition root, без додаткових пакетів.
4. Окремі каталоги-фікстури для BDD-007, 012, 035, 038, 039, 040 погоджено: tests/fixtures/catalogs/, шлях передається через параметр composition root, файли створюються на кроці тестів.
5. Засівання каталогу за D-06 — це бізнес-логіка T-32 (BDD-001, BDD-031), її перевіряють тести, тому в T-10 вона не реалізується. У T-10 — лише файл src/assets/catalog/test-catalog.json і шлях до нього в конфігурації composition root.
6. Примітку щодо D-26 і D-28 записати в журнал (зроблено вище).

## Етап 6. T-10 (API-частина): каркас проєкту із заглушками й логуванням — 13.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Створити каркас API за структурою з етапу 1:
   - Dart-пакет у src/, тестовий пакет у tests/; точні версії, pubspec.lock комітиться (CON-003);
   - Drift-схема і згенерований код;
   - компоненти domain / ports / application / data / http;
   - 27 маршрутів за operationId; сервіси — лише сигнатури з `UnimplementedError` → 501;
   - логування за рішенням 3 етапу 1, файли в logs/app/;
   - bin/server.dart лише на 127.0.0.1, порт конфігурується, за замовчуванням не 4010;
   - дані [TEST] як ресурс постачання.
   Бізнес-логіки не писати.
2. Готовність: `dart analyze --fatal-infos` без зауважень; димовий тест (обробник створюється, кожен із 27 маршрутів повертає 501, у лог-файлі є записи старту й запиту); аналіз логу після запуску з фрагментом.
3. Запропонувати, чи комітити logs/app/.

**Пропозиція агента та дії:**
- Середовище: Dart SDK 3.14.0 (stable), встановлено людиною. `dart pub get` розв'язав точні версії етапу 1 в обох пакетах. pubspec.lock створено в src/ і tests/.
- src/ (пакет `boxing_api`):
  - `domain/` — перелічування контракту з wire-значеннями (зокрема 22 коди `Error.code`) і незмінні класи даних за схемами spec/openapi.yaml; `DomainError`. Логіки немає.
  - `ports/` — `Clock`, `RandomSource`, `IdGenerator`; порти сховищ (`ExerciseRepository`, `TrainingPlanRepository`, `CompletedTrainingRepository`, `CatalogSource`, `OpenPlanStore`, `CurrentSessionStore`).
  - `application/` — 7 сервісів з методом на кожен operationId; усі методи кидають `UnimplementedError`.
  - `data/`:
    - Drift-схема `database.dart` з таблицями `exercises`, `catalog_meta`, `training_plans`, `completed_trainings`; вкладені структури зберігаються JSON-копіями (SRS §4.5); дата-час зберігається текстом (build.yaml);
    - `database.g.dart` згенеровано командою `dart run build_runner build`;
    - репозиторії, сховища в пам'яті та `JsonFileCatalogSource` — заглушки;
    - системні реалізації портів: `SystemClock`, `SystemRandomSource`, `RandomIdGenerator` (`<префікс>-<32 hex>`, для власних вправ — `custom-`, без додаткових пакетів).
  - `http/`:
    - `routes.dart` — 27 маршрутів shelf_router, по одному на operationId;
    - `json_mapping.dart` — `RequestDecoder` / `ResponseEncoder`, заглушки;
    - `middleware.dart` — обгортка операції (`UnimplementedError` → 501 без тіла, WARNING; інший виняток → 500 без тіла, ERROR зі стеком) і журнал запитів (INFO: метод, operationId, статус, тривалість).
  - `config/app_config.dart`:
    - хост фіксований 127.0.0.1;
    - параметри `--port` (за замовчуванням 8080), `--db` (`:memory:` або файл, за замовчуванням `.data/boxing_api.sqlite`, ігнорується git), `--catalog`, `--log-dir` (за замовчуванням `../logs/app`), `--log-file`.
  - `logging/app_logging.dart` — синхронний запис у файл і stdout; рівні INFO / WARNING / ERROR. Рядки запитів і тіла не логуються.
  - `composition_root.dart` — `buildApp(config, {clock, random, ids})`: єдине місце підстановки годинника, випадковості, генератора ID і шляху до каталогу.
  - `bin/server.dart` — запуск, зупинка за SIGINT / SIGTERM.
  - `assets/catalog/test-catalog.json` — дані T-57 за рішенням людини етапу 5 (5 довідників, 8 вправ, `catalogVersion: test-1`, `placeholder: true`). Засівання за D-06 не реалізовано (T-32).
- tests/ (пакет `boxing_api_tests`): `test/skeleton/skeleton_smoke_test.dart` — перевірка готовності T-10, не тест TEST-GATE.
  - Перелік операцій, методи, шляхи й наявність `requestBody` тест читає з spec/openapi.yaml.
  - Перевіряє: 27 операцій збігаються з маршрутами каркаса; кожна повертає 501 з порожнім тілом; у лог-файлі є запис старту й по запису запиту та заглушки на кожну операцію.
  - Після реалізації операцій цей тест замінюється.
- `.gitignore` у src/ і tests/ (`.dart_tool/`, `.data/`), бо агент не комітить файли поза src/, tests/, logs/app/. logs/app/.gitignore ігнорує `*.log`, крім `control-*.log`.
- Перевірки:
  - `dart analyze --fatal-infos` у src/ і tests/ — «No issues found!» (першу помилку `undefined_class QueryExecutor` виправлено імпортом);
  - `dart test` у tests/ — 29 з 29 пройдено (+29: All tests passed!).
- Контрольний запуск: `dart run bin/server.dart --log-file=control-T-10-20261113.log --db=:memory:`, 5 запитів curl, зупинка SIGINT, код виходу 0. Лог — logs/app/control-T-10-20261113.log.
- Аналіз логу:
  - Старт: `starting`, `app composed operations=27 database=memory catalog=…`, `listening host=127.0.0.1 port=8080`. `lsof` підтвердив прослуховування лише 127.0.0.1:8080.
  - На кожен запит записано пару: WARNING `not implemented` з місцем зупинки (декодер або сервіс) і INFO з методом, operationId, статусом і тривалістю (0–5 мс). Значення фільтра `level=level-beginner` і тіло POST у лог не потрапили.
  - Перший запит `getAnalytics` — це опитування готовності з циклу curl.
  - Неіснуючий маршрут дав 404 і `operationId=-`. Тіло цієї відповіді — текст shelf_router «Route not found», а не модель `Error`; контракт таких маршрутів не описує.
  - ERROR-записів немає; зупинка записана (`stopping signal=SIGINT`, `stopped`).
- Пропозиція щодо logs/app/: комітити лише логи контрольних запусків (`control-<T-ID>-<дата>.log`) як доказ; решта логів лишається локально (REQ-NF-004).

**Питання до специфікації (передано людині):**
1. Статус 501 і порожнє тіло заглушок відсутні в spec/openapi.yaml. Це тимчасовий стан каркаса, який зникає з реалізацією; Prism proxy позначатиме його як невідповідність.
2. Для неіснуючих маршрутів контракт не визначає відповіді (зараз 404 з текстовим тілом shelf_router).
3. Записи заглушок мають рівень WARNING без стеку. Рішення 3 вимагає ERROR зі стеком для винятків, але `UnimplementedError` — очікуваний стан каркаса, а не збій.

**Повний діалог:** не збережено агентом
**Рішення людини (13.11.2026):**
1. 501 із порожнім тілом до реалізації операцій прийнято.
2. 404 для неіснуючого маршруту не змінювати.
3. WARNING без стеку для заглушок погоджено.
4. Димовий тест tests/test/skeleton/skeleton_smoke_test.dart буде видалено перед TEST-GATE, бо він не є тестом вимог.
5. Назви лог-файлів залишити (`control-<T-ID>-YYYYMMDD.log`); у репозиторій потрапляють лише логи контрольних запусків.
6. Коміт `feat: [agent] API project skeleton with stubs and logging` підтверджено.

## Етап 7. Тести за TDD (Test-тікети, API-частина) і червоний запуск — 13.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Написати тести API-частини T-11, T-12, T-13, T-14, T-17, T-18, T-19, T-20, T-22, T-23, T-24, T-25, T-26, T-27; T-15, T-16, T-21, T-28, T-61, T-62 не виконуються. Гілка impl/lab5.
2. Джерела — лише spec/srs.md (v1.1), AC, spec/acceptance.feature, spec/openapi.yaml, docs/api/scenarios.md (POS/NEG) і рішення людини на SPEC-GATE v1.1 (REV-004, REV-009). Код каркаса — лише точка входу `buildApp`.
3. Назва кожного тесту містить ID (BDD / AC / POS / NEG) і operationId; кожна відповідь перевіряється валідатором контракту в tests/support/; час і випадковість — лише FakeClock і SeededRandom; фікстури каталогів — у tests/fixtures/catalogs/.
4. Окремий тест: кожен operationId має хоча б один тест, і жодна відповідь не має статусу 501. Видалити tests/test/skeleton/skeleton_smoke_test.dart (рішення людини 13.11.2026).
5. Червоний запуск: `dart analyze --fatal-infos`, потім `dart test --reporter json`; скриптом довести, що кожен тест падає з очікуваної причини і «Failed to load» немає; перелічити тести, що несподівано проходять; лог — logs/app/control-red-<дата>.log; аналіз логу і таблиця простежуваності — у журналі.
6. Коміти за групами тегів OpenAPI, перед кожним — `git diff --cached --stat` і повідомлення. Поза тестами нічого не змінювати.

**Пропозиція агента та дії:**
- Відповідність «тікет → operationId» етапу 1 у журналі не збережено. Агент вивів її з колонки джерел docs/plan/decomposition.md і docs/api/req-api-traceability.md; результат — колонки «operationId» і «Тікет» таблиці простежуваності нижче (див. питання 1).
- tests/test/support/ (лише тестова інфраструктура):
  - `contract.dart` — `Contract` читає spec/openapi.yaml і перетворює схеми OpenAPI 3.0 на JSON Schema draft-07 (`nullable` → тип `null`, `$ref` → `definitions`, `example`/`discriminator`/`x-*` відкидаються). `ApiClient.send(operationId, …)` бере метод і шлях з контракту за operationId і викликає `App.handler`. Кожна відповідь перевіряється: статус оголошено для операції; тіло `application/json` і валідне за схемою (формати `date`, `date-time`, `uri` теж); `201` має `Location` (URI-reference); відповідь без `content` у контракті (`204`) має порожнє тіло; `Error.code` 4xx/5xx — з enum контракту. Порушення — `TestFailure` з operationId і статусом, зокрема «status 501 is not declared».
  - `fake_clock.dart` — `FakeClock` (встановлення, зсув; сценарій читань для BDD-040: старт, N читань із 2,999 с, далі 3,000 с).
  - `seeded_random.dart` — `SeededRandom` на `dart:math Random(seed)`; фіксовані зерна 1, 7, 42, 2026, 31337.
  - `test_app.dart` — `TestApp`: `buildApp` з FakeClock, SeededRandom і шляхом каталогу; власний тимчасовий файл SQLite на тест; `restart()` — нова композиція на тому самому файлі (рішення 4 етапу 1); `restartWithReadOnlyStorage()` — змодельований збій запису: файл БД лише для читання для ОС (читання працює, запис — ні; механізм перевірено окремо в scratchpad на SQLite: «attempt to write a readonly database»). Тестових ендпоінтів і заголовків немає (рішення 5 етапу 1). `CatalogData` читає дані каталогу самим тестом — очікувані значення беруться з погоджених даних, а не з коду.
  - `json.dart` — доступ до JSON і оракули з SRS: тривалість §5.4, порядок етапів §5.2, `D` §5.5.
  - `plan_properties.dart` — властивості сформованого плану: правила 1–6 §5.1, §5.2 (три непорожні етапи, варіант не більше одного разу за його id, D-33), межі `[min; max]` (AC-F-008 п. 3), `e` фіксоване (D-08).
  - `flows.dart` — передумови через контракт (кожен крок перевіряє свій успішний статус).
- tests/fixtures/catalogs/ — 9 фікстур (`placeholder: true`, назви `[TEST]`, посилання `example.com`, D-01). Арифметику перевірено скриптом `fixture_check.py` (Python, поза репозиторієм):
  - погоджені на етапі 5 (BDD-007, 012, 035, 038, 039, 040): `bdd-007-one-variant-per-stage` (600 + 2400 + 600 = 3600 с), `bdd-012-max-volume` (максимум 600 + 3600 + 600 = 4800 с = 80 хв < 6480 с), `catalog-v2-ex1-deprecated` (версія test-2: ex-1 застаріла, ex-2 перейменована, решта як test-1 — звірено скриптом), `bdd-038-reduce-to-minimum` (рекомендовано 4800 с > 3960 с, мінімум 180 с), `bdd-039-min-volume` (мінімум 4500 с > 3960 с), `bdd-040-search-limit` (суми 1800, 2400, 3000, 3600 с; у [2430; 2970] жодної, межі обсягу неможливості не доводять);
  - додаткові, не названі на етапі 5 (див. питання 15): `selection-rules` (T-19: придатні вправи й шість «приманок», кожна порушує рівно одне правило §5.1), `bdd-010-tolerance-bounds` (T-20: єдиний план 3239 / 3240 / 3960 / 3961 с за рівнем та інтенсивністю), `duration-tunable` (T-18, T-23: інтервал змінюється на 1 с, точна сума задається редагуванням).
  - Межі навантаження в нових фікстурах — тестові дані для перевірки правил, а не рекомендації (CON-005); діапазони `selection-rules` скопійовано з прикладів контракту (ex-1, ex-2, ex-4).
- Тести (16 файлів, 296 тестів): exercises/ — 4 файли (75), plan_generations/ — 4 (72), open_plans/ — 1 (33), training_plans/ — 1 (24), storage/ — 1 (8), current_session/ — 2 (34), completed_trainings/ — 1 (6), analytics/ — 1 (15), contract/ — 1 (29). Очікувані множини фільтрів T-14 (15 випадків і 10 комбінацій) звірено скриптом `filter_check.py` за правилами AC-F-003 / D-09 — розбіжностей 0.
- Окремий тест `contract/operation_coverage_test.dart`: (а) статично — кожен із 27 operationId викликається `send('<operationId>'` хоча б в одному тестовому файлі; (б) статично — кожен operationId має POS у docs/api/scenarios.md; (в) 27 тестів — запит із першим прикладом `requestBody` контракту, статус оголошено і не 501.
- Звірка покриття скриптом за decomposition.md: усі BDD і AC тікетів обсягу мають тест. BDD-007 (T-20), BDD-014 (T-22), BDD-023 (T-23), BDD-017 (T-25) перевірено в тестах сусіднього тікета (вказано в таблиці). BDD-027 не має операції API: відхилення підтвердження — дія клієнта, запит не надсилається (`abortCurrentSession`: «ознаки підтвердження в API немає»).
- tests/test/skeleton/skeleton_smoke_test.dart видалено (`git rm`, рішення людини 13.11.2026).
- src/ і spec/ не змінено. `dart format` не застосовано, бо форматування — це запис файлів командою shell; `dart analyze` зауважень не має.

**Червоний запуск (13.11.2026):**
- `cd tests && dart analyze --fatal-infos` → «No issues found!».
- Перший запуск `dart test --reporter json` (паралельно, за замовчуванням): 296 тестів, ті самі причини падіння. Але в лозі застосунку 2 пошкоджені рядки (`…onRequest"`) і 7 втрачених записів: ізоляти тестових файлів одночасно дописують в один файл, а `FileMode.append` у Dart не є атомарним дозаписом. Це властивість паралельного запуску тестів в одному процесі, а не сервера. Лог цього запуску видалено, src/ не змінено.
- Контрольний запуск: `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-red-20261113.log dart test --concurrency=1 --reporter json` → код виходу 1. Лог застосунку записала сама система: logs/app/control-red-20261113.log.
- Після рішення людини (див. нижче) контрольний запуск повторено з конфігурацією tests/dart_test.yaml (`concurrency: 1`): `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-red-20261113.log dart test --reporter compact --file-reporter json:../logs/app/control-red-20261113.jsonl` → код виходу 1. Вивід JSON записав сам `dart test`, лог — сама система; обидва файли — з одного запуску, попередній лог видалено. Набір тестів і причини падіння збігаються з попереднім запуском (звірено скриптом; відрізнявся лише символ-заповнювач у рядках тестів, що пройшли). Цифри нижче — з цього запуску.
- Скрипт tests/tool/red_check.py (`python3 -I tool/red_check.py ../logs/app/control-red-20261113.jsonl`, код виходу 0) за виводом репортера:
  - 16 наборів, 296 видимих тестів; «Failed to load» і помилок завантаження — 0;
  - 293 тести — `failure`, у кожного перша й єдина помилка — `TestFailure` валідатора «<operationId>: status 501 is not declared in ../spec/openapi.yaml»; інших причин — 0; `UnimplementedError` до тестів не дійшов жодного разу — middleware каркаса перетворює його на 501;
  - операція, що першою відповіла 501: generatePlan — 168, createExercise — 41, listExercises — 29, getAnalytics — 8, getDictionary і getExercise — по 6, listCompletedTrainings — 3, решта 20 операцій — по 1–2;
  - несподівано пройшли 3 тести — усі статичні, систему не викликають:
    1. `AC-NF-006 REQ-NF-006 all operationIds…` — перевіряє тестові файли (кожен operationId викликається);
    2. `AC-NF-006 docs/api/scenarios.md: every operationId has a POS scenario` — перевіряє документ сценаріїв;
    3. `D-20 AC-F-014 getCompletedTraining: records are read-only…` — перевіряє, що в контракті немає операцій зміни чи видалення завершеного тренування.
    Вони проходять за призначенням і після реалізації стережуть від регресії контракту й покриття.

**Аналіз логу logs/app/control-red-20261113.log (скрипт):**
- 888 записів, пошкоджених рядків 0; INFO — 595, WARNING — 293, ERROR — 0, стеків — 0.
- `app composed operations=27` — 302 рази (кожен тест або кожна композиція: два застосунки в тестах D-11, другий застосунок у BDD-014). Каталоги: постачальний `../src/assets/catalog/test-catalog.json` — 283, фікстури — 19 (duration-tunable 4, bdd-010 4, selection-rules 5, bdd-040 2, bdd-007, bdd-012, bdd-038, bdd-039 — по 1).
- Запитів (INFO `http: request`) — 293, усі зі статусом 501; різних operationId — 27; тривалість 0–5 мс. Кожному запиту передує WARNING `not implemented` того самого operationId (293 пари), отже на кожен тест — рівно один запит до першої заглушки.
- Місце заглушки: декодер тіла чи параметрів (наприклад `decode PlanGenerationRequest` — 162, `decode ExerciseInput` — 41, `decode ExerciseFilter` — 28, `decode analytics period` — 8) або сервіс (`getExercise`, `listTrainingPlans` тощо).
- Вмісту полів користувача (назви `[TEST]`, примітки), значень query й мережевих адрес у лозі немає (REQ-NF-004, рішення 3 етапу 1).
- Висновок: тести падають саме через нереалізовані операції; помилок середовища, компіляції чи завантаження немає.

**Таблиця простежуваності «тест → BDD / AC → REQ → operationId → тікет»** (згенеровано скриптом `trace.py` з виводу репортера, spec/acceptance.feature і docs/api/scenarios.md; REQ — за тегами BDD, номером AC, а для тестів лише з POS / NEG — за колонкою REQ-ID сценарію; тести з різними зернами об'єднано позначкою «×5»; 27 тестів «never 501» — один рядок):

| № | Файл | Тест | BDD / AC / POS / NEG | REQ | operationId | Тікет | Червоний запуск |
|---|---|---|---|---|---|---|---|
| 1 | operation_coverage | AC-NF-006 REQ-NF-006 all operationIds: every operation of spec/openapi.yaml is called by at least one test | AC-NF-006 | REQ-NF-006 | `усі 27` | усі (REQ-NF-006) | пройшов (статичний) |
| 2 | operation_coverage | AC-NF-006 docs/api/scenarios.md: every operationId has a POS scenario | AC-NF-006 | REQ-NF-006 | `усі 27` | усі (REQ-NF-006) | пройшов (статичний) |
| 3 | operation_coverage | AC-NF-006 every operation answers with a declared status, never 501 — POS-xx <operationId>: <метод> <шлях> → declared status, not 501 (×27, по одному на кожен operationId; тіло — перший приклад requestBody контракту) | AC-NF-006, POS-01…POS-36 (перший POS операції) | REQ-NF-006 | усі 27 | усі (REQ-NF-006) | 501: кожна з 27 операцій |
| 4 | history | POS-33 BDD-020 AC-F-014 listCompletedTrainings: an empty history → items [] | BDD-020, AC-F-014, POS-33 | REQ-F-014, REQ-F-016 | `listCompletedTrainings` | T-26 | 501: listCompletedTrainings |
| 5 | history | POS-32 AC-F-014 listCompletedTrainings: records are ordered by start time from newer to older, not by the moment of completion | AC-F-014, POS-32 | REQ-F-014 | `listCompletedTrainings` | T-26 | 501: generatePlan |
| 6 | history | POS-34 BDD-016 AC-F-014 getCompletedTraining: details have the start date and time, the local date, the exercises with execution parameters and the note | BDD-016, AC-F-014, POS-34 | REQ-F-012, REQ-F-013, REQ-F-014 | `getCompletedTraining` | T-26 | 501: generatePlan |
| 7 | history | BDD-017 AC-F-014 updateExercise getCompletedTraining: changing the name and parameters of a custom exercise in the catalog does not change its copy in the history | BDD-017, AC-F-014 | REQ-F-013, REQ-F-014 | `updateExercise`, `getCompletedTraining` | T-26 | 501: createExercise |
| 8 | history | AC-F-014 getCompletedTraining: unknown record → 404 NOT_FOUND | AC-F-014 | REQ-F-014 | `getCompletedTraining` | T-26 | 501: getCompletedTraining |
| 9 | history | D-20 AC-F-014 getCompletedTraining: records are read-only — the contract has no operation to change or delete a completed training | AC-F-014 | REQ-F-014 | `getCompletedTraining` | T-26 | пройшов (статичний) |
| 10 | storage | AC-NF-002 createExercise saveNewTrainingPlan completeTraining: after a confirmed save and a restart the custom exercise, the saved plan and the completed training are restored with the same values, order and note | AC-NF-002 | REQ-NF-002 | `createExercise`, `saveNewTrainingPlan`, `completeTraining` | T-12 | 501: createExercise |
| 11 | storage | BDD-015 AC-F-011 AC-NF-002 updateExercise getTrainingPlan: a saved plan with a custom exercise keeps the previous name and saved parameters after the exercise is changed and the app restarted | BDD-015, AC-NF-002, AC-F-011 | REQ-F-011, REQ-NF-002 | `updateExercise`, `getTrainingPlan` | T-12, T-23 | 501: createExercise |
| 12 | storage | AC-NF-003 saveNewTrainingPlan: success is reported only after the write is complete — a restart right after 201 finds the plan | AC-NF-002, AC-NF-003 | REQ-NF-002, REQ-NF-003 | `saveNewTrainingPlan` | T-12 | 501: generatePlan |
| 13 | storage | AC-NF-003 completeTraining: success is reported only after the write is complete — a restart right after 201 finds the record | AC-NF-002, AC-NF-003 | REQ-NF-002, REQ-NF-003 | `completeTraining` | T-12 | 501: generatePlan |
| 14 | storage | BDD-021 NEG-07 AC-NF-003 completeTraining getCurrentSession listCompletedTrainings: a storage error → 500 STORAGE_WRITE_FAILED, no partial record, the session stays current | BDD-021, AC-NF-003, NEG-07 | REQ-NF-003 | `completeTraining`, `getCurrentSession`, `listCompletedTrainings` | T-12, T-25 | 501: generatePlan |
| 15 | storage | AC-NF-003 saveNewTrainingPlan: a storage error → 500 STORAGE_WRITE_FAILED, no plan is saved and the open plan stays unsaved | AC-NF-003 | REQ-NF-003 | `saveNewTrainingPlan` | T-12 | 501: generatePlan |
| 16 | storage | AC-NF-003 overwriteTrainingPlan: a storage error → 500 STORAGE_WRITE_FAILED, the previous saved plan stays in full | AC-NF-003 | REQ-NF-003 | `overwriteTrainingPlan` | T-12 | 501: generatePlan |
| 17 | storage | AC-NF-003 deleteTrainingPlan: a storage error → 500 STORAGE_WRITE_FAILED, the plan is not deleted | AC-NF-003 | REQ-NF-003 | `deleteTrainingPlan` | T-12 | 501: generatePlan |
| 18 | manual_editing | BDD-013 AC-F-010 updateOpenPlanItem getOpenPlan: rounds of one element changed within the limits — total recalculated, other elements unchanged | BDD-013, AC-F-010 | REQ-F-010 | `updateOpenPlanItem`, `getOpenPlan` | T-22 | 501: generatePlan |
| 19 | manual_editing | BDD-032 NEG-17 AC-F-010 updateOpenPlanItem: 6 rounds for a variant with at most 5 → 422 VALIDATION_FAILED WITHIN_VARIANT_RANGE, plan unchanged | BDD-032, AC-F-010, NEG-17 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 20 | manual_editing | NEG-18 D-08 AC-F-010 updateOpenPlanItem: repetitionTimeSeconds → 422 VALIDATION_FAILED NOT_EDITABLE, e unchanged | AC-F-010, NEG-18 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 21 | manual_editing | AC-F-010 updateOpenPlanItem: zero rounds → 422 VALIDATION_FAILED, plan unchanged | AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 22 | manual_editing | AC-F-010 updateOpenPlanItem: negative rest → 422 VALIDATION_FAILED, plan unchanged | AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 23 | manual_editing | AC-F-010 updateOpenPlanItem: non-integer interval → 422 VALIDATION_FAILED, plan unchanged | AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 24 | manual_editing | AC-F-010 updateOpenPlanItem: field of the other mode (sets for a time variant) → 422 VALIDATION_FAILED, plan unchanged | AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 25 | manual_editing | AC-F-010 updateOpenPlanItem: position outside the stage → 422 VALIDATION_FAILED, plan unchanged | AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 26 | manual_editing | AC-F-010 updateOpenPlanItem: empty body → 422 VALIDATION_FAILED, plan unchanged | AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 27 | manual_editing | AC-F-010 updateOpenPlanItem: unknown element → 404 NOT_FOUND | AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 28 | manual_editing | D-14 AC-F-010 updateOpenPlanItem: generation parameters stay in the open plan after edits | AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 29 | manual_editing | BDD-023 AC-F-010 updateOpenPlanItem getExercise saveNewTrainingPlan: ex-2 (main only) moved to the warm-up is allowed, its catalog classification is unchanged and the plan can be saved | BDD-023, AC-F-010 | REQ-F-010, REQ-F-011 | `updateOpenPlanItem`, `getExercise`, `saveNewTrainingPlan` | T-22 | 501: generatePlan |
| 30 | manual_editing | AC-F-010 updateOpenPlanItem: order within a stage is changed, positions stay contiguous, stage order is fixed | AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 31 | manual_editing | POS-14 BDD-013 AC-F-010 addOpenPlanItem: ex-1 added to the cool-down outside its stages — appended at the end, total recalculated, Location of the new element | BDD-013, AC-F-010, POS-14 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 32 | manual_editing | AC-F-010 addOpenPlanItem: position 0 inserts at the beginning of the stage, positions stay contiguous | AC-F-010 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 33 | manual_editing | BDD-041 D-15 AC-F-010 addOpenPlanItem: the same variant V of E1 added again is allowed and the plan contains V twice | BDD-041, AC-F-010 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 34 | manual_editing | AC-F-010 addOpenPlanItem: an exercise that does not match the source filters gets FILTER_MISMATCH warnings | AC-F-010 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 35 | manual_editing | NEG-14 unknown exercise: addOpenPlanItem → 422 EXERCISE_NOT_FOUND, plan unchanged | NEG-14 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 36 | manual_editing | NEG-15 D-33 variant not of the exercise: addOpenPlanItem → 422 VARIANT_NOT_FOUND, plan unchanged | NEG-15 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 37 | manual_editing | NEG-16 D-06 deprecated exercise ex-9: addOpenPlanItem → 422 EXERCISE_DEPRECATED, plan unchanged | NEG-16 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 38 | manual_editing | NEG-17 BDD-032 6 rounds above the variant maximum 5: addOpenPlanItem → 422 VALIDATION_FAILED, plan unchanged | BDD-032, NEG-17 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 39 | manual_editing | AC-F-010 D-08 repetitionTimeSeconds is not accepted: addOpenPlanItem → 422 VALIDATION_FAILED, plan unchanged | AC-F-010 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 40 | manual_editing | AC-F-010 position outside the stage: addOpenPlanItem → 422 VALIDATION_FAILED, plan unchanged | AC-F-010 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 41 | manual_editing | AC-F-010 addOpenPlanItem: unknown open plan → 404 NOT_FOUND | AC-F-010 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 42 | manual_editing | POS-15 AC-F-010 replaceOpenPlanItem: a main element replaced by the custom rope exercise keeps id, stage and position; FILTER_MISMATCH for intensity, availableEquipment and emphasis | AC-F-010, POS-15 | REQ-F-010 | `replaceOpenPlanItem` | T-22 | 501: generatePlan |
| 43 | manual_editing | AC-F-010 replaceOpenPlanItem: ex-7 (advanced, high, endurance, no equipment) gives FILTER_MISMATCH for level, intensity and emphasis only | AC-F-010 | REQ-F-010 | `replaceOpenPlanItem` | T-22 | 501: generatePlan |
| 44 | manual_editing | NEG-16 D-06 deprecated exercise ex-9: replaceOpenPlanItem → 422 EXERCISE_DEPRECATED, plan unchanged | NEG-16 | REQ-F-010 | `replaceOpenPlanItem` | T-22 | 501: generatePlan |
| 45 | manual_editing | NEG-14 unknown exercise: replaceOpenPlanItem → 422 EXERCISE_NOT_FOUND, plan unchanged | NEG-14 | REQ-F-010 | `replaceOpenPlanItem` | T-22 | 501: generatePlan |
| 46 | manual_editing | NEG-17 BDD-032 parameters outside the variant range: replaceOpenPlanItem → 422 VALIDATION_FAILED, plan unchanged | BDD-032, NEG-17 | REQ-F-010 | `replaceOpenPlanItem` | T-22 | 501: generatePlan |
| 47 | manual_editing | NEG-18 D-08 repetitionTimeSeconds is not accepted: replaceOpenPlanItem → 422 VALIDATION_FAILED, plan unchanged | NEG-18 | REQ-F-010 | `replaceOpenPlanItem` | T-22 | 501: generatePlan |
| 48 | manual_editing | AC-F-010 unknown element: replaceOpenPlanItem → 404 NOT_FOUND, plan unchanged | AC-F-010 | REQ-F-010 | `replaceOpenPlanItem` | T-22 | 501: generatePlan |
| 49 | manual_editing | POS-18 BDD-033 AC-F-010 deleteOpenPlanItem: emptying the warm-up gives STAGE_EMPTY for the warm-up and recalculates the total | BDD-033, AC-F-010, POS-18 | REQ-F-010, REQ-F-011 | `deleteOpenPlanItem` | T-22 | 501: generatePlan |
| 50 | manual_editing | AC-F-010 deleteOpenPlanItem: unknown element → 404 NOT_FOUND | AC-F-010 | REQ-F-010 | `deleteOpenPlanItem` | T-22 | 501: generatePlan |
| 51 | catalog_version | BDD-035 D-06 AC-F-001 getExercise: the custom exercise is not changed by the new catalog version | BDD-035, AC-F-001 | REQ-F-001, REQ-F-003, REQ-F-006, REQ-F-010 | `getExercise` | T-13, T-14, T-19, T-22, T-23, T-26 | 501: createExercise |
| 52 | catalog_version | BDD-035 D-06 AC-F-001 AC-F-003 listExercises: E1 is not shown in the catalog; renamed ex-2 is shown with the new name | BDD-035, AC-F-001, AC-F-003 | REQ-F-001, REQ-F-003, REQ-F-006, REQ-F-010 | `listExercises` | T-13, T-14, T-19, T-22, T-23, T-26 | 501: createExercise |
| 53 | catalog_version | BDD-035 D-06 AC-F-001 getExercise: E1 is not deleted — its card opens from the plan with deprecated true | BDD-035, AC-F-001 | REQ-F-001, REQ-F-003, REQ-F-006, REQ-F-010 | `getExercise` | T-13, T-14, T-19, T-22, T-23, T-26 | 501: createExercise |
| 54 | catalog_version | BDD-035 D-06 AC-F-006 generatePlan: the generator does not propose E1 | BDD-035, AC-F-006 | REQ-F-001, REQ-F-003, REQ-F-006, REQ-F-010 | `generatePlan` | T-13, T-14, T-19, T-22, T-23, T-26 | 501: createExercise |
| 55 | catalog_version | BDD-035 D-06 NEG-16 AC-F-010 addOpenPlanItem: E1 cannot be added to a plan manually → 422 EXERCISE_DEPRECATED | BDD-035, AC-F-010, NEG-16 | REQ-F-001, REQ-F-003, REQ-F-006, REQ-F-010 | `addOpenPlanItem` | T-13, T-14, T-19, T-22, T-23, T-26 | 501: createExercise |
| 56 | catalog_version | BDD-035 D-06 AC-F-011 getTrainingPlan openSavedPlan: the saved plan still contains E1 and copies made before the update | BDD-035, AC-F-011 | REQ-F-001, REQ-F-003, REQ-F-006, REQ-F-010, REQ-F-011 | `getTrainingPlan`, `openSavedPlan` | T-13, T-14, T-19, T-22, T-23, T-26 | 501: createExercise |
| 57 | catalog_version | BDD-035 D-06 AC-F-014 getCompletedTraining: history contains E1 and the details are not changed by the new version | BDD-035, AC-F-014 | REQ-F-001, REQ-F-003, REQ-F-006, REQ-F-010, REQ-F-014 | `getCompletedTraining` | T-13, T-14, T-19, T-22, T-23, T-26 | 501: createExercise |
| 58 | catalog_initialization | BDD-001 AC-F-001 AC-NF-001 listExercises: after the first start all non-deprecated initial exercises are available without network | BDD-001, AC-F-001, AC-NF-001 | REQ-F-001, REQ-NF-001 | `listExercises` | T-13 | 501: listExercises |
| 59 | catalog_initialization | BDD-001 AC-F-001 D-06 listExercises: deprecated initial exercise ex-9 is not shown in the catalog | BDD-001, AC-F-001 | REQ-F-001, REQ-NF-001 | `listExercises` | T-13 | 501: listExercises |
| 60 | catalog_initialization | BDD-001 AC-F-001 listExercises: a repeated start adds no duplicates | BDD-001, AC-F-001 | REQ-F-001, REQ-NF-001 | `listExercises` | T-13 | 501: listExercises |
| 61 | catalog_initialization | D-05 AC-F-001 createExercise updateExercise getExercise: a repeated start keeps custom exercises and their changes | AC-F-001 | REQ-F-001 | `createExercise`, `updateExercise`, `getExercise` | T-13 | 501: createExercise |
| 62 | catalog_initialization | POS-04 AC-F-004 D-01 getExercise: every initial exercise card equals the supplied data and has a [TEST] name and example.com HTTPS links | AC-F-004, POS-04 | REQ-F-004 | `getExercise` | T-13 | 501: getExercise |
| 63 | catalog_initialization | POS-06 D-06 getExercise: the card of deprecated ex-9 is available with deprecated true | POS-06 | REQ-F-002 | `getExercise` | T-13 | 501: getExercise |
| 64 | catalog_filter | AC-F-003 listExercises: filter by stage warm-up | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 65 | catalog_filter | AC-F-003 listExercises: filter by stage main | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 66 | catalog_filter | AC-F-003 listExercises: filter by stage cool-down | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 67 | catalog_filter | AC-F-003 listExercises: filter by type single-punch | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 68 | catalog_filter | AC-F-003 listExercises: filter by type combination | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 69 | catalog_filter | AC-F-003 listExercises: filter by level level-advanced | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 70 | catalog_filter | AC-F-003 listExercises: filter by level level-intermediate | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 71 | catalog_filter | AC-F-003 listExercises: filter by intensity intensity-low | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 72 | catalog_filter | AC-F-003 listExercises: filter by intensity intensity-high | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 73 | catalog_filter | AC-F-003 listExercises: filter by emphasis emphasis-endurance | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 74 | catalog_filter | AC-F-003 listExercises: filter by loadCharacter special-physical | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 75 | catalog_filter | AC-F-003 listExercises: filter by executionMeans means-pairs | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 76 | catalog_filter | AC-F-003 listExercises: filter by executionMeans means-no-equipment | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 77 | catalog_filter | AC-F-003 listExercises: filter by equipment equipment-bag | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 78 | catalog_filter | AC-F-003 listExercises: filter by equipment equipment-pads | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 79 | catalog_filter | AC-F-003 D-09 listExercises: two stages are combined by OR | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 80 | catalog_filter | AC-F-003 D-09 listExercises: different attributes are combined by AND | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 81 | catalog_filter | BDD-037 D-09 D-34 AC-F-003 listExercises: levels «beginner» OR «intermediate» give A, B and C; adding load character «ЗФП» leaves only A; C with «not applicable» is not shown; no filters give all | BDD-037, AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 82 | catalog_filter | REV-004 D-09 D-34 AC-F-003 listExercises: filter loadCharacter not-applicable → 200 and an empty list | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 83 | catalog_filter | POS-02 AC-F-003 listExercises: no result → 200 and items [] | AC-F-003, POS-02 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 84 | catalog_filter | POS-01 AC-F-003 listExercises: items have id, name, type and origin of the catalog exercise | AC-F-003, POS-01 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 85 | catalog_filter | BDD-004 AC-F-003 listExercises: ex-6 (pads without bag, bag without pads) is not found by means «pads» AND equipment «bag» | BDD-004, AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 86 | catalog_filter | BDD-004 AC-F-003 listExercises: ex-6 is found when means and equipment belong to the same variant | BDD-004, AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 87 | catalog_filter | AC-F-003 createExercise listExercises: custom exercises are filtered together with initial ones | AC-F-003 | REQ-F-003 | `createExercise`, `listExercises` | T-14 | 501: createExercise |
| 88 | catalog_filter | NEG-05 AC-F-003 listExercises: unknown dictionary value → 422 UNKNOWN_DICTIONARY_VALUE | AC-F-003, NEG-05 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 89 | catalog_filter | AC-F-003 listExercises: value outside the stage enumeration → 422 UNKNOWN_DICTIONARY_VALUE | AC-F-003 | REQ-F-003 | `listExercises` | T-14 | 501: listExercises |
| 90 | catalog_filter | POS-08 getDictionary: training-levels has the values of the supplied data | POS-08 | REQ-F-003, REQ-F-005 | `getDictionary` | T-14 | 501: getDictionary |
| 91 | catalog_filter | POS-08 getDictionary: intensities has the values of the supplied data | POS-08 | REQ-F-003, REQ-F-005 | `getDictionary` | T-14 | 501: getDictionary |
| 92 | catalog_filter | POS-08 getDictionary: emphases has the values of the supplied data | POS-08 | REQ-F-003, REQ-F-005 | `getDictionary` | T-14 | 501: getDictionary |
| 93 | catalog_filter | POS-08 getDictionary: equipment has the values of the supplied data | POS-08 | REQ-F-003, REQ-F-005 | `getDictionary` | T-14 | 501: getDictionary |
| 94 | catalog_filter | POS-08 getDictionary: execution-means has the values of the supplied data | POS-08 | REQ-F-003, REQ-F-005 | `getDictionary` | T-14 | 501: getDictionary |
| 95 | exercise_validation | POS-03 POS-05 BDD-024 AC-F-002 AC-F-004 createExercise getExercise: custom exercise without video data is saved with the entered values | BDD-024, AC-F-002, AC-F-004, POS-03, POS-05 | REQ-F-002, REQ-F-004 | `createExercise`, `getExercise` | T-11 | 501: createExercise |
| 96 | exercise_validation | BDD-002 POS-07 AC-F-002 createExercise updateExercise getExercise: changed description is saved and returned when the card is reopened | BDD-002, AC-F-002, POS-07 | REQ-F-002 | `createExercise`, `updateExercise`, `getExercise` | T-11 | 501: createExercise |
| 97 | exercise_validation | D-05 AC-F-002 createExercise: id, origin and deprecated in the body are set by the system (origin custom, deprecated false) | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 98 | exercise_validation | BDD-052 D-33 AC-F-002 updateExercise: after changing variant V1 the variants V1 and V2 keep their ids | BDD-052, AC-F-002 | REQ-F-002 | `updateExercise` | T-11 | 501: createExercise |
| 99 | exercise_validation | AC-F-002 D-33 updateExercise: a variant without id is added with a new id, a variant missing from the body is removed | AC-F-002 | REQ-F-002 | `updateExercise` | T-11 | 501: createExercise |
| 100 | exercise_validation | BDD-003 AC-F-002 updateExercise: minimum 5 sets above maximum 3 → 422 VALIDATION_FAILED, saved data unchanged | BDD-003, AC-F-002 | REQ-F-002 | `updateExercise` | T-11 | 501: createExercise |
| 101 | exercise_validation | AC-F-002 updateExercise: empty name of a custom exercise → 422 VALIDATION_FAILED, no partial save of other changed fields | AC-F-002 | REQ-F-002 | `updateExercise` | T-11 | 501: createExercise |
| 102 | exercise_validation | BDD-034 D-05 NEG-06 AC-F-002 updateExercise: initial exercise ex-1 → 403 INITIAL_EXERCISE_READ_ONLY, data unchanged | BDD-034, AC-F-002, NEG-06 | REQ-F-002 | `updateExercise` | T-11 | 501: getExercise |
| 103 | exercise_validation | BDD-034 D-05 D-06 updateExercise: deprecated initial exercise ex-9 → 403 INITIAL_EXERCISE_READ_ONLY | BDD-034, AC-F-002 | REQ-F-002 | `updateExercise` | T-11 | 501: getExercise |
| 104 | exercise_validation | AC-F-002 updateExercise: unknown exercise → 404 NOT_FOUND | AC-F-002 | REQ-F-002 | `updateExercise` | T-11 | 501: updateExercise |
| 105 | exercise_validation | NEG-02 getExercise: unknown exercise → 404 NOT_FOUND | AC-F-002, NEG-02 | REQ-F-002 | `getExercise` | T-11 | 501: getExercise |
| 106 | exercise_validation | AC-F-002 empty name: createExercise → 422 VALIDATION_FAILED | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 107 | exercise_validation | AC-F-002 empty description: createExercise → 422 VALIDATION_FAILED | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 108 | exercise_validation | AC-F-002 missing name: createExercise → 422 VALIDATION_FAILED | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 109 | exercise_validation | AC-F-002 no variants: createExercise → 422 VALIDATION_FAILED | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 110 | exercise_validation | NEG-03 BDD-003 AC-F-002 rounds minimum 5 above maximum 3: createExercise → 422 VALIDATION_FAILED | BDD-003, AC-F-002, NEG-03 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 111 | exercise_validation | D-08 AC-F-002 recommended rounds above maximum: createExercise → 422 VALIDATION_FAILED | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 112 | exercise_validation | D-08 AC-F-002 recommended interval below minimum: createExercise → 422 VALIDATION_FAILED | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 113 | exercise_validation | AC-F-002 SRS §5.3 zero rounds: createExercise → 422 VALIDATION_FAILED | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 114 | exercise_validation | AC-F-002 SRS §5.3 negative rest: createExercise → 422 VALIDATION_FAILED | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 115 | exercise_validation | AC-F-002 SRS §5.3 non-integer interval: createExercise → 422 VALIDATION_FAILED | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 116 | exercise_validation | D-08 AC-F-002 zero repetition time: createExercise → 422 VALIDATION_FAILED | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 117 | exercise_validation | D-08 AC-F-002 missing repetition time: createExercise → 422 VALIDATION_FAILED | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 118 | exercise_validation | AC-F-004 video link is not HTTPS: createExercise → 422 VALIDATION_FAILED | AC-F-002, AC-F-004 | REQ-F-002, REQ-F-004 | `createExercise` | T-11 | 501: createExercise |
| 119 | exercise_validation | AC-F-004 author page link is not HTTPS: createExercise → 422 VALIDATION_FAILED | AC-F-002, AC-F-004 | REQ-F-002, REQ-F-004 | `createExercise` | T-11 | 501: createExercise |
| 120 | exercise_validation | AC-F-002 createExercise: wrong JSON type of a field → 400 BAD_REQUEST | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 121 | exercise_validation | AC-F-002 createExercise: malformed JSON → 400 BAD_REQUEST | AC-F-002 | REQ-F-002 | `createExercise` | T-11 | 501: createExercise |
| 122 | exercise_validation | BDD-036 D-07 AC-F-004 createExercise getExercise: video=yes author=no is saved; absent links are null | BDD-036, AC-F-004 | REQ-F-004 | `createExercise`, `getExercise` | T-11 | 501: createExercise |
| 123 | exercise_validation | BDD-036 D-07 AC-F-004 createExercise getExercise: video=no author=yes is saved; absent links are null | BDD-036, AC-F-004 | REQ-F-004 | `createExercise`, `getExercise` | T-11 | 501: createExercise |
| 124 | exercise_validation | BDD-036 D-07 AC-F-004 createExercise getExercise: video=yes author=yes is saved; absent links are null | BDD-036, AC-F-004 | REQ-F-004 | `createExercise`, `getExercise` | T-11 | 501: createExercise |
| 125 | exercise_validation | BDD-036 D-07 AC-F-004 createExercise getExercise: video=no author=no is saved; absent links are null | BDD-036, AC-F-004 | REQ-F-004 | `createExercise`, `getExercise` | T-11 | 501: createExercise |
| 126 | save_reopen | POS-21 POS-22 AC-F-011 D-14 D-31 saveNewTrainingPlan getTrainingPlan getOpenPlan: the saved plan has the same stages, order, variants, parameters and five generation parameters; Location; the open plan is linked to it | AC-F-011, POS-21, POS-22 | REQ-F-011 | `saveNewTrainingPlan`, `getTrainingPlan`, `getOpenPlan` | T-23 | 501: generatePlan |
| 127 | save_reopen | BDD-042 D-16 D-32 AC-F-011 saveNewTrainingPlan renameOpenPlan overwriteTrainingPlan: unsaved plan has no name; saved on 12.11.2026 at 18:05 it is «План від 12.11.2026 18:05»; renamed «Спаринговий день»; with a cleared name it gets the default name of that save | BDD-042, AC-F-011 | REQ-F-011 | `saveNewTrainingPlan`, `renameOpenPlan`, `overwriteTrainingPlan` | T-23 | 501: generatePlan |
| 128 | save_reopen | REV-009 D-16 AC-F-011 saveNewTrainingPlan renameOpenPlan overwriteTrainingPlan: modifiedAt is the moment of a successful save or overwrite; renaming the open plan does not change it | AC-F-011 | REQ-F-011 | `saveNewTrainingPlan`, `renameOpenPlan`, `overwriteTrainingPlan` | T-23 | 501: generatePlan |
| 129 | save_reopen | POS-13 D-32 renameOpenPlan saveNewTrainingPlan: a generated unsaved plan gets a name before the first save; sourcePlanId stays null; the name is saved | POS-13 | REQ-F-011 | `renameOpenPlan`, `saveNewTrainingPlan` | T-23 | 501: generatePlan |
| 130 | save_reopen | D-16 AC-F-011 saveNewTrainingPlan: names of saved plans need not be unique | AC-F-011 | REQ-F-011 | `saveNewTrainingPlan` | T-23 | 501: generatePlan |
| 131 | save_reopen | POS-20 D-16 listTrainingPlans: no saved plans → items [] | POS-20 | REQ-F-011 | `listTrainingPlans` | T-23 | 501: listTrainingPlans |
| 132 | save_reopen | BDD-043 POS-19 POS-24 D-16 AC-F-011 listTrainingPlans deleteTrainingPlan getTrainingPlan: P2 changed later is above P1; after deletion P1 is absent | BDD-043, AC-F-011, POS-19, POS-24 | REQ-F-011 | `listTrainingPlans`, `deleteTrainingPlan`, `getTrainingPlan` | T-23 | 501: generatePlan |
| 133 | save_reopen | REV-009 D-16 AC-F-011 listTrainingPlans overwriteTrainingPlan: an overwrite moves P1 above P2 | AC-F-011 | REQ-F-011 | `listTrainingPlans`, `overwriteTrainingPlan` | T-23 | 501: generatePlan |
| 134 | save_reopen | AC-F-011 D-16 SRS §4.5 deleteTrainingPlan: the history and the current session keep their own copies | AC-F-011 | REQ-F-011 | `deleteTrainingPlan` | T-23 | 501: generatePlan |
| 135 | save_reopen | AC-F-011 D-16 getTrainingPlan deleteTrainingPlan: unknown plan → 404 NOT_FOUND | AC-F-011 | REQ-F-011 | `getTrainingPlan`, `deleteTrainingPlan` | T-23 | 501: getTrainingPlan |
| 136 | save_reopen | POS-10 POS-12 BDD-015 AC-F-011 openSavedPlan getOpenPlan: the opened copy has the saved name, sourcePlanId and the same stages; Location | BDD-015, AC-F-011, POS-10, POS-12 | REQ-F-011, REQ-NF-002 | `openSavedPlan`, `getOpenPlan` | T-23 | 501: generatePlan |
| 137 | save_reopen | BDD-044 D-16 AC-F-011 openSavedPlan updateOpenPlanItem overwriteTrainingPlan listTrainingPlans: saving the opened plan P1 overwrites it — one plan P1 with the changed rounds | BDD-044, AC-F-011 | REQ-F-011 | `openSavedPlan`, `updateOpenPlanItem`, `overwriteTrainingPlan`, `listTrainingPlans` | T-23 | 501: generatePlan |
| 138 | save_reopen | NEG-13 AC-F-011 openSavedPlan: unknown saved plan → 422 PLAN_NOT_FOUND | AC-F-011, NEG-13 | REQ-F-011 | `openSavedPlan` | T-23 | 501: openSavedPlan |
| 139 | save_reopen | NEG-19 D-16 AC-F-011 saveNewTrainingPlan: an open plan linked to a saved plan → 409 OPEN_PLAN_ALREADY_SAVED, no new plan | AC-F-011, NEG-19 | REQ-F-011 | `saveNewTrainingPlan` | T-23 | 501: generatePlan |
| 140 | save_reopen | NEG-20 AC-F-011 saveNewTrainingPlan overwriteTrainingPlan: unknown open plan → 422 OPEN_PLAN_NOT_FOUND | AC-F-011, NEG-20 | REQ-F-011 | `saveNewTrainingPlan`, `overwriteTrainingPlan` | T-23 | 501: saveNewTrainingPlan |
| 141 | save_reopen | NEG-22 AC-F-011 overwriteTrainingPlan: the open plan of P1 saved to P2 → 409 OPEN_PLAN_SOURCE_MISMATCH, P2 unchanged | AC-F-011, NEG-22 | REQ-F-011 | `overwriteTrainingPlan` | T-23 | 501: generatePlan |
| 142 | save_reopen | AC-F-011 overwriteTrainingPlan: an unsaved generated plan (sourcePlanId null) → 409 OPEN_PLAN_SOURCE_MISMATCH | AC-F-011 | REQ-F-011 | `overwriteTrainingPlan` | T-23 | 501: generatePlan |
| 143 | save_reopen | D-16 AC-F-011 overwriteTrainingPlan: the saved plan was deleted after opening → 404 NOT_FOUND | AC-F-011 | REQ-F-011 | `overwriteTrainingPlan` | T-23 | 501: generatePlan |
| 144 | save_reopen | BDD-033 NEG-21 AC-F-010 AC-F-011 deleteOpenPlanItem saveNewTrainingPlan overwriteTrainingPlan: without the warm-up the plan is saved with STAGE_EMPTY; after deleting the rest it is not saved (422 PLAN_EMPTY) | BDD-033, AC-F-010, AC-F-011, NEG-21 | REQ-F-010, REQ-F-011 | `deleteOpenPlanItem`, `saveNewTrainingPlan`, `overwriteTrainingPlan` | T-23 | 501: generatePlan |
| 145 | save_reopen | NEG-21 BDD-033 AC-F-011 saveNewTrainingPlan: a completely empty generated plan → 422 PLAN_EMPTY, nothing saved | BDD-033, AC-F-011, NEG-21 | REQ-F-010, REQ-F-011 | `saveNewTrainingPlan` | T-23 | 501: generatePlan |
| 146 | save_reopen | BDD-014 POS-23 AC-F-010 AC-F-011 saveNewTrainingPlan overwriteTrainingPlan: a manually changed plan outside ±10 % is saved with DURATION_OUT_OF_TOLERANCE | BDD-014, AC-F-010, AC-F-011, POS-23 | REQ-F-010, REQ-F-011 | `saveNewTrainingPlan`, `overwriteTrainingPlan` | T-23 | 501: generatePlan |
| 147 | save_reopen | BDD-051 D-30 AC-F-011 getOpenPlan listTrainingPlans: an unsaved open plan is absent after a restart; saved P1 is in the list | BDD-051, AC-F-011 | REQ-F-011, REQ-NF-002 | `getOpenPlan`, `listTrainingPlans` | T-23 | 501: generatePlan |
| 148 | save_reopen | AC-F-011 D-30 getOpenPlan renameOpenPlan: unknown open plan → 404 NOT_FOUND | AC-F-011 | REQ-F-011 | `getOpenPlan`, `renameOpenPlan` | T-23 | 501: getOpenPlan |
| 149 | save_reopen | AC-F-011 D-16 renameOpenPlan: name of a wrong JSON type → 400 BAD_REQUEST | AC-F-011 | REQ-F-011 | `renameOpenPlan` | T-23 | 501: generatePlan |
| 150 | selection_structure | BDD-007 AC-F-006 AC-F-008 generatePlan getOpenPlan: stages in order, each non-empty, rules satisfied, no repeats, total 3600 s, parameters within limits | BDD-007, AC-F-006, AC-F-008 | REQ-F-005, REQ-F-006, REQ-F-008 | `generatePlan`, `getOpenPlan` | T-19 | 501: generatePlan |
| 151 | selection_structure | AC-F-006 D-06 D-11 generatePlan: seed {1, 7, 42, 2026, 31337} — every variant satisfies the rules; no decoy, no ineligible variant var-1 of sel-two-variants; emphasis is not required for warm-up and cool-down (×5) | AC-F-006 | REQ-F-006 | `generatePlan` | T-19 | 501: generatePlan |
| 152 | selection_structure | AC-F-006 AC-F-008 D-11 generatePlan: seed {1, 7, 42, 2026, 31337}, 1 h 0 min — rules, structure and parameter limits hold (×5) | AC-F-006, AC-F-008 | REQ-F-006, REQ-F-008 | `generatePlan` | T-19 | 501: generatePlan |
| 153 | selection_structure | AC-F-006 AC-F-008 D-11 generatePlan: seed {1, 7, 42, 2026, 31337}, 1 h 30 min — rules, structure and parameter limits hold (×5) | AC-F-006, AC-F-008 | REQ-F-006, REQ-F-008 | `generatePlan` | T-19 | 501: generatePlan |
| 154 | selection_structure | AC-NF-006 D-11 generatePlan: seed {1, 7, 42, 2026, 31337} gives the same composition in two fresh applications (×5) | AC-NF-006 | REQ-NF-006 | `generatePlan` | T-19 | 501: generatePlan |
| 155 | tolerance_impossibility | BDD-010 AC-F-008 generatePlan: the only candidate of 3239 s for 1 h 0 min is rejected | BDD-010, AC-F-008 | REQ-F-008 | `generatePlan` | T-20 | 501: generatePlan |
| 156 | tolerance_impossibility | BDD-010 AC-F-008 generatePlan: the only candidate of 3240 s for 1 h 0 min is accepted | BDD-010, AC-F-008 | REQ-F-008 | `generatePlan` | T-20 | 501: generatePlan |
| 157 | tolerance_impossibility | BDD-010 AC-F-008 generatePlan: the only candidate of 3960 s for 1 h 0 min is accepted | BDD-010, AC-F-008 | REQ-F-008 | `generatePlan` | T-20 | 501: generatePlan |
| 158 | tolerance_impossibility | BDD-010 AC-F-008 generatePlan: the only candidate of 3961 s for 1 h 0 min is rejected | BDD-010, AC-F-008 | REQ-F-008 | `generatePlan` | T-20 | 501: generatePlan |
| 159 | tolerance_impossibility | AC-F-008 D-11 generatePlan: seed {1, 7, 42, 2026, 31337}, 0 h 45 min — 0.9·D ≤ total ≤ 1.1·D by exact seconds, parameters within [min; max] (×5) | AC-F-008 | REQ-F-008 | `generatePlan` | T-20 | 501: generatePlan |
| 160 | tolerance_impossibility | AC-F-008 D-11 generatePlan: seed {1, 7, 42, 2026, 31337}, 1 h 0 min — 0.9·D ≤ total ≤ 1.1·D by exact seconds, parameters within [min; max] (×5) | AC-F-008 | REQ-F-008 | `generatePlan` | T-20 | 501: generatePlan |
| 161 | tolerance_impossibility | AC-F-008 D-11 generatePlan: seed {1, 7, 42, 2026, 31337}, 1 h 30 min — 0.9·D ≤ total ≤ 1.1·D by exact seconds, parameters within [min; max] (×5) | AC-F-008 | REQ-F-008 | `generatePlan` | T-20 | 501: generatePlan |
| 162 | tolerance_impossibility | BDD-038 D-10 AC-F-008 generatePlan: recommended values exceed 3960 s, the plan is reduced into 3240–3960 s and no parameter is below the minimum of its variant | BDD-038, AC-F-008 | REQ-F-008 | `generatePlan` | T-20 | 501: generatePlan |
| 163 | tolerance_impossibility | BDD-039 D-10 NEG-10 AC-F-009 generatePlan: even the minimum volume exceeds 3960 s → 422 PLAN_GENERATION_IMPOSSIBLE, no plan | BDD-039, AC-F-009, NEG-10 | REQ-F-009 | `generatePlan` | T-20 | 501: generatePlan |
| 164 | tolerance_impossibility | BDD-012 NEG-09 AC-F-009 generatePlan: maximum volume of all eligible variants is 80 min for 2 h 0 min → 422 PLAN_GENERATION_IMPOSSIBLE without exceeding limits or duplicating variants | BDD-012, AC-F-009, NEG-09 | REQ-F-008, REQ-F-009 | `generatePlan` | T-20 | 501: generatePlan |
| 165 | tolerance_impossibility | BDD-011 NEG-08 AC-F-009 generatePlan: no exercises for the cool-down → 422 PLAN_GENERATION_IMPOSSIBLE, no incomplete plan | BDD-011, AC-F-009, NEG-08 | REQ-F-009 | `generatePlan` | T-20 | 501: generatePlan |
| 166 | tolerance_impossibility | BDD-040 D-25 AC-F-009 generatePlan: 2.999 s after the start the search goes on — the limit is not reported before 3.000 s | BDD-040, AC-F-009 | REQ-F-009 | `generatePlan` | T-20 | 501: generatePlan |
| 167 | tolerance_impossibility | BDD-040 D-13 D-25 NEG-12 AC-F-009 generatePlan: at 3.000 s the search stops → 503 GENERATION_SEARCH_LIMIT_REACHED with limitSeconds 3, different from proven impossibility; no open plan | BDD-040, AC-F-009, NEG-12 | REQ-F-009 | `generatePlan` | T-20 | 501: generatePlan |
| 168 | duration | BDD-008 AC-F-007 addOpenPlanItem: 3 rounds × 180 s with 60 s rest → 660 s | BDD-008, AC-F-007 | REQ-F-007 | `addOpenPlanItem` | T-18 | 501: generatePlan |
| 169 | duration | BDD-009 AC-F-007 addOpenPlanItem: 3 sets × 10 repetitions × 3 s with 30 s rest → 150 s | BDD-009, AC-F-007 | REQ-F-007 | `addOpenPlanItem` | T-18 | 501: generatePlan |
| 170 | duration | AC-F-007 addOpenPlanItem getOpenPlan: the two elements together add 810 s to the plan | AC-F-007 | REQ-F-007 | `addOpenPlanItem`, `getOpenPlan` | T-18 | 501: generatePlan |
| 171 | duration | AC-F-007 BDD-008 BDD-009 generatePlan: seed {1, 7, 42, 2026, 31337} — each element and the plan total are computed by the formulas of §5.4 (×5) | BDD-008, BDD-009, AC-F-007 | REQ-F-007 | `generatePlan` | T-18 | 501: generatePlan |
| 172 | duration | BDD-022 AC-F-007 updateOpenPlanItem: total 5429 s is returned as exact seconds, not rounded to minutes | BDD-022, AC-F-007 | REQ-F-007 | `updateOpenPlanItem` | T-18 | 501: generatePlan |
| 173 | duration | AC-F-007 AC-F-010 updateOpenPlanItem: tolerance uses the exact time — 3239 s gives DURATION_OUT_OF_TOLERANCE although it rounds to 54 min | AC-F-007, AC-F-010 | REQ-F-007, REQ-F-010 | `updateOpenPlanItem` | T-18 | 501: generatePlan |
| 174 | duration | AC-F-007 AC-F-010 updateOpenPlanItem: 3240 s and 3960 s are inside the tolerance, 3961 s is outside | AC-F-007, AC-F-010 | REQ-F-007, REQ-F-010 | `updateOpenPlanItem` | T-18 | 501: generatePlan |
| 175 | generation_parameters | BDD-006 NEG-04 AC-F-005 generatePlan: 0 h 0 min → 422 VALIDATION_FAILED, no open plan | BDD-006, AC-F-005, NEG-04 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 176 | generation_parameters | BDD-006 NEG-32 AC-F-005 generatePlan: -1 h 30 min → 422 VALIDATION_FAILED, no open plan | BDD-006, AC-F-005, NEG-32 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 177 | generation_parameters | BDD-006 AC-F-005 generatePlan: 1 h -10 min → 422 VALIDATION_FAILED, no open plan | BDD-006, AC-F-005 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 178 | generation_parameters | BDD-006 AC-F-005 generatePlan: 0 h 60 min → 422 VALIDATION_FAILED, no open plan | BDD-006, AC-F-005 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 179 | generation_parameters | AC-F-005 generatePlan: missing targetDuration → 422 VALIDATION_FAILED | AC-F-005 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 180 | generation_parameters | NEG-33 AC-F-005 generatePlan: missing level → 422 VALIDATION_FAILED | AC-F-005, NEG-33 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 181 | generation_parameters | AC-F-005 generatePlan: missing emphasis → 422 VALIDATION_FAILED | AC-F-005 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 182 | generation_parameters | AC-F-005 generatePlan: missing availableEquipment → 422 VALIDATION_FAILED | AC-F-005 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 183 | generation_parameters | AC-F-005 generatePlan: missing intensity → 422 VALIDATION_FAILED | AC-F-005 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 184 | generation_parameters | AC-F-005 generatePlan: non-integer hours → 422 VALIDATION_FAILED | AC-F-005 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 185 | generation_parameters | NEG-01 AC-F-005 generatePlan: hours as a JSON string → 400 BAD_REQUEST | AC-F-005, NEG-01 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 186 | generation_parameters | NEG-01 AC-F-005 generatePlan: malformed JSON → 400 BAD_REQUEST | AC-F-005, NEG-01 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 187 | generation_parameters | POS-09 AC-F-005 generatePlan getOpenPlan: 1 h 30 min is converted to 5400 s with tolerance 4860–5940 s; the open plan keeps the five parameters, has no name and no source plan | AC-F-005, POS-09 | REQ-F-005 | `generatePlan`, `getOpenPlan` | T-17 | 501: generatePlan |
| 188 | generation_parameters | AC-F-005 generatePlan: 0 h 45 min is converted to 2700 s (tolerance 2430–2970 s) | AC-F-005 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 189 | generation_parameters | AC-F-005 generatePlan: empty list of equipment is accepted and only variants without equipment are selected | AC-F-005 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
| 190 | session_finish | BDD-016 POS-27 POS-30 NEG-25 AC-F-013 updateExecutedPlanItem completeTraining listCompletedTrainings getCurrentSession startCurrentSession: started at 18:00, refined sets and a note → one record with 18:00, the refined plan and the note; the session is no longer current; a repeated completion creates no second record; another training can be started | BDD-016, AC-F-013, POS-27, POS-30, NEG-25 | REQ-F-012, REQ-F-013, REQ-F-014 | `updateExecutedPlanItem`, `completeTraining`, `listCompletedTrainings`, `getCurrentSession`, `startCurrentSession` | T-25 | 501: generatePlan |
| 191 | session_finish | POS-31 AC-F-013 completeTraining: without a note (body {}) → the record has note null | AC-F-013, POS-31 | REQ-F-013 | `completeTraining` | T-25 | 501: generatePlan |
| 192 | session_finish | POS-31 AC-F-013 completeTraining: without a note (note null) → the record has note null | AC-F-013, POS-31 | REQ-F-013 | `completeTraining` | T-25 | 501: generatePlan |
| 193 | session_finish | POS-31 AC-F-013 completeTraining: without a note (no body (requestBody is optional)) → the record has note null | AC-F-013, POS-31 | REQ-F-013 | `completeTraining` | T-25 | 501: generatePlan |
| 194 | session_finish | BDD-029 AC-F-013 completeTraining: 90 minutes after the start of a 1 h plan the result is saved | BDD-029, AC-F-013 | REQ-F-013 | `completeTraining` | T-25 | 501: generatePlan |
| 195 | session_finish | NEG-25 AC-F-013 completeTraining: no current session → 409 NO_CURRENT_SESSION | AC-F-013, NEG-25 | REQ-F-013 | `completeTraining` | T-25 | 501: completeTraining |
| 196 | session_finish | AC-F-013 completeTraining: note of a wrong JSON type → 400 BAD_REQUEST, the session stays current | AC-F-013 | REQ-F-013 | `completeTraining` | T-25 | 501: generatePlan |
| 197 | session_finish | BDD-047 D-19 AC-F-013 updateExecutedPlanItem: 7 rounds above the variant maximum 5 are accepted; 0 rounds are rejected; there is no operation to add exercises to the executed plan | BDD-047, AC-F-013 | REQ-F-013 | `updateExecutedPlanItem` | T-25 | 501: generatePlan |
| 198 | session_finish | NEG-34 zero sets: updateExecutedPlanItem → 422 VALIDATION_FAILED, session unchanged | NEG-34 | REQ-F-013 | `updateExecutedPlanItem` | T-25 | 501: generatePlan |
| 199 | session_finish | AC-F-013 D-19 zero repetitions: updateExecutedPlanItem → 422 VALIDATION_FAILED, session unchanged | AC-F-013 | REQ-F-013 | `updateExecutedPlanItem` | T-25 | 501: generatePlan |
| 200 | session_finish | AC-F-013 D-19 zero interval: updateExecutedPlanItem → 422 VALIDATION_FAILED, session unchanged | AC-F-013 | REQ-F-013 | `updateExecutedPlanItem` | T-25 | 501: generatePlan |
| 201 | session_finish | AC-F-013 D-19 negative rest: updateExecutedPlanItem → 422 VALIDATION_FAILED, session unchanged | AC-F-013 | REQ-F-013 | `updateExecutedPlanItem` | T-25 | 501: generatePlan |
| 202 | session_finish | AC-F-013 D-19 non-integer rounds: updateExecutedPlanItem → 422 VALIDATION_FAILED, session unchanged | AC-F-013 | REQ-F-013 | `updateExecutedPlanItem` | T-25 | 501: generatePlan |
| 203 | session_finish | AC-F-013 D-19 field of the other mode (rounds for repetitions): updateExecutedPlanItem → 422 VALIDATION_FAILED, session unchanged | AC-F-013 | REQ-F-013 | `updateExecutedPlanItem` | T-25 | 501: generatePlan |
| 204 | session_finish | AC-F-013 D-08 D-19 repetitionTimeSeconds: updateExecutedPlanItem → 422 VALIDATION_FAILED, session unchanged | AC-F-013 | REQ-F-013 | `updateExecutedPlanItem` | T-25 | 501: generatePlan |
| 205 | session_finish | AC-F-013 D-19 stage outside the allowed fields: updateExecutedPlanItem → 422 VALIDATION_FAILED, session unchanged | AC-F-013 | REQ-F-013 | `updateExecutedPlanItem` | T-25 | 501: generatePlan |
| 206 | session_finish | AC-F-013 D-19 position outside the allowed fields: updateExecutedPlanItem → 422 VALIDATION_FAILED, session unchanged | AC-F-013 | REQ-F-013 | `updateExecutedPlanItem` | T-25 | 501: generatePlan |
| 207 | session_finish | POS-28 D-19 AC-F-013 deleteExecutedPlanItem: the exercise is removed from the executed plan; the open plan is unchanged | AC-F-013, POS-28 | REQ-F-013 | `deleteExecutedPlanItem` | T-25 | 501: generatePlan |
| 208 | session_finish | NEG-30 AC-F-013 deleteExecutedPlanItem updateExecutedPlanItem: unknown element → 404 NOT_FOUND | AC-F-013, NEG-30 | REQ-F-013 | `deleteExecutedPlanItem`, `updateExecutedPlanItem` | T-25 | 501: generatePlan |
| 209 | session_finish | AC-F-013 deleteExecutedPlanItem updateExecutedPlanItem: no current session → 404 NO_CURRENT_SESSION | AC-F-013 | REQ-F-013 | `deleteExecutedPlanItem`, `updateExecutedPlanItem` | T-25 | 501: deleteExecutedPlanItem |
| 210 | session_finish | BDD-026 POS-29 AC-F-013 abortCurrentSession: a session from a saved plan with changed parameters and a deleted exercise is closed; changes are discarded; history, analytics for the period and the saved plan are unchanged; another training can be started | BDD-026, AC-F-013, POS-29 | REQ-F-012, REQ-F-013, REQ-F-016 | `abortCurrentSession` | T-25 | 501: generatePlan |
| 211 | session_finish | D-17 AC-F-012 AC-F-013 abortCurrentSession: a plan started unsaved is not saved automatically | AC-F-012, AC-F-013 | REQ-F-012, REQ-F-013 | `abortCurrentSession` | T-25 | 501: generatePlan |
| 212 | session_finish | BDD-028 NEG-26 AC-F-013 deleteExecutedPlanItem completeTraining abortCurrentSession: with all executed exercises deleted the completion is rejected (422 EXECUTED_PLAN_EMPTY) and the session stays; the abort closes it without a record; another training can be started | BDD-028, AC-F-013, NEG-26 | REQ-F-013 | `deleteExecutedPlanItem`, `completeTraining`, `abortCurrentSession` | T-25 | 501: generatePlan |
| 213 | session_finish | NEG-31 AC-F-013 abortCurrentSession: no current session → 404 NO_CURRENT_SESSION | AC-F-013, NEG-31 | REQ-F-013 | `abortCurrentSession` | T-25 | 501: abortCurrentSession |
| 214 | session_start | POS-25 POS-26 BDD-045 D-17 AC-F-012 startCurrentSession getCurrentSession: start from an unsaved generated plan at 18:00 — start time, local start date, executed plan is a working copy; Location; the plan is not saved automatically | BDD-045, AC-F-012, POS-25, POS-26 | REQ-F-012 | `startCurrentSession`, `getCurrentSession` | T-24 | 501: generatePlan |
| 215 | session_start | D-17 AC-F-012 openSavedPlan startCurrentSession: a training starts from an opened saved plan | AC-F-012 | REQ-F-012 | `openSavedPlan`, `startCurrentSession` | T-24 | 501: generatePlan |
| 216 | session_start | BDD-025 NEG-23 AC-F-012 startCurrentSession getCurrentSession: a repeated start of another plan B → 409 SESSION_ALREADY_ACTIVE; session A and its data are not overwritten | BDD-025, AC-F-012, NEG-23 | REQ-F-012 | `startCurrentSession`, `getCurrentSession` | T-24 | 501: generatePlan |
| 217 | session_start | AC-F-012 startCurrentSession: an empty open plan → 422 PLAN_EMPTY, no session | AC-F-012 | REQ-F-012 | `startCurrentSession` | T-24 | 501: generatePlan |
| 218 | session_start | AC-F-012 startCurrentSession: unknown open plan → 422 OPEN_PLAN_NOT_FOUND | AC-F-012 | REQ-F-012 | `startCurrentSession` | T-24 | 501: startCurrentSession |
| 219 | session_start | NEG-24 D-18 getCurrentSession: no current session → 404 NO_CURRENT_SESSION | NEG-24 | REQ-F-012 | `getCurrentSession` | T-24 | 501: getCurrentSession |
| 220 | session_start | BDD-046 D-18 CON-007 AC-F-012 getCurrentSession listCompletedTrainings getAnalytics: after a restart there is no current session; history and analytics are unchanged | BDD-046, AC-F-012 | REQ-F-012 | `getCurrentSession`, `listCompletedTrainings`, `getAnalytics` | T-24 | 501: listCompletedTrainings |
| 221 | session_start | BDD-019 AC-F-012 listCompletedTrainings: until completion the current session is not in the history | BDD-019, AC-F-012 | REQ-F-012, REQ-F-016 | `listCompletedTrainings` | T-24 | 501: generatePlan |
| 222 | session_start | AC-F-012 startCurrentSession updateOpenPlanItem updateExecutedPlanItem: the executed plan is a copy independent of the open plan | AC-F-012 | REQ-F-012 | `startCurrentSession`, `updateOpenPlanItem`, `updateExecutedPlanItem` | T-24 | 501: generatePlan |
| 223 | session_start | AC-F-012 generatePlan openSavedPlan: a current session does not block generation or opening a plan | AC-F-012 | REQ-F-012 | `generatePlan`, `openSavedPlan` | T-24 | 501: generatePlan |
| 224 | analytics | BDD-018 POS-35 AC-F-015 AC-F-016 getAnalytics: T1 on 1 June, T2 on 30 June, T3 on 1 July; E1 twice in T1 and once in T2; period 1–30 June → 2 trainings, sum of days 2, frequency of E1 = 2, T3 not counted | BDD-018, AC-F-015, AC-F-016, POS-35 | REQ-F-015, REQ-F-016 | `getAnalytics` | T-27 | 501: generatePlan |
| 225 | analytics | AC-F-016 getAnalytics getCompletedTraining: the frequency of each exercise equals the number of trainings of the period that contain its id | AC-F-016 | REQ-F-016 | `getAnalytics`, `getCompletedTraining` | T-27 | 501: generatePlan |
| 226 | analytics | AC-F-016 getAnalytics: several inclusions and different variants of one exercise in one training are counted once | AC-F-016 | REQ-F-016 | `getAnalytics` | T-27 | 501: generatePlan |
| 227 | analytics | BDD-049 D-22 AC-F-016 getAnalytics: a day without trainings is shown with 0; E1 renamed between T1 and T2 is counted twice under the name from the newest training of the period | BDD-049, AC-F-016 | REQ-F-016 | `getAnalytics` | T-27 | 501: createExercise |
| 228 | analytics | AC-F-015 getAnalytics: the day is the local start date fixed at the start, not the completion date | AC-F-015 | REQ-F-015 | `getAnalytics` | T-27 | 501: generatePlan |
| 229 | analytics | BDD-019 AC-F-016 startCurrentSession getAnalytics: a current unfinished session is not included in the indicators of its period | BDD-019, AC-F-016 | REQ-F-012, REQ-F-016 | `startCurrentSession`, `getAnalytics` | T-27 | 501: generatePlan |
| 230 | analytics | BDD-020 POS-36 AC-F-016 getAnalytics: no completed trainings → count 0, every day with 0, empty frequencies | BDD-020, AC-F-016, POS-36 | REQ-F-014, REQ-F-016 | `getAnalytics` | T-27 | 501: getAnalytics |
| 231 | analytics | BDD-026 AC-F-013 AC-F-016 abortCurrentSession getAnalytics: an aborted session does not change the indicators | BDD-026, AC-F-013, AC-F-016 | REQ-F-012, REQ-F-013, REQ-F-016 | `abortCurrentSession`, `getAnalytics` | T-27 | 501: generatePlan |
| 232 | analytics | BDD-030 AC-F-015 getAnalytics: without a range on 30 June 2026 the period is 1–30 June inclusive (today and 29 previous days) | BDD-030, AC-F-015 | REQ-F-015 | `getAnalytics` | T-27 | 501: getAnalytics |
| 233 | analytics | BDD-030 NEG-27 AC-F-015 getAnalytics: start after the end → 422 INVALID_PERIOD | BDD-030, AC-F-015, NEG-27 | REQ-F-015 | `getAnalytics` | T-27 | 501: getAnalytics |
| 234 | analytics | BDD-030 NEG-28 D-35 AC-F-015 getAnalytics: only the start → 422 INVALID_PERIOD | BDD-030, AC-F-015, NEG-28 | REQ-F-015 | `getAnalytics` | T-27 | 501: getAnalytics |
| 235 | analytics | BDD-030 D-35 AC-F-015 getAnalytics: only the end → 422 INVALID_PERIOD | BDD-030, AC-F-015 | REQ-F-015 | `getAnalytics` | T-27 | 501: getAnalytics |
| 236 | analytics | BDD-048 NEG-29 D-21 AC-F-015 getAnalytics: on 30 June 2026 the period 1 June – 1 July → 422 END_DATE_IN_FUTURE | BDD-048, AC-F-015, NEG-29 | REQ-F-015 | `getAnalytics` | T-27 | 501: getAnalytics |
| 237 | analytics | D-21 AC-F-015 getAnalytics: the end date equal to today is accepted; bounds are inclusive | AC-F-015 | REQ-F-015 | `getAnalytics` | T-27 | 501: generatePlan |
| 238 | analytics | D-21 AC-F-015 getAnalytics: the length of the range is not limited | AC-F-015 | REQ-F-015 | `getAnalytics` | T-27 | 501: getAnalytics |
| — | — | API-тесту немає: відхилення підтвердження припинення — дія клієнта, запит не надсилається | BDD-027, AC-F-013 | REQ-F-013 | — | T-25 | клієнт, поза ЛР-5 (рішення людини 13.11.2026, питання 14) |

Примітка до таблиці: колонка «Червоний запуск» — операція, що першою відповіла 501 у тесті (для більшості тестів це передумова, наприклад `generatePlan`). REQ-NF-006 / AC-NF-006 покриває також простежуваність і FakeClock / SeededRandom у всіх тестах.

**Питання до специфікації (передано людині):**
1. Таблиці «тікет → operationId» етапу 1 у журналі немає. Відповідність у таблиці вище виведено з docs/plan/decomposition.md і docs/api/req-api-traceability.md. Чи збігається вона з погодженою?
2. `details[]`: контракт задає `constraint` лише в прикладах (MIN_LE_MAX, MINIMUM, WITHIN_VARIANT_RANGE, NOT_EDITABLE, TOTAL_GREATER_THAN_ZERO, DICTIONARY_VALUE, NOT_AFTER_TO, REQUIRED_WITH_FROM, NOT_AFTER_TODAY, INVALID_JSON). Тести вимагають:
   - `field` — за конвенцією шляхів прикладів (`variants[0].rounds.min`, `parameters.rounds`, `targetDuration.hours`, `name`, `videoUrl`);
   - `constraint` — лише там, де відповідне правило є в прикладі: MINIMUM застосовано до порушень `minimum` і поза виконаним планом (`variants[0].rounds.min = 0`, `targetDuration.hours = -1`);
   - для `maximum` (хвилини 60), рекомендованого поза діапазоном, не-HTTPS, нецілого значення — лише `field`;
   - «задано лише кінець періоду» — лише `code` INVALID_PERIOD: аналога REQUIRED_WITH_FROM для поля `from` у контракті немає.
   Чи прийнятна така строгість?
3. STAGE_NOT_IN_EXERCISE: AC-F-010 — «якщо воно відображається», тобто необов'язкове; приклади контракту його містять. Тести його наявності не вимагають (POS-14, BDD-023).
4. FILTER_MISMATCH за акцентом для розминки й заминки (де акцент не є правилом відбору, §5.1) не визначено. Тести цього випадку уникають: у фікстурі BDD-007 акценти збігаються, попередження фікстури `selection-rules` не перевіряються.
5. `PlanItemParametersInput` у `addOpenPlanItem` і `replaceOpenPlanItem` — усі поля необов'язкові; значення відсутніх полів не визначено. Тести завжди передають усі поля режиму.
6. Невідомі значення довідників у тілі `createExercise` і `generatePlan` (VALIDATION_FAILED, UNKNOWN_DICTIONARY_VALUE чи PLAN_GENERATION_IMPOSSIBLE?) і поле іншого режиму у варіанті вправи (`TimeVariantFields` без `additionalProperties: false`) не визначено — не тестується.
7. `renameOpenPlan` без `name`: 422 для операції не оголошено, лише 400. `getDictionary` з невідомою назвою, формат дати в query (`from=2026-13-01`) — 400 чи 422 / 404, не визначено. Не тестується.
8. BDD-040: тест вимагає, щоб генератор читав годинник під час пошуку ще до того, як доведе неможливість перебором. Фікстура `bdd-040-search-limit` не дає неможливості, доведеної межами обсягу. Для 2,999 с прийнятні 422 PLAN_GENERATION_IMPOSSIBLE (доведено перебором) і 503 лише після читання ≥ 3,000 с; для 3,000 с — лише 503 з `limitSeconds: 3`.
9. `Location`: для `addOpenPlanItem` тест вимагає `/open-plans/{openPlanId}/items/{itemId}` (створений ресурс — елемент; приклад заголовка в контракті загальний — `/open-plans/open-1`). Для `startCurrentSession` — `/current-session`, для решти — URI ресурсу з тіла.
10. `replaceOpenPlanItem` зберігає `id` елемента (приклад `item-3`) — тест це вимагає. Ідентичність id елементів між відкритим, збереженим, виконаним планом і записом історії тести не вимагають, порівнюють склад без id.
11. Змодельований збій запису (AC-NF-003, BDD-021): файл БД лише для читання після перезапуску. Припущення: режим журналу SQLite за замовчуванням (не WAL) і відсутність запису під час засівання, якщо версія каталогу не змінилася. Чи погоджується спосіб? Тестових ендпоінтів немає (рішення 5 етапу 1).
12. `deleteTrainingPlan` 500 STORAGE_WRITE_FAILED перевірено за контрактом; AC-NF-003 говорить лише про збереження плану й завершеного тренування.
13. `createExercise`: id з тіла ігнорується — тест вимагає `id ≠ 'ex-1'`, префікс `custom-` (рішення 3 етапу 5) не перевіряється, бо не є джерелом тестів.
14. BDD-027 (відхилення підтвердження припинення) — без API-тесту: операції немає.
15. Додаткові фікстури поза переліком етапу 5: `selection-rules`, `bdd-010-tolerance-bounds`, `duration-tunable`. Значення — тестові дані `[TEST]` для перевірки правил, а не межі навантаження (CON-005). Потрібне погодження на TEST-GATE.
16. Лог при паралельному запуску тестів: ізоляти одного процесу пошкоджують спільний файл (`FileMode.append` не атомарний). Контрольні запуски — з `--concurrency=1`; src/ не змінено. Сервер (один ізолят) це не зачіпає.
17. Тест покриття «never 501» читає перший приклад `requestBody` контракту і шляхові параметри `coverage-<name>`, тож після реалізації частина відповідей буде 404/422. Це навмисно: перевіряється лише «статус оголошено і не 501».
18. Сирий вивід `dart test --reporter json` зберігається поза репозиторієм. Зберегти його в logs/app/ (наприклад через `--file-reporter json:…`)?

**Повний діалог:** не збережено агентом
**Рішення людини (13.11.2026):**
1. Питання 1, 2, 8, 11 — погоджено, як запропоновано.
2. Питання 15: фікстуру залишити, лише якщо на неї посилається тест з ID BDD / AC / NEG, інакше видалити. Перевірка агента (`grep` у tests/test/): `selection-rules` — тести AC-F-006 (T-19), `bdd-010-tolerance-bounds` — тести BDD-010 (T-20), `duration-tunable` — тести BDD-022, AC-F-007, AC-F-010 (T-18) і BDD-014 (T-23). Видаляти нічого не потрібно.
3. Питання 18: вивід репортера зберегти як logs/app/control-red-20261113.jsonl, red_check.py — у tests/tool/ (для повторної перевірки рецензентом TEST-GATE). Інші скрипти (`fixture_check.py`, `filter_check.py`, `trace.py`) у репозиторій не переносяться.
4. Тести запускаються лише з concurrency 1 — зафіксовано в tests/dart_test.yaml.
5. Серію комітів 1–7 погоджено; tests/dart_test.yaml і tests/tool/red_check.py — у коміт 1, control-red-20261113.jsonl — у коміт 7; без трейлерів.
6. Питання 3–7, 9–10, 12–14, 16–17 — відкриті, людина відповість окремо.

**Коміти (хеші з `git log --oneline`):**
1. `5e4e4ca` test: [agent] T-11–T-27 test support, contract validator and operation coverage test
2. `dbdb8fe` test: [agent] T-11, T-13, T-14 exercises, variants and dictionaries tests
3. `42485a7` test: [agent] T-17, T-18, T-19, T-20 plan generation tests
4. `576615b` test: [agent] T-12, T-22, T-23 open plans, items and training plans tests
5. `a1f6daf` test: [agent] T-24, T-25, T-26 current session, executed plan and completed trainings tests
6. `4096c06` test: [agent] T-27 analytics tests
7. docs: [agent] red run log and lab 5 session log, stage 7 — цей запис журналу, logs/app/control-red-20261113.log і .jsonl.

**Рішення людини щодо решти питань етапу 7 (13.11.2026):**
- 3. STAGE_NOT_IN_EXERCISE не вимагається (AC-F-010 «якщо воно відображається») — погоджено.
- 4. FILTER_MISMATCH за акцентом для розминки й заминки не перевіряється — погоджено.
- 5. Відсутні поля `PlanItemParametersInput` не перевіряються — погоджено. Прогалина специфікації, статус «Відкладено».
- 6. Невідомі значення довідників у тілах `createExercise` / `generatePlan` і поле іншого режиму у варіанті вправи не перевіряються — погоджено. Статус «Відкладено».
- 7. `renameOpenPlan` без `name`, `getDictionary` з невідомою назвою, некоректна дата в query не перевіряються — погоджено. Статус «Відкладено».
- Для випадків 5–7 реалізація відповідає лише статусами й кодами, оголошеними в контракті для операції; нових кодів не вводити.
- 9. `Location`: для `addOpenPlanItem` — URI створеного елемента, для `startCurrentSession` — `/current-session` — погоджено.
- 10. `replaceOpenPlanItem` зберігає `id` елемента (приклад контракту); ідентичність id між копіями не перевіряється — погоджено.
- 12. 500 STORAGE_WRITE_FAILED для `deleteTrainingPlan` — погоджено (оголошено в контракті).
- 13. Префікс `custom-` не перевіряється — погоджено.
- 14. BDD-027 — дія клієнта, API-тесту немає. У таблиці простежуваності додано рядок із позначкою «клієнт, поза ЛР-5» — погоджено.
- 16. Тести запускаються лише з concurrency 1 — погоджено (зафіксовано в tests/dart_test.yaml).
- 17. Тест «never 501» перевіряє лише «статус оголошено і не 501» — погоджено.
- Тести не змінювалися. Усі питання етапу 7 закрито (1, 2, 8, 11, 15, 18 — попереднім рішенням 13.11.2026).
