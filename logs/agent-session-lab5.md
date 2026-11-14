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
- Звірка покриття скриптом за decomposition.md: усі BDD і AC тікетів обсягу мають тест (повне в межах API-обсягу: форматування відображення тривалості, BDD-022 і AC-F-007 пп. 4, 6, 7, — клієнтська частина T-18 поза обсягом ЛР-5; рішення людини 13.11.2026, TEST-GATE, TG-001). BDD-007 (T-20), BDD-014 (T-22), BDD-023 (T-23), BDD-017 (T-25) перевірено в тестах сусіднього тікета (вказано в таблиці). BDD-027 не має операції API: відхилення підтвердження — дія клієнта, запит не надсилається (`abortCurrentSession`: «ознаки підтвердження в API немає»).
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
| 239 | manual_editing | BDD-032 AC-F-010 addOpenPlanItem: ex-1/var-1 every parameter = min (1 round, 60 s, rest 30 s) → 201, parameters saved, duration 60 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 240 | manual_editing | BDD-032 AC-F-010 addOpenPlanItem: ex-1/var-1 every parameter = max (5 rounds, 300 s, rest 120 s) → 201, parameters saved, duration 1980 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 241 | manual_editing | BDD-032 AC-F-010 addOpenPlanItem: ex-3/var-1 every parameter = min (1 set, 5 repetitions, rest 0 s) → 201, parameters saved, duration 15 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 242 | manual_editing | BDD-032 AC-F-010 addOpenPlanItem: ex-3/var-1 every parameter = max (5 sets, 20 repetitions, rest 60 s) → 201, parameters saved, duration 540 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 243 | manual_editing | BDD-032 AC-F-010 replaceOpenPlanItem: ex-1/var-1 every parameter = min (1 round, 60 s, rest 30 s) → 200, parameters saved, duration 60 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `replaceOpenPlanItem` | T-22 | 501: generatePlan |
| 244 | manual_editing | BDD-032 AC-F-010 replaceOpenPlanItem: ex-1/var-1 every parameter = max (5 rounds, 300 s, rest 120 s) → 200, parameters saved, duration 1980 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `replaceOpenPlanItem` | T-22 | 501: generatePlan |
| 245 | manual_editing | BDD-032 AC-F-010 replaceOpenPlanItem: ex-3/var-1 every parameter = min (1 set, 5 repetitions, rest 0 s) → 200, parameters saved, duration 15 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `replaceOpenPlanItem` | T-22 | 501: generatePlan |
| 246 | manual_editing | BDD-032 AC-F-010 replaceOpenPlanItem: ex-3/var-1 every parameter = max (5 sets, 20 repetitions, rest 60 s) → 200, parameters saved, duration 540 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `replaceOpenPlanItem` | T-22 | 501: generatePlan |
| 247 | manual_editing | BDD-032 AC-F-010 updateOpenPlanItem getOpenPlan: ex-1/var-1 every parameter = min (1 round, 60 s, rest 30 s) → 200, parameters saved, duration 60 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `getOpenPlan`, `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 248 | manual_editing | BDD-032 AC-F-010 updateOpenPlanItem getOpenPlan: ex-1/var-1 every parameter = max (5 rounds, 300 s, rest 120 s) → 200, parameters saved, duration 1980 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `getOpenPlan`, `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 249 | manual_editing | BDD-032 AC-F-010 updateOpenPlanItem getOpenPlan: ex-3/var-1 every parameter = min (1 set, 5 repetitions, rest 0 s) → 200, parameters saved, duration 15 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `getOpenPlan`, `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 250 | manual_editing | BDD-032 AC-F-010 updateOpenPlanItem getOpenPlan: ex-3/var-1 every parameter = max (5 sets, 20 repetitions, rest 60 s) → 200, parameters saved, duration 540 s (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `getOpenPlan`, `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 251 | manual_editing | BDD-032 AC-F-010 updateOpenPlanItem: exactly 5 rounds (the variant maximum) for ex-1/var-1 → 200, other parameters unchanged (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 252 | manual_editing | BDD-032 AC-F-010 updateOpenPlanItem: exactly 1 round (the variant minimum) for ex-1/var-1 → 200, other parameters unchanged (TG-002) | BDD-032, AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 253 | manual_editing | AC-F-010 addOpenPlanItem: position of the last element (n − 1) inserts before it, positions stay contiguous (TG-002) | AC-F-010 | REQ-F-010 | `addOpenPlanItem` | T-22 | 501: generatePlan |
| 254 | manual_editing | AC-F-010 updateOpenPlanItem: the first element moved to the last position (n − 1) of its stage, positions stay contiguous (TG-002) | AC-F-010 | REQ-F-010 | `updateOpenPlanItem` | T-22 | 501: generatePlan |
| 255 | exercise_validation | AC-F-002 SRS §5.3 time mode: min = max = recommended = 1 for rounds and interval, 0 for rest (smallest allowed values): createExercise getExercise → 201, saved as entered (TG-002) | AC-F-002 | REQ-F-002 | `createExercise`, `getExercise` | T-11 | 501: createExercise |
| 256 | exercise_validation | AC-F-002 D-08 time mode: recommended = min for every parameter: createExercise getExercise → 201, saved as entered (TG-002) | AC-F-002 | REQ-F-002 | `createExercise`, `getExercise` | T-11 | 501: createExercise |
| 257 | exercise_validation | AC-F-002 D-08 time mode: recommended = max for every parameter: createExercise getExercise → 201, saved as entered (TG-002) | AC-F-002 | REQ-F-002 | `createExercise`, `getExercise` | T-11 | 501: createExercise |
| 258 | exercise_validation | AC-F-002 SRS §5.3 D-08 repetitions mode: min = max = recommended = 1 for sets and repetitions, 0 for rest, repetition time 1 s: createExercise getExercise → 201, saved as entered (TG-002) | AC-F-002 | REQ-F-002 | `createExercise`, `getExercise` | T-11 | 501: createExercise |
| 259 | exercise_validation | AC-F-002 D-08 repetitions mode: recommended = min and = max: createExercise getExercise → 201, saved as entered (TG-002) | AC-F-002 | REQ-F-002 | `createExercise`, `getExercise` | T-11 | 501: createExercise |
| 260 | exercise_validation | AC-F-002 SRS §5.3 time mode: min = max = recommended = 1 for rounds and interval, 0 for rest (smallest allowed values): updateExercise getExercise → 200, saved and returned on reopening (TG-002) | AC-F-002 | REQ-F-002 | `updateExercise`, `getExercise` | T-11 | 501: createExercise |
| 261 | exercise_validation | AC-F-002 D-08 time mode: recommended = min for every parameter: updateExercise getExercise → 200, saved and returned on reopening (TG-002) | AC-F-002 | REQ-F-002 | `updateExercise`, `getExercise` | T-11 | 501: createExercise |
| 262 | exercise_validation | AC-F-002 D-08 time mode: recommended = max for every parameter: updateExercise getExercise → 200, saved and returned on reopening (TG-002) | AC-F-002 | REQ-F-002 | `updateExercise`, `getExercise` | T-11 | 501: createExercise |
| 263 | exercise_validation | AC-F-002 SRS §5.3 D-08 repetitions mode: min = max = recommended = 1 for sets and repetitions, 0 for rest, repetition time 1 s: updateExercise getExercise → 200, saved and returned on reopening (TG-002) | AC-F-002 | REQ-F-002 | `updateExercise`, `getExercise` | T-11 | 501: createExercise |
| 264 | exercise_validation | AC-F-002 D-08 repetitions mode: recommended = min and = max: updateExercise getExercise → 200, saved and returned on reopening (TG-002) | AC-F-002 | REQ-F-002 | `updateExercise`, `getExercise` | T-11 | 501: createExercise |
| 265 | generation_parameters | AC-F-005 generatePlan getOpenPlan: 0 h 1 min (the smallest total above zero) is accepted and converted to 60 s (tolerance 54–66 s) (TG-002) | AC-F-005 | REQ-F-005 | `generatePlan`, `getOpenPlan` | T-17 | 501: generatePlan |
| 266 | generation_parameters | AC-F-005 generatePlan getOpenPlan: 0 h 59 min (minutes at the upper bound 59) is accepted and converted to 3540 s (tolerance 3186–3894 s) (TG-002) | AC-F-005 | REQ-F-005 | `generatePlan`, `getOpenPlan` | T-17 | 501: generatePlan |
| 267 | generation_parameters | AC-F-005 generatePlan: 1 h 0 min (minutes at the lower bound 0) is accepted and converted to 3600 s (tolerance 3240–3960 s) (TG-002) | AC-F-005 | REQ-F-005 | `generatePlan` | T-17 | 501: generatePlan |
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

## Етап 8. T-29: незалежна перевірка тестів для TEST-GATE (API-частина) — 13.11.2026
**Модель:** Claude Sonnet 5.5 (claude-sonnet-5-5), Claude Code у VS Code; нова сесія без контексту етапів 1–7 (автор тестів — Claude Opus 5.5)
**Запити:**
1. Незалежна перевірка тестів для T-29 TEST-GATE (лише API-частина), гілка impl/lab5; у tests/, src/, spec/ нічого не змінювати.
2. Перевірити: умови GO T-29 з plan.md (розділ 1.1) з урахуванням обсягу ЛР-5; виведення кожного тесту зі специфікації (надмірні тести, пропуски); позитивні, негативні й граничні випадки для кожного тікета; відтворюваність червоного запуску (`dart analyze --fatal-infos`, `dart test --file-reporter json:/tmp/red-recheck.jsonl`, `python3 -I tool/red_check.py`, порівняння з logs/app/control-red-20261113.jsonl); час і випадковість лише через FakeClock / SeededRandom, без тестових ендпоінтів.
3. Створити logs/test-gate.md як чернетку за структурою logs/api-gate.md з порожнім «Остаточним рішенням»; додати цей етап; не комітити.

**Пропозиція агента та дії:**
- Прочитано: plan.md (розділ 1.1, 6.4), журнал етапів 1–7, api-gate.md, spec-gate.md (REV-004, REV-009), SRS v1.1 (REQ-F-006…016, §5), BDD-021, 029, 030, 037, 038, 040, фрагменти spec/openapi.yaml, decomposition.md (чек-лист T-29), risks.md, high-risk-requirements.md; тести — вибірково (support/test_app.dart, json.dart, fake_clock.dart, початок operation_coverage_test.dart, група BDD-040, група відтворюваності) і за повними назвами 296 тестів із JSON-виводу. Рядок-в-рядок усі файли тестів не читано.
- Червоний запуск (із `tests/`, лог застосунку — `/tmp/red-recheck-logs/`, у репозиторій не потрапив):
  - `dart analyze --fatal-infos` — «No issues found!»;
  - `dart test` — код виходу 1; `red_check.py` — код виходу 0: 16 наборів, 296 тестів, 293 `failure` (усі — `TestFailure` «status 501 is not declared»), 3 `success` (ті самі три статичні тести, що й у контрольному запуску), «Failed to load» і інших причин — 0;
  - `diff` звітів `red_check.py` для /tmp/red-recheck.jsonl і logs/app/control-red-20261113.jsonl порожній; порівняння двох JSON-виводів скриптом — 296 і 296 тестів, розбіжностей 0.
- Аналіз логу `/tmp/red-recheck-logs/red-recheck.log` (скрипт): 888 записів, нерозібраних 0; INFO — 595, WARNING — 293, ERROR — 0; `app composed` — 302; запитів — 293, усі 501, 27 різних operationId; стеків і винятків немає. Числа збігаються з аналізом етапу 7.
- Скриптом: кожен із 296 тестів має ID (BDD / AC / POS / NEG / D / REV); operationId немає лише в двох статичних тестах AC-NF-006; 0 невідомих ID у назвах; для 14 тікетів обсягу всі BDD і AC з decomposition.md мають тест.
- Час і випадковість: `DateTime.now`, `Stopwatch`, `Future.delayed`, `Timer` у tests/test — 0; `Random(` — лише `seeded_random.dart`; тестових ендпоінтів і заголовків у src/ немає (27 маршрутів). Генератор ID у тестах не підставляється (`Random.secure()` за замовчуванням) — TG-006.
- Дата гейту 13.11.2026; план (§6.4) — 12.01.2027; відхилення −60 днів (скрипт). Стан issues узято з виводу `gh issue list --state all --limit 200 --json number,title,state`: T-02 (#3), T-05…T-10 (#6…#11), T-29 (#30), T-56 (#57), T-57 (#58) — OPEN.
- logs/test-gate.md створено як чернетку: об'єкт перевірки, учасники, дата й відхилення, перевірка умов GO і чек-листа T-29, виведення тестів зі специфікації (надмірні й пропуски), матриця позитивних / негативних / граничних випадків, відтворення червоного запуску, час і випадковість, контроль RISK-19, реєстр TG-001…TG-011, питання до специфікації, порожнє «Остаточне рішення».
- Блокувальних зауважень три: TG-001 (немає тестів відображення «1 год 30 хв» / «1 год 31 хв» для 5400, 5429, 5430, 3599 с — критерій готовності T-18, BDD-022), TG-003 (немає фактичних годин T-02, T-05–T-10 і дати запиту за T-56 для перерахунку календаря; значення не підставлено, RISK-21), TG-010 (три тести пройшли в червоному запуску без рішення людини про виняток). Решта — неблокувальні (TG-002 граничні допустимі значення T-11, T-17, T-22; TG-004 часткове закриття T-29 і T-15 поза обсягом; TG-005 тест збігу складу для одного зерна проти SRS рядка 633; TG-006; TG-007 залежність від `src/assets/catalog/test-catalog.json`; TG-008 закрито рішенням 13.11.2026; TG-009; TG-011).
- tests/, src/, spec/, docs/ не змінено; коміт не створено; GO / REVISE не встановлено.

**Питання до специфікації (передано людині):**
1. SRS рядок 633 («Детермінованість формування не вимагається») проти рядка 980 («з фіксованим зерном результат відтворюваний») і AC-NF-006 («не конкретний склад»): чи може лишитися тест збігу складу для одного зерна (TG-005)?
2. Чи входить текст відображення тривалості («Орієнтовно: 1 год 30 хв») у відповідальність REST API; контракт повертає лише `estimatedDurationSeconds` (TG-001). Зміну `spec/openapi.yaml` без вказівки людини агент не пропонує вносити.

**Повний діалог:** не збережено агентом
**Рішення людини (13.11.2026):**
- TG-001: неблокувальне; відображення тривалості — клієнтська частина T-18 (категорія (в)), поза обсягом ЛР-5; API-частину BDD-022 покрито. Формулювання етапу 7 уточнено: «повне в межах API-обсягу».
- TG-002: прийнято; тести додасть автор тестів в окремій сесії, рецензент перевірить лише додані тести.
- TG-003: неблокувальне; перерахунок календаря не виконується (T-02, T-05–T-09 у ЛР-5 не виконувались, графік визначає дедлайн 15.11.2026; T-56 відкрите, трек К поза ЛР-5, дані [TEST]).
- TG-004: прийнято як наслідок рішення про обсяг. TG-005: тест залишається (AC-F-006 — повторне формування з іншим станом випадковості; відтворюваність за зерном — AC-NF-006, D-11). TG-006: прийнято. TG-007: прийнято, SHA-256 `f29ec0745de79cb8a0d85f3bff27cb72d21d1b3c9de031de4a257f09017e9839` записано в logs/test-gate.md (`shasum -a 256`). TG-008: закрито. TG-009: неблокувальне, інспекція `src/` на верифікації. TG-010: виняток для трьох статичних мета-тестів. TG-011: виправляє людина.
- Питання до специфікації 1 і 2 закрито: тест збігу складу лишається; текст відображення тривалості до REST API не входить.
- Реєстр у logs/test-gate.md оновлено; «Остаточне рішення» порожнє; коміт не створено — очікується перевірка тестів TG-002.

**Перевірка доданих тестів TG-002 (13.11.2026, та сама модель Claude Sonnet 5.5, та сама сесія):**
- Перевірено лише додані тести (`git diff --cached`; зміни проіндексовані, у `git log` коміту з ними не було). У діффі лише додані рядки: наявні тести не змінено.
- Додано 29 тестів: T-11 — 10, T-17 — 3, T-22 — 16. Межі виведено з SRS §5.3, AC-F-005, AC-F-010, §5.4–5.6, D-08, BDD-032; межі варіантів звірено з `src/assets/catalog/test-catalog.json`; для 60 с і 3540 с використано фікстуру `duration-tunable` (арифметику перевірено). Позиція `n` і верхня межа годин не тестуються, бо специфікація їх не визначає — внесено в питання до специфікації 4 і 5 у logs/test-gate.md.
- Червоний запуск: `dart analyze --fatal-infos` чистий; 325 тестів, 322 `failure` (усі `TestFailure` 501), 3 статичні `success`; «Failed to load» і інших причин — 0; `diff` звітів `red_check.py` для /tmp/red-recheck-b.jsonl і logs/app/control-red-20261113b.jsonl порожній; 296 наявних тестів — ті самі результати, 29 нових — усі червоні. Лог `control-red-20261113b.log`: 977 записів, INFO 655, WARNING 322, ERROR 0, 322 запити зі статусом 501.
- TG-002 у logs/test-gate.md — закрито (розділ 8). tests/, src/, spec/ агент не змінював.
- Рішення людини (13.11.2026): TG-011 виправлено комітом `4bbc8ba` — закрито в реєстрі (`git show 4bbc8ba`: заголовок decomposition.md без «(чернетка)»). Питання до специфікації 4 (верхня межа годин) і 5 (позиція `n`): специфікація не визначає, не тестуються, статус «Відкладено». Відкритих зауважень у реєстрі немає. Коміт logs/test-gate.md і журналу відкладено до того, як автор тестів закомітить тести TG-002; файли лишаються проіндексованими, «Остаточне рішення» порожнє.

## Етап 9. TG-002: позитивні граничні тести T-11, T-17, T-22 і повторний червоний запуск — 13.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Зауваження TEST-GATE TG-002 (logs/test-gate.md): додати позитивні граничні тести для T-11, T-17, T-22, виведені з SRS v1.1 / AC / контракту, з ID у назві. Гілка impl/lab5, змінювати лише tests/.
2. T-11 (createExercise, updateExercise): min = max, recommended = min і = max, мінімально допустимі значення за SRS §5.3; T-17 (generatePlan): найменша й найбільша допустимі тривалості за AC-F-005 приймаються й конвертуються в секунди; T-22 (addOpenPlanItem, replaceOpenPlanItem, updateOpenPlanItem): параметри рівно min і рівно max варіанта, позиції на межах етапу (0 і остання).
3. Межу, яку специфікація не визначає, не вигадувати — винести в питання.
4. Червоний запуск (`dart analyze --fatal-infos`; `dart test` з логом logs/app/control-red-20261113b.log і `--file-reporter json:../logs/app/control-red-20261113b.jsonl`; `python3 -I tool/red_check.py`), аналіз логу, рядки таблиці простежуваності, цей етап журналу; коміт `test: [agent] T-11, T-17, T-22 positive boundary tests (TG-002)` після показу `git diff --cached`.

**Пропозиція агента та дії:**
- Джерела: SRS v1.1 §5.3 (додатні цілі — найменше 1; відпочинок невід'ємний — найменше 0; мін. ≤ макс.; рекомендоване в діапазоні), §5.4 (формули тривалості), §5.5 (години ≥ 0, хвилини 0…59, сума > 0, `D = h × 3600 + m × 60`), §5.6 (допуск `[0,9 × D; 1,1 × D]`, межі включно); AC-F-002 (`мін. ≤ рек. ≤ макс.`, D-08), AC-F-005, AC-F-010 («[мін., макс.]»), BDD-032; spec/openapi.yaml: `PlanItemCreateRequest.position` / `PlanItemPatchRequest.position` (`minimum: 0`), `PlanItemUnprocessable` / `PlanItemPatchInvalid` («position поза межами етапу»). Межі варіантів ex-1/var-1 і ex-3/var-1 — з `src/assets/catalog/test-catalog.json` (затверджено T-57; SHA-256 зафіксовано в TG-007).
- Додано 29 тестів (усі з ID у назві та позначкою TG-002 у назві групи):
  - T-11, `exercise_validation_test.dart` (+10): 5 випадків × createExercise і updateExercise — режим за часом min = max = рек. = 1 (раунди, інтервал) і 0 (відпочинок); рек. = min; рек. = max; режим за повтореннями min = max = рек. = 1 (підходи, повторення), відпочинок 0, `e` = 1 с; рек. = min і = max. Перевіряється 201 / 200 і збіг збереженого варіанта з введеним після повторного відкриття (getExercise). Для updateExercise вихідний варіант того самого режиму, `id` варіанта зберігається (D-33).
  - T-17, `generation_parameters_test.dart` (+3): 0 год 1 хв → 60 с (допуск 54–66 с), 0 год 59 хв → 3540 с (3186–3894 с) — на фікстурі `duration-tunable` (на постачальному каталозі план на 60 с неможливий і приховав би перетворення); 1 год 0 хв (хвилини на нижній межі 0) → 3600 с (3240–3960 с) — на постачальному каталозі. Перевіряються 201, `targetDurationSeconds`, `durationTolerance`, `generationParameters`.
  - T-22, `manual_editing_test.dart` (+16): 4 набори меж (ex-1/var-1 усі параметри = min (1, 60, 30) і = max (5, 300, 120); ex-3/var-1 = min (1, 5, 0) і = max (5, 20, 60)) × addOpenPlanItem, replaceOpenPlanItem, updateOpenPlanItem; окремо updateOpenPlanItem `rounds` = 5 і = 1 (дзеркало BDD-032); позиції: addOpenPlanItem з позицією останнього елемента (n − 1), updateOpenPlanItem — перший елемент на останню позицію (n − 1). Позицію 0 уже покривають тести № 30 і № 32 таблиці. Тривалості — за формулами §5.4 (60, 1980, 15, 540 с).
- Затверджені тести не змінено (diff — лише додані рядки); tests/test/support/, фікстури, src/, spec/ не змінено.

**Червоний запуск (13.11.2026):**
- `cd tests && dart analyze --fatal-infos` → «No issues found!».
- `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-red-20261113b.log dart test --reporter compact --file-reporter json:../logs/app/control-red-20261113b.jsonl` → код виходу 1 (concurrency 1 з tests/dart_test.yaml).
- `python3 -I tool/red_check.py ../logs/app/control-red-20261113b.jsonl` → код виходу 0: 16 наборів, 325 тестів; 322 `failure`, у кожного перша помилка — `TestFailure` «<operationId>: status 501 is not declared»; інших причин 0; «Failed to load» — немає; пройшли 3 — ті самі статичні мета-тести (виняток TG-010).
- Порівняння з logs/app/control-red-20261113.jsonl (скрипт поза репозиторієм): 296 → 325, додано 29, вилучено 0, результат попередніх тестів не змінився в жодного; усі 29 нових — `failure` з «status 501» і містять ID. Перша операція з 501: T-11 — createExercise (10; для updateExercise це передумова), T-17 — generatePlan (3), T-22 — generatePlan (16, передумова setUp). Отже, падіння доводить відсутність реалізації, але для T-22 і updateExercise до цільової операції запит у червоному запуску не доходить — так само, як у решти тестів цих файлів (етап 7).

**Аналіз логу logs/app/control-red-20261113b.log (скрипт):**
- 977 записів, нерозібраних 0; INFO — 655, WARNING — 322, ERROR — 0; стеків і винятків — 0.
- `app composed operations=27` — 333 = 302 (етап 7) + 29 нових тестів + 2 повторні композиції в тестах T-17 на фікстурі (постачальний каталог — 312, `duration-tunable` — 6, решта фікстур без змін).
- Запитів (INFO `http: request`) — 322, усі 501, 27 різних operationId, тривалість 0–5 мс; кожному передує WARNING `not implemented` того самого operationId (322 пари). Заглушки: `decode PlanGenerationRequest` — 187, `decode ExerciseInput` — 53, `decode ExerciseFilter` — 29, `decode analytics period` — 8.
- Значень `[TEST]`, URL і query у лозі немає (REQ-NF-004).
- Висновок: нові тести падають через нереалізовані операції; помилок середовища, компіляції чи завантаження немає.

**Таблиця простежуваності:** додано рядки 239–267 (таблиця етапу 7; згенеровано скриптом із виводу репортера).

**Питання до специфікації (передано людині):**
1. Верхня межа годин цільової тривалості: SRS §5.5 і AC-F-005 задають лише «години — невід'ємне ціле число», контракт — `minimum: 0` без `maximum`. «Найбільшу допустиму тривалість» визначити неможливо; тестовано лише межу хвилин 59. Тест на великі години не додано.
2. Чи є `position = n` (одразу після останнього елемента етапу, n — кількість елементів) у addOpenPlanItem і position в updateOpenPlanItem при перенесенні в інший етап «у межах етапу»? Контракт: «position поза межами етапу» → 422, «якщо відсутній — у кінець етапу», межу не уточнено. Тестовано лише 0 і n − 1.
3. Верхніх меж параметрів варіанта власної вправи (наприклад, найбільша кількість раундів чи інтервал) SRS §5.3 не задає; тестовано лише найменші допустимі значення.

**Повний діалог:** не збережено агентом

## Етап 10. Реалізація, група 1: T-30, T-31, T-32, T-33 (API-частина) — 13.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. ЛР-5, крок 2 — реалізація за TDD після GO на TEST-GATE (logs/test-gate.md, коміт `5962e33`). Гілка impl/lab5. Змінювати лише src/; tests/ і spec/openapi.yaml не змінювати; лише поведінка, потрібна для тестів групи; для випадків, які специфікація не визначає (рішення 5–7 етапу 7), — лише статуси й коди контракту; логування за рішенням 3 етапу 1.
2. Група 1: T-31 (сховище Drift, атомарні транзакції), T-32 (ініціалізація каталогу за D-06), T-30 (вправи, варіанти, валідація), T-33 (довідники, фільтрація). Операції: createExercise, updateExercise, getExercise, listExercises, getDictionary.
3. Порядок: червоний запуск тестів групи → реалізація → тести групи й повний набір → контрольний запуск із логом logs/app/control-green-g1-<дата>.log і його аналіз → `dart analyze --fatal-infos` → цей етап журналу → коміт після показу `git diff --cached --stat`.

**Пропозиція агента та дії:**
- Тести групи — 4 файли за тікетами T-11 → T-30, T-12 → T-31, T-13 → T-32, T-14 → T-33 (колонка залежностей docs/plan/decomposition.md): exercises/exercise_validation_test.dart (41), exercises/catalog_initialization_test.dart (6), exercises/catalog_filter_test.dart (31), storage/storage_test.dart (8). exercises/catalog_version_test.dart (BDD-035) потребує generatePlan, saveNewTrainingPlan, completeTraining у setUp — поза групою 1.
- Червоний запуск до змін (src/ без змін, коміт `5962e33`): `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-red-g1-20261113.log dart test <4 файли> --reporter compact --file-reporter json:../logs/app/control-red-g1-20261113.jsonl` → код виходу 1; `python3 -I tool/red_check.py ../logs/app/control-red-g1-20261113.jsonl` → код виходу 0: 4 набори, 86 тестів, 86 `failure`, у кожного перша помилка — `TestFailure` «status 501 is not declared»; інших причин і «Failed to load» — 0. Перша операція з 501: createExercise — 41, listExercises — 28, generatePlan — 6 (storage_test), getDictionary і getExercise — по 5, updateExercise — 1. Лог: 260 записів, INFO 174, WARNING 86, ERROR 0; 86 запитів, усі 501.
- Перед реалізацією агент передав людині два питання (див. рішення нижче): значення `ErrorDetail.constraint` для порушень, яких немає в прикладах контракту, і як трактувати тести T-12, що потребують операцій поза групою.
- Реалізація (лише src/lib/; схема Drift не змінювалась, `build_runner` не запускався):
  - моделі й валідація (`domain/`):
    - `exercise_json.dart` (новий) — wire-форма `Exercise`, `Variant`, `Dictionary` для довірених даних (ресурс каталогу, збережені копії) і відповідей;
    - `exercise_validation.dart` (новий) — правила AC-F-002, AC-F-004, SRS §5.3, D-08: непорожні назва й опис, хоча б один варіант, кожне значення ≥ 1 (раунди, підходи, повторення, інтервал, `e`) або ≥ 0 (відпочинок), `min ≤ max`, `min ≤ recommended ≤ max`, посилання — абсолютний `https://` URI;
    - `domain_error.dart` — константи `Constraint` (рішення людини нижче); `enums.dart` — інтерфейс `WireEnum` і `fromWire` для розбору перелічувань контракту;
  - порти: `StorageWriteException`; у `ExerciseRepository` — `installedCatalogVersion`, `installCatalog`; `EntityKind.variant` (ID `var-<32 hex>`, D-33);
  - репозиторії (`data/`), T-31: `DriftExerciseRepository` — читання, вставка, оновлення; `installCatalog` — одна транзакція `db.transaction`; будь-який збій запису → ERROR зі стеком і `StorageWriteException` (сервіс → 500 STORAGE_WRITE_FAILED, AC-NF-003). Репозиторії планів і завершених тренувань — заглушки (рішення людини нижче). `JsonFileCatalogSource` читає ресурс T-57 (SHA-256 `f29ec074…9839` збігається з TG-007);
  - сервіси (`application/catalog_service.dart`):
    - T-32 `initialize`: завантажує ресурс; якщо встановлена версія (`catalog_meta.catalogVersion`) збігається — нічого не пише (повторний запуск без дублікатів, AC-F-001, також умова змодельованого збою запису, питання 11 етапу 7); інакше одна транзакція: початкові вправи замінюються за ID, власні не зачіпаються, початкові, відсутні в новій версії, не видаляються, а позначаються застарілими (D-06);
    - T-30 `createExercise`: ID, `origin = custom`, `deprecated = false` встановлює система (D-05); `updateExercise`: 404 → 403 для початкової, зокрема застарілої (D-05) → 422 → запис; варіант зі своїм id зберігає його, без id (або з id, якого у вправи немає) — новий id, відсутній у тілі — вилучається (D-33); `getExercise` повертає й застарілу (D-06);
    - T-33 `listExercises`: «АБО» в межах ознаки, «І» між ознаками (D-09); з фільтром `loadCharacter` вправи `not-applicable` не повертаються (D-34, REV-004); засіб виконання й обладнання задовольняє один варіант (AC-F-003); застарілі не повертаються (D-06); значення фільтрів довідників перевіряються за довідниками → 422 UNKNOWN_DICTIONARY_VALUE (NEG-05); `getDictionary` — довідник із ресурсу;
  - маршрути й відображення (`http/`): декодер `ExerciseFilter`, `ExerciseInput`, `DictionaryName` за `info.description` контракту (некоректний JSON → 400 з `body: INVALID_JSON`; неправильний JSON-тип → 400; відсутнє обов'язкове поле, неціле число, значення поза перелічуванням → 422 VALIDATION_FAILED); кодувальники `ExerciseList`, `Exercise` (201 з `Location: /exercises/{id}`), `Dictionary`; модель `Error`; `middleware.dart` — `DomainError` → статус контракту й тіло `Error`, WARNING з кодом і шляхами полів `details` (без значень). Статуси задано лише для кодів групи (400, 403, 404, 422, 500); код без статусу → 500 і ERROR;
  - конфігурація (`composition_root.dart`): ініціалізація каталогу стартує під час композиції; кожен запит чекає на її завершення; збій ініціалізації — ERROR зі стеком; `App.close` закриває БД після ініціалізації;
  - логування: нові логери `catalog` (встановлення / актуальність версії, створення й редагування вправи з ID і кількістю варіантів, кількість у переліку) і `storage` (збій запису).

**Рішення людини (13.11.2026), отримані до реалізації:**
1. `ErrorDetail.constraint`: наявні ідентифікатори контракту — MIN_LE_MAX (зокрема `recommended` поза `[min; max]` — ланцюг `min ≤ recommended ≤ max` схеми `CountRange`), MINIMUM, DICTIONARY_VALUE (значення поза довідником чи перелічуванням), INVALID_JSON; для порушень без ідентифікатора в контракті — назва ключового слова схеми: REQUIRED, MIN_LENGTH, MIN_ITEMS, INTEGER, HTTPS. Записати в «Питання до специфікації».
2. Група 1 — тести, що викликають лише 5 операцій групи. storage_test.dart (T-12) лишається червоним через 501 інших операцій; T-31 у групі 1 — схема й атомарні транзакції для вправ і метаданих каталогу, решта репозиторіїв — з відповідними групами.

**Запуски після реалізації (13.11.2026):**
- Тести групи: `dart test test/exercises/exercise_validation_test.dart test/exercises/catalog_initialization_test.dart test/exercises/catalog_filter_test.dart` → «+78: All tests passed!» (41 + 6 + 31). storage_test.dart (8) — червоний, перша операція з 501 — generatePlan (6) і saveNewTrainingPlan / completeTraining через передумови (рішення 2).
- Повний набір — він же контрольний запуск: `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-green-g1-20261113.log dart test --reporter compact --file-reporter json:../logs/app/control-green-g1-20261113.jsonl` (concurrency 1 з tests/dart_test.yaml) → код виходу 1. Звірка скриптом `green_check.py` (Python, поза репозиторієм) з logs/app/control-red-20261113b.jsonl (останній затверджений червоний запуск):
  - 16 наборів, 325 тестів (ті самі 325), «Failed to load» — 0;
  - пройшли 86 = 78 тестів групи + 5 тестів AC-NF-006 «never 501» для listExercises, createExercise, getExercise, updateExercise, getDictionary + 3 статичні мета-тести (виняток TG-010);
  - 239 `failure` — у кожного перша помилка «<operationId>: status 501 is not declared», і жодна з цих операцій не належить групі 1; інших причин падіння — 0; регресій (пройшов у червоному, падає тепер) — 0;
  - перша операція з 501 серед решти: generatePlan — 198, getAnalytics — 8, listCompletedTrainings — 3, ще 19 операцій — по 1–2.
- `dart analyze --fatal-infos` у src/ і tests/ → «No issues found!».
- `git diff --quiet 5962e33 -- tests spec` → без відмінностей: тести, затверджені на TEST-GATE, і spec/ не змінено.

**Аналіз логу logs/app/control-green-g1-20261113.log (скрипт `log_check.py`, поза репозиторієм):**
- 1431 запис, нерозібраних 0; INFO — 1166, WARNING — 265, ERROR — 0; записів зі стеком — 0.
- 400 запитів; операції групи: createExercise 201 — 35, 400 — 2, 422 — 14; getExercise 200 — 35, 404 — 2; updateExercise 200 — 9, 403 — 2, 404 — 2, 422 — 2; listExercises 200 — 50, 422 — 2; getDictionary 200 — 6. Решта 22 операції — лише 501 (239 запитів).
- WARNING: 239 — `not implemented` (заглушки операцій інших груп, по одному на запит з 501); 26 — `domain error` (по одному на кожну відповідь 4xx операцій групи) з кодом і `details` лише як шлях:constraint, наприклад `variants[0].rounds.min:MIN_LE_MAX`, `name:REQUIRED`, `level:DICTIONARY_VALUE`, `body:INVALID_JSON`. Значень полів у них немає.
- Каталог: `catalog installed version=test-1 previous=- … initial=8 markedDeprecated=[]` — 310 (кожна нова БД); фікстури — 25 (версії `fixture-*`); `catalog up to date version=test-1` — 5 (перезапуски в тестах T-13 і D-05): повторний запуск нічого не пише. Позначення застарілих за D-06 у цьому запуску не виконувалось: тести BDD-035 (catalog_version_test.dart) зупиняються на generatePlan до перезапуску з новою версією.
- Тривалість запитів 0–362 мс (у повторному запуску після доопрацювання — 0–354 мс); найдовший — перший запит процесу (компіляція JIT, відкриття БД, встановлення каталогу), ще 18 запитів — 10–99 мс, решта < 10 мс.
- Даних користувача немає: скрипт шукав назви, описи, імена авторів і посилання з ресурсу каталогу та фікстур, назви з тіл тестів, `[TEST]`, `https://`, `http://`, `ftp://`, `example.com`, значення query `level-unknown`, `stretching` — збігів 0 (REQ-NF-004, рішення 3 етапу 1).
- Висновок: помилок і винятків немає; WARNING — лише очікувані заглушки інших груп і помилки валідації з кодами контракту; дані користувача не логуються.

**Питання до специфікації (передано людині):**
1. Ідентифікатори `constraint` REQUIRED, MIN_LENGTH, MIN_ITEMS, INTEGER, HTTPS і MIN_LE_MAX для `recommended` введено рішенням людини, у spec/openapi.yaml їх немає (є лише в прикладах MIN_LE_MAX, MINIMUM, DICTIONARY_VALUE, INVALID_JSON). Чи вносити перелік у контракт — вирішує людина; агент spec/ не змінював.
2. `updateExercise`: варіант з id, якого у вправи немає, або повторений id контракт не визначає. Реалізовано як новий варіант із новим id (без нових кодів). Не тестується.
3. Значення довідників у тілі `createExercise` / `updateExercise` не перевіряються (питання 6 етапу 7, «Відкладено»): власна вправа може містити ID поза довідниками. Перевірки на це немає й у тестах.
4. Неправильний JSON-тип поля → 400 BAD_REQUEST без `details` (поле `details` необов'язкове; ідентифікатора для цього порушення в контракті немає). Значення поза перелічуванням у тілі (`type`, `mode`, `allowedStages[i]`, `loadCharacter`) → 422 VALIDATION_FAILED, `constraint: DICTIONARY_VALUE`. Не тестується.
5. `getDictionary` з назвою поза перелічуванням → 404 NOT_FOUND (єдина помилка, оголошена для операції; питання 7 етапу 7). Не тестується.
6. Якщо ініціалізація каталогу не вдалася (ресурс відсутній чи пошкоджений, збій запису під час встановлення нової версії), кожен запит отримує 500 без тіла; для операцій читання 500 у контракті не оголошено. Не тестується.
7. Позначення застарілих за D-06 (початкова вправа, відсутня в новій версії) у групі 1 тестами не перевірено: фікстура catalog-v2 містить ті самі 8 ID, а тести BDD-035 зупиняються на generatePlan. Перевірка — разом із групою формування плану.

**Рішення людини щодо групи 1 (13.11.2026):**
1. Ідентифікатори constraint у контракт не вносяться: `ErrorDetail.constraint` — `type: string` без `enum`. Перелік, що використовує реалізація (`Constraint` у src/lib/src/domain/domain_error.dart):
   - з прикладів контракту: MIN_LE_MAX (`min > max`; також `recommended` поза `[min; max]`), MINIMUM (значення менше за `minimum` схеми), DICTIONARY_VALUE (значення поза довідником чи перелічуванням — фільтри `listExercises` і перелічування в тілі вправи), INVALID_JSON (`field: body`, некоректний JSON);
   - за ключовим словом схеми: REQUIRED (відсутнє обов'язкове поле), MIN_LENGTH (порожні `name`, `description`), MIN_ITEMS (порожній `variants`), INTEGER (неціле число там, де очікується ціле), HTTPS (`videoUrl`, `authorPageUrl` не є абсолютним `https://` URI).
2. Невідомий або повторений id варіанта в `updateExercise` → новий варіант із новим id — прийнято, статус «Відкладено».
3. Значення довідників у тілі `createExercise` / `updateExercise` — як рішення щодо питання 6 етапу 7 («Відкладено», не перевіряються).
4. 500 без тіла порушує контракт (модель `Error` для всіх 4xx / 5xx) — виправити: якщо ініціалізація каталогу не вдалася — ERROR зі стеком у лозі, сервер не стартує (ненульовий код виходу), запити не обслуговуються; після зміни повторити повний набір тестів і `dart analyze`.
5. Перевірка позначення застарілих за D-06 — у групі 2.
6. Червоний лог control-red-g1 лишається в коміті як доказ кроку «спершу падає».

**Доопрацювання за рішенням 4 (13.11.2026, та сама модель):**
- `App.initialized` (composition_root.dart) — завершення ініціалізації каталогу; збій, як і раніше, записує buildApp (ERROR зі стеком, логер `app`).
- bin/server.dart: `shelf_io.serve` викликається лише після `await app.initialized`. Якщо ініціалізація не вдалася — ERROR `startup aborted reason=catalog-initialization-failed`, закриття БД і логів, `exitCode = 1`, порт не відкривається. Якщо не вдався сам `serve` — також закриває БД.
- Обробник у процесі (тести) і далі чекає на ініціалізацію перед кожним запитом; через сервер запити до успішної ініціалізації не надходять.
- Перевірка збою: `dart run bin/server.dart --db=:memory: --catalog=assets/catalog/missing.json --log-file=control-T-32-20261113.log` → код виходу 1. Лог logs/app/control-T-32-20261113.log — 4 записи: `starting`, `app composed`, ERROR `catalog initialization failed` (`PathNotFoundException` зі стеком), ERROR `startup aborted …`; запису `listening` немає; `lsof -iTCP:8080 -sTCP:LISTEN` — порожньо. У стеку є абсолютний шлях до bin/server.dart (зокрема ім'я домашнього каталогу) — так Dart формує стек; даних користувача застосунку немає.
- Перевірка нормального старту (лог у scratchpad, поза репозиторієм): `--db=:memory: --port=8091`, один запит getDictionary → 200, SIGINT → код виходу 0; порядок записів: `catalog installed version=test-1` → `listening` → запит → `stopping` → `stopped`.
- Повторний повний набір (той самий контрольний запуск, файли logs/app/control-green-g1-20261113.log і .jsonl перезаписано): 325 тестів, 86 `success`, 239 `failure` — усі через 501 операцій поза групою 1; інших причин, регресій і «Failed to load» — 0 (`green_check.py`). Лог: 1431 запис, INFO 1166, WARNING 265 (239 `not implemented`, 26 `domain error`), ERROR 0, даних користувача немає — цифри аналізу вище не змінились, крім тривалості.
- `dart analyze --fatal-infos` у src/ і tests/ → «No issues found!»; `git diff --quiet 5962e33 -- tests spec` → без відмінностей.

**Повний діалог:** не збережено агентом

**Коміт:** `5c70ba4` feat: [agent] T-30, T-31, T-32, T-33 exercises, storage, catalog and dictionaries (`git log --oneline -1`).

## Етап 11. Реалізація, група 2: T-36, T-37, T-38, T-39 (формування плану, API-частина) — 13.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Та сама процедура й правила, що для групи 1 (етап 10). Тікети: T-36 (параметри формування й конвертація в секунди, AC-F-005), T-37 (розрахунок тривалості §5.4, AC-F-007), T-38 (правила відбору §5.1, AC-F-006, D-06, D-09), T-39 (генератор: структура §5.2, допуск ±10 %, коригування обсягу D-10, неможливість §5.7, ліміт пошуку 3 с D-13 / D-25 через підставлений годинник, відтворюваність за зерном D-11). Операції: generatePlan, getOpenPlan (відкритий план лише в пам'яті, рішення 4 етапу 1).
2. Тести, що потребують операцій групи 3, лишаються червоними з причиною 501. Окремо підтвердити, що тести BDD-035 щодо застарілих вправ у generatePlan проходять (питання 5 групи 1).
3. Коміт `feat: [agent] T-36, T-37, T-38, T-39 plan generation` після показу `git diff --cached --stat`.

**Пропозиція агента та дії:**
- Тести групи — 4 файли plan_generations/ за тікетами T-17 → T-36, T-18 → T-37, T-19 → T-38, T-20 → T-39 (decomposition.md): generation_parameters_test.dart (18), duration_test.dart (11), selection_structure_test.dart (21), tolerance_impossibility_test.dart (25).
- Червоний запуск до змін (src/ = коміт `5c70ba4`): `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-red-g2-20261113.log dart test test/plan_generations/ --reporter compact --file-reporter json:../logs/app/control-red-g2-20261113.jsonl` → код виходу 1; `python3 -I tool/red_check.py ../logs/app/control-red-g2-20261113.jsonl` → код виходу 0: 4 набори, 75 тестів, 75 `failure`, перша й єдина помилка кожного — «generatePlan: status 501 is not declared»; інших причин і «Failed to load» — 0. Лог: 314 записів, INFO 239, WARNING 75, ERROR 0; 75 запитів, усі 501.
- Реалізація (лише src/lib/; схема Drift не змінювалась):
  - моделі й правила (`domain/`):
    - `plan_rules.dart` (новий): T-37 — тривалість елемента за §5.4 (`n × t + (n − 1) × r`, `n × p × e + (n − 1) × r`) і плану (сума); T-36 — `D = h × 3600 + m × 60` (§5.5), допуск `[⌈0,9 × D⌉; ⌊1,1 × D⌋]` включно (§5.6), перевірка параметрів до пошуку (години ≥ 0, хвилини 0…59, `D > 0`; BDD-006); T-38 — придатність варіанта за правилами 1–6 §5.1 (акцент — лише для основної частини; порожній перелік обладнання — лише варіанти без обладнання; застарілі не підбираються, D-06);
    - `plan_json.dart` (новий) — wire-форма `GenerationParameters`, `PlanItem`, `PlanStage`, `PlanWarning`, `Plan`, `OpenPlan`;
    - `domain_error.dart` — `Constraint.totalGreaterThanZero` (з прикладу контракту) і `Constraint.maximum` (MAXIMUM, ключове слово схеми — див. питання 1);
  - генератор (`application/plan_generator.dart`, новий), T-39:
    1. кандидати — варіанти, придатні за §5.1 хоча б для одного етапу;
    2. доведена неможливість до пошуку: етап без кандидатів → `NO_CANDIDATES_FOR_STAGE` зі `stage`; сума по етапах найменших мінімальних обсягів > `1,1 × D` → `MIN_VOLUME_ABOVE_UPPER_BOUND` (D-10); максимальний обсяг усіх кандидатів, кожного один раз, < `0,9 × D` → `MAX_VOLUME_BELOW_LOWER_BOUND`. Тривалість за §5.4 не спадає за жодним параметром, тому межі — значення за всіма мінімумами й максимумами;
    3. пошук: перебір вибірок «по одному різному варіанту на етап» у порядку, перемішаному підставленим джерелом випадковості (D-11); перед кожною вибіркою читається підставлений годинник, і якщо від початку минуло не менше 3,000 с — 503 `GENERATION_SEARCH_LIMIT_REACHED`, `limitSeconds: 3` (D-13, D-25);
    4. для вибірки: спершу рекомендовані значення; якщо сума поза допуском — точний розрахунок досяжних сум (множини цілих діапазонів тривалостей кожного варіанта в межах `[min; max]`) і вибір найближчої до рекомендованої суми в допуску; для кожного елемента — тривалість, найближча до рекомендованої, і параметри, найближчі до рекомендованих (D-10). Якщо вибірки самої не досить, решта кандидатів може бути додана — кожен не більше одного разу (§5.2, D-33), в етап, вибраний випадково серед допустимих для варіанта;
    5. усі вибірки відхилено → 422 `PLAN_GENERATION_IMPOSSIBLE` без `reasons` (повний перебір — доказ; `reasons` у контракті необов'язкові);
    6. інший виняток генератора → ERROR зі стеком і 500 `GENERATION_FAILED` (AC-F-009 п. 5);
  - сервіси (`application/plan_services.dart`): `generatePlan` — перевірка параметрів (422 VALIDATION_FAILED до пошуку), генерація, ID елементів і відкритого плану, позиції з 0, `name: null`, `sourcePlanId: null` (D-30, D-32), `warnings: []` (план у допуску й відповідає фільтрам за побудовою; перерахунок попереджень — група 3), збереження в пам'яті; у разі будь-якої помилки відкритий план не створюється. `getOpenPlan` — 404 NOT_FOUND для невідомого (зокрема після перезапуску, D-30);
  - сховище (`data/memory_stores.dart`): `InMemoryOpenPlanStore` — словник у пам'яті процесу;
  - HTTP (`http/json_mapping.dart`): декодер `PlanGenerationRequest` (400 — неправильний JSON-тип, напр. години рядком; 422 — відсутнє поле, неціле число); кодувальники `OpenPlan` (201 з `Location: /open-plans/{id}`, 200); статуси кодів PLAN_GENERATION_IMPOSSIBLE — 422, GENERATION_FAILED — 500, GENERATION_SEARCH_LIMIT_REACHED — 503;
  - логування: логер `plans` — `plan generated openPlanId=… targetSeconds=… totalSeconds=… items=w/m/c checkedSelections=…`, `plan not generated targetSeconds=… code=… reasons=[…]`; значення параметрів (рівень, акцент тощо) не логуються.

**Запуски після реалізації (13.11.2026):**
- Тести групи: `dart test test/plan_generations/` → 69 `success`, 6 `failure`. Ці 6 — групи T-18 у duration_test.dart (`addOpenPlanItem: durations of AC-F-007` — 3, `updateOpenPlanItem: exact seconds` — 3): перша помилка — 501 на addOpenPlanItem (3) і updateOpenPlanItem (3), передумови й дії групи 3. Інших причин — 0.
- Повний набір — він же контрольний запуск: `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-green-g2-20261113.log dart test --reporter compact --file-reporter json:../logs/app/control-green-g2-20261113.jsonl` → код виходу 1. Звірка `green_check.py` (поза репозиторієм; множина реалізованих операцій розширена на generatePlan, getOpenPlan) з logs/app/control-green-g1-20261113.jsonl:
  - 16 наборів, 325 тестів, «Failed to load» — 0;
  - пройшли 157 = 86 (група 1) + 69 (група 2) + 2 тести AC-NF-006 «never 501» для generatePlan і getOpenPlan;
  - 168 `failure` — у кожного перша помилка «<operationId>: status 501 is not declared», жодна з цих операцій не реалізована; інших причин — 0; регресій відносно групи 1 — 0;
  - перша операція з 501: addOpenPlanItem — 75, saveNewTrainingPlan — 23, replaceOpenPlanItem і startCurrentSession — по 12, getAnalytics — 8, deleteOpenPlanItem — 6, renameOpenPlan і updateOpenPlanItem — по 5, ще 12 операцій — по 1–3.
- BDD-035 (питання 5 групи 1): усі 7 тестів catalog_version_test.dart, зокрема `BDD-035 D-06 AC-F-006 generatePlan: the generator does not propose E1`, **лишаються червоними**: їхній спільний setUp викликає addOpenPlanItem (перша помилка — 501 на addOpenPlanItem), далі saveNewTrainingPlan, startCurrentSession, completeTraining — групи 3–5. Підтвердити їх у групі 2 неможливо. Правило 6 §5.1 (D-06) у генераторі в групі 2 перевіряють тести, що проходять: `AC-F-006 D-06 D-11 generatePlan: seed … — every variant satisfies the rules; no decoy …` (×5, фікстура selection-rules, `decoy-deprecated`) і перевірка правила 6 в `expectSelectionRules` на постачальному каталозі із застарілою ex-9 (`AC-F-006 AC-F-008 D-11 generatePlan: seed …` — 5 зерен × 2 тривалості = 10 тестів). Позначення застарілих під час встановлення нової версії (D-06, питання 5 групи 1) досі не перевірено тестами.
- `dart analyze --fatal-infos` у src/ і tests/ → «No issues found!»; `git diff --quiet 5962e33 -- tests spec` → без відмінностей.

**Аналіз логу logs/app/control-green-g2-20261113.log (скрипт `log_check.py`, поза репозиторієм):**
- 1730 записів, нерозібраних 0; INFO — 1515, WARNING — 215, ERROR — 0; записів зі стеком — 0.
- 544 запити. generatePlan: 201 — 188, 400 — 2, 422 — 16, 503 — 1; getOpenPlan: 200 — 4, 404 — 2. Операції групи 1 — ті самі статуси, що на етапі 10, лише createExercise 201 — 37 замість 35: у двох тестах manual_editing_test.dart (рядки 306, 436) generatePlan тепер проходить, і виконання доходить до створення вправи перед 501 на replaceOpenPlanItem. Решта 20 операцій — лише 501 (168 запитів).
- WARNING: 168 — `not implemented` (по одному на запит із 501); 47 — `domain error`. Для generatePlan: VALIDATION_FAILED — 10 (`targetDuration:TOTAL_GREATER_THAN_ZERO`, `targetDuration.hours:MINIMUM`, `targetDuration.minutes:MINIMUM`, `targetDuration.minutes:MAXIMUM`, `targetDuration.hours:INTEGER`, по одному REQUIRED для п'яти полів), BAD_REQUEST — 2 (`body:INVALID_JSON` і неправильний тип), PLAN_GENERATION_IMPOSSIBLE — 6, GENERATION_SEARCH_LIMIT_REACHED — 1.
- Логер `plans`: `plan generated` — 188 (ціль 60 с — 1, 2700 с — 6, 3540 с — 1, 3600 с — 163, 5400 с — 17); `checkedSelections=1` у всіх 188 — перша ж вибірка давала план; склад 1/1/1 — 179, 2/1/1 — 9 (додано другий варіант розминки, коли однієї вибірки не досить). `plan not generated`: NO_CANDIDATES_FOR_STAGE:cool-down — 1 (BDD-011), MAX_VOLUME_BELOW_LOWER_BOUND — 2 (BDD-012, BDD-010 3239 с), MIN_VOLUME_ABOVE_UPPER_BOUND — 2 (BDD-039, BDD-010 3961 с), без reasons після повного перебору — 1 (BDD-040, 2,999 с), GENERATION_SEARCH_LIMIT_REACHED — 1 (BDD-040, 3,000 с).
- Тривалість запитів 0–366 мс; найдовший — перший запит процесу (компіляція, відкриття БД, встановлення каталогу); найдовші generatePlan — 72, 77, 86 мс.
- Даних користувача немає (той самий пошук, що на етапі 10, — збігів 0).
- Висновок: помилок і винятків немає; WARNING — заглушки інших груп і очікувані відмови з кодами контракту; дані користувача не логуються.

**Питання до специфікації (передано людині):**
1. Новий ідентифікатор `constraint` MAXIMUM (хвилини > 59, `maximum: 59` схеми `TargetDuration`) — за правилом «ключове слово схеми» рішення 1 групи 1; тест перевіряє лише `field`. Перелік рішення 1 групи 1 доповнено: MAXIMUM, а також TOTAL_GREATER_THAN_ZERO з прикладу контракту.
2. BDD-035 для generatePlan у групі 2 не підтверджено — setUp потребує операцій груп 3–5 (див. вище). Підтвердження — після групи 5.
3. Неможливість, доведена повним перебором (жодна комбінація параметрів не потрапляє в допуск, а межі обсягу цього не показують, як у BDD-040), повертається без `reasons`: для цього випадку коду `ImpossibilityReason` у контракті немає.
4. Значення довідників у тілі generatePlan не перевіряються (питання 6 етапу 7, «Відкладено»): невідомий рівень дає 422 PLAN_GENERATION_IMPOSSIBLE з `NO_CANDIDATES_FOR_STAGE` для всіх етапів.
5. Додаткові варіанти (коли однієї вибірки «по одному на етап» не досить) потрапляють в етап, вибраний випадково серед допустимих для варіанта; частки етапів не нормуються (D-12, плейсхолдер).
6. Годинник читається перед кожною вибіркою; розрахунок однієї вибірки не переривається. Для каталогу `[TEST]` найдовший generatePlan — 86 мс; для великого реального каталогу (T-63) час однієї вибірки не оцінено (норматив продуктивності — CON-008, не змінюється).

**Рішення людини щодо групи 2 (13.11.2026):**
1. MAXIMUM і TOTAL_GREATER_THAN_ZERO — прийнято (правило «ключове слово схеми»). Перелік `constraint` реалізації: MIN_LE_MAX, MINIMUM, TOTAL_GREATER_THAN_ZERO, DICTIONARY_VALUE, INVALID_JSON (з прикладів контракту); REQUIRED, MIN_LENGTH, MIN_ITEMS, INTEGER, HTTPS, MAXIMUM (ключові слова схеми).
2. Неможливість, доведена повним перебором, без `reasons` — прийнято, «Відкладено»; enum контракту не змінювати.
3. Значення довідників у тілі generatePlan — рішення щодо питання 6 етапу 7 («Відкладено»).
4. Розподіл додаткових варіантів без нормування часток — прийнято, «Відкладено» (частки етапів специфікацією не визначено).
5. Читання годинника між вибірками — прийнято; оцінка на реальному каталозі поза ЛР-5.
6. BDD-035 перевіряється після групи 5.

**Повний діалог:** не збережено агентом

**Коміт:** `3713cfe` feat: [agent] T-36, T-37, T-38, T-39 plan generation (`git log --oneline -1`).

## Етап 12. Реалізація, група 3: T-41, T-42 (редагування відкритого плану, збережені плани, API-частина) — 13.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Та сама процедура й правила, що для груп 1–2. T-41: редагування відкритого плану (add / replace / update / delete елементів, перерахунок тривалості, попередження FILTER_MISMATCH, STAGE_EMPTY, DURATION_OUT_OF_TOLERANCE; AC-F-010, D-14, D-15). T-42: збережені плани (openSavedPlan, renameOpenPlan, listTrainingPlans, saveNewTrainingPlan, getTrainingPlan, overwriteTrainingPlan, deleteTrainingPlan; сховище Drift з атомарним записом і STORAGE_WRITE_FAILED (T-31, AC-NF-003); назва за замовчуванням D-32; modifiedAt за REV-009; копії в історії й поточному занятті не зачіпаються).
2. Окремо вказати, які тести storage_test.dart і duration_test.dart тепер проходять.
3. Коміт `feat: [agent] T-41, T-42 open plan editing and saved training plans` після показу `git diff --cached --stat`.

**Пропозиція агента та дії:**
- Тести групи — 4 файли: open_plans/manual_editing_test.dart (49, T-22 → T-41), training_plans/save_reopen_test.dart (24, T-23 → T-42), storage/storage_test.dart (8, T-12 → T-31 / T-42), plan_generations/duration_test.dart (11; 6 тестів T-18 потребують addOpenPlanItem / updateOpenPlanItem).
- Червоний запуск до змін (src/ = коміт `3713cfe`): `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-red-g3-20261113.log dart test <4 файли> --reporter compact --file-reporter json:../logs/app/control-red-g3-20261113.jsonl` → код виходу 1; `python3 -I tool/red_check.py ../logs/app/control-red-g3-20261113.jsonl` → код виходу 0: 92 тести; 87 `failure`, у кожного перша помилка — «status 501 is not declared» (addOpenPlanItem — 40, saveNewTrainingPlan — 19, replaceOpenPlanItem — 11, deleteOpenPlanItem, renameOpenPlan, updateOpenPlanItem — по 4, startCurrentSession — 2, getTrainingPlan, listTrainingPlans, openSavedPlan — по 1); інших причин і «Failed to load» — 0; пройшли 5 — тести `T-18 generatePlan: durations follow SRS §5.4` (×5 зерен) групи 2. Лог: 548 записів, INFO 460, WARNING 88, ERROR 0; 179 запитів, з них 87 — 501.
- Реалізація (лише src/):
  - схема Drift (`data/database.dart`): у `training_plans` додано стовпець `warningsJson` — попередження на момент збереження. Без нього FILTER_MISMATCH збереженого плану довелося б перераховувати з каталогу, а зміна каталогу не має переписувати збережений план (AC-F-011, BDD-035). `schemaVersion` лишається 1, міграції немає (розгорнутих БД немає, D-28); локальну БД розробки `src/.data/boxing_api.sqlite`, створену до цієї зміни, треба видалити. `database.g.dart` перегенеровано командою `dart run build_runner build`;
  - моделі й правила (`domain/`):
    - `plan_rules.dart`: `filterMismatches` — атрибути level, intensity, availableEquipment, emphasis (лише для основної частини) за правилами 2–5 §5.1 проти вихідних параметрів (D-14); `resolveItemParameters` — параметри елемента: лише поля режиму варіанта, значення ≥ 1 (≥ 0 для відпочинку), у межах `[min; max]` копії варіанта, `e` з варіанта (D-08), відсутнє поле — з поточних параметрів (updateOpenPlanItem) або обов'язкове (add / replace); `defaultPlanName` — «План від ДД.ММ.РРРР ГГ:ХХ» за локальним часом збереження (D-16, D-32);
    - `plan_json.dart`: декодування збережених копій (параметри формування, етапи, елементи, попередження), `SavedPlan`, `date-time` — момент у UTC;
    - `domain_error.dart`: `constraint` WITHIN_VARIANT_RANGE, NOT_EDITABLE (з прикладів контракту), ADDITIONAL_PROPERTIES, MIN_PROPERTIES (ключові слова схеми; MAXIMUM — також для позиції поза етапом);
    - `enums.dart`: `PlanWarningCode`, `WarningAttribute` реалізують `WireEnum`;
  - сервіси (`application/plan_services.dart`):
    - T-41: `addOpenPlanItem` (будь-який етап, без позиції — у кінець, той самий варіант повторно дозволено D-15; порядок перевірок: 404 плану → EXERCISE_NOT_FOUND → EXERCISE_DEPRECATED → VARIANT_NOT_FOUND → VALIDATION_FAILED), `replaceOpenPlanItem` (id, етап і позиція зберігаються), `updateOpenPlanItem` (параметри, порядок, перенесення в будь-який етап; без позиції в іншому етапі — у кінець), `deleteOpenPlanItem`. Після кожної зміни `recomputePlan`: етапи у фіксованому порядку, позиції 0…n−1, сума за §5.4, попередження FILTER_MISMATCH (за поточним каталогом), STAGE_EMPTY, DURATION_OUT_OF_TOLERANCE (точні секунди). STAGE_NOT_IN_EXERCISE не формується (рішення щодо питання 3 етапу 7). Відмова не змінює план: зміни робляться на копії й записуються в сховище лише після всіх перевірок;
    - T-42: `openSavedPlan` (копія вмісту збереженого плану разом з id елементів і попередженнями, `sourcePlanId`; немає плану → 422 PLAN_NOT_FOUND), `renameOpenPlan` (порожня назва допустима, `modifiedAt` не змінюється, REV-009), `saveNewTrainingPlan` (422 OPEN_PLAN_NOT_FOUND → 409 OPEN_PLAN_ALREADY_SAVED → 422 PLAN_EMPTY → запис → `sourcePlanId` відкритого плану), `getTrainingPlan`, `overwriteTrainingPlan` (422 OPEN_PLAN_NOT_FOUND → 404 NOT_FOUND → 409 OPEN_PLAN_SOURCE_MISMATCH → 422 PLAN_EMPTY → запис), `deleteTrainingPlan`, `listTrainingPlans` (новіші `modifiedAt` зверху). `modifiedAt` і назва за замовчуванням — момент успішного збереження чи перезапису (REV-009, D-16, D-32); після запису відкритий план отримує збережену назву. Збій запису → 500 STORAGE_WRITE_FAILED, попередній стан діє;
  - репозиторій (`data/drift_repositories.dart`): `DriftTrainingPlanRepository` — вставка, оновлення, видалення одним оператором SQL кожне (атомарно), читання, перелік. Історія й поточне заняття мають власні копії, видалення плану їх не зачіпає (SRS §4.5; перевірка — після груп 4–5);
  - HTTP (`http/json_mapping.dart`, `http/routes.dart`): декодери `PlanItemCreateRequest`, `PlanItemReplaceRequest`, `PlanItemPatchRequest` (порожнє тіло → 422 `body: MIN_PROPERTIES`), `PlanItemParametersInput` (`repetitionTimeSeconds` → 422 NOT_EDITABLE, неціле → INTEGER, позиція < 0 → MINIMUM), `SavePlanRequest`, `OpenSavedPlanRequest`, `OpenPlanPatchRequest`; кодувальники `SavedPlan` (201 з `Location: /training-plans/{id}`), `TrainingPlanList`, 204; `Location` addOpenPlanItem — `/open-plans/{openPlanId}/items/{itemId}` (рішення щодо питання 9 етапу 7); статуси кодів групи 3 (422, 409).
- Знайдено й виправлено під час аналізу першого контрольного логу: записи ERROR про збій запису (тести AC-NF-003 зі сховищем лише для читання) містили текст `SqliteException` разом із SQL-оператором і його параметрами — назвою плану й JSON етапів з назвами вправ `[TEST]` (порушення рішення 3 етапу 1, REQ-NF-004). Тепер у лог потрапляють лише код і пояснення `SqliteException`, для будь-якого іншого винятку — лише його тип; стек зберігається. З `NativeDatabase.createInBackground` помилка надходить загорнутою в `DriftRemoteException`, клас якого експортує лише експериментальний `package:drift/remote.dart` (`dart analyze --fatal-infos` дає `experimental_member_use`), тому для неї в лозі лише тип, без коду SQLite. Логи цього й проміжного запусків видалено; цифри нижче — з повторного контрольного запуску. У логах груп 1–2 записів ERROR не було.

**Запуски після реалізації (13.11.2026):**
- Тести групи (4 файли): 88 `success`, 4 `failure`. Ці 4 — з першою помилкою 501 на startCurrentSession (група 4): save_reopen_test.dart `AC-F-011 D-16 SRS §4.5 deleteTrainingPlan: the history and the current session keep their own copies` і 3 тести storage_test.dart (нижче).
- storage_test.dart (окремо за запитом): проходять 5 з 8 —
  1. `BDD-015 AC-F-011 AC-NF-002 updateExercise getTrainingPlan: a saved plan with a custom exercise keeps the previous name and saved parameters after the exercise is changed and the app restarted`;
  2. `AC-NF-003 saveNewTrainingPlan: success is reported only after the write is complete — a restart right after 201 finds the plan`;
  3. `AC-NF-003 saveNewTrainingPlan: a storage error → 500 STORAGE_WRITE_FAILED, no plan is saved and the open plan stays unsaved`;
  4. `AC-NF-003 overwriteTrainingPlan: a storage error → 500 STORAGE_WRITE_FAILED, the previous saved plan stays in full`;
  5. `AC-NF-003 deleteTrainingPlan: a storage error → 500 STORAGE_WRITE_FAILED, the plan is not deleted`.
  Червоні (501 на startCurrentSession): `AC-NF-002 createExercise saveNewTrainingPlan completeTraining: after a confirmed save and a restart …`, `AC-NF-003 completeTraining: success is reported only after the write is complete …`, `BDD-021 NEG-07 AC-NF-003 completeTraining getCurrentSession listCompletedTrainings: a storage error → 500 …`.
- duration_test.dart (окремо за запитом): проходять усі 11; нові в групі 3 — 6: `BDD-008 AC-F-007 addOpenPlanItem: 3 rounds × 180 s with 60 s rest → 660 s`, `BDD-009 AC-F-007 addOpenPlanItem: 3 sets × 10 repetitions × 3 s with 30 s rest → 150 s`, `AC-F-007 addOpenPlanItem getOpenPlan: the two elements together add 810 s to the plan`, `BDD-022 AC-F-007 updateOpenPlanItem: total 5429 s is returned as exact seconds, not rounded to minutes`, `AC-F-007 AC-F-010 updateOpenPlanItem: tolerance uses the exact time — 3239 s gives DURATION_OUT_OF_TOLERANCE …`, `AC-F-007 AC-F-010 updateOpenPlanItem: 3240 s and 3960 s are inside the tolerance, 3961 s is outside`; 5 тестів `generatePlan: durations follow SRS §5.4` — з групи 2.
- Повний набір — він же контрольний запуск: `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-green-g3-20261113.log dart test --reporter compact --file-reporter json:../logs/app/control-green-g3-20261113.jsonl` → код виходу 1. Звірка `green_check.py` (поза репозиторієм; множина реалізованих операцій — групи 1–3) з logs/app/control-green-g2-20261113.jsonl:
  - 325 тестів, «Failed to load» — 0;
  - пройшли 251 = 157 (групи 1–2) + 94: manual_editing — 49, save_reopen — 23, contract (`never 501`) — 11, duration — 6, storage — 5;
  - 74 `failure` — у кожного перша помилка «status 501» на нереалізованій операції (startCurrentSession — 51, getAnalytics — 8, listCompletedTrainings — 4, getCurrentSession, abortCurrentSession, deleteExecutedPlanItem, completeTraining, getCompletedTraining — по 2, updateExecutedPlanItem — 1); інших причин — 0; регресій відносно групи 2 — 0.
- BDD-035 (catalog_version_test.dart, 7 тестів): червоні, перша помилка — 501 на startCurrentSession (setUp; до групи 3 — на addOpenPlanItem). Перевірка — після групи 5 (рішення 6 групи 2).
- `dart analyze --fatal-infos` у src/ і tests/ → «No issues found!»; `git diff --quiet 5962e33 -- tests spec` → без відмінностей.

**Аналіз логу logs/app/control-green-g3-20261113.log (скрипт `log_check.py`, поза репозиторієм):**
- 2159 записів, INFO — 1984, WARNING — 172, ERROR — 3; 118 рядків — кадри стеку цих трьох записів.
- ERROR — 3, усі очікувані: `storage: write failed operation=trainingPlan.insert | trainingPlan.update | trainingPlan.delete`, `error: DriftRemoteException` зі стеком — тести AC-NF-003 зі сховищем лише для читання; кожному відповідає WARNING `domain error … code=STORAGE_WRITE_FAILED status=500`.
- 776 запитів; операції групи 3: addOpenPlanItem 201 — 93, 404 — 2, 422 — 6; replaceOpenPlanItem 200 — 6, 404 — 2, 422 — 4; updateOpenPlanItem 200 — 30, 404 — 2, 422 — 8; deleteOpenPlanItem 200 — 11, 404 — 2; openSavedPlan 201 — 8, 422 — 2; renameOpenPlan 200 — 6, 400 — 1, 404 — 2; listTrainingPlans 200 — 14; saveNewTrainingPlan 201 — 38, 409 — 2, 422 — 3, 500 — 1; getTrainingPlan 200 — 19, 404 — 3; overwriteTrainingPlan 200 — 6, 404 — 1, 409 — 2, 422 — 3, 500 — 1; deleteTrainingPlan 204 — 2, 404 — 2, 500 — 1. Решта 9 операцій — лише 501 (74 запити).
- WARNING: 74 — `not implemented`; 98 — `domain error` з кодами контракту, у `details` — лише шлях і constraint (`parameters.rounds:WITHIN_VARIANT_RANGE`, `parameters.repetitionTimeSeconds:NOT_EDITABLE`, `parameters.sets:ADDITIONAL_PROPERTIES`, `position:MAXIMUM`, `body:MIN_PROPERTIES` тощо).
- `catalog up to date version=test-1` — 12 (перезапуски на тій самій БД, зокрема з файлом лише для читання: тести AC-NF-003 пройшли, тобто ініціалізація тієї самої версії нічого не пише — припущення питання 11 етапу 7 підтверджено).
- Логер `plans`: формування, редагування, збереження, перезапис, видалення з ID; назви планів не логуються (`open plan renamed … empty=true|false`).
- Тривалість запитів 0–356 мс (найдовший — перший запит процесу).
- Даних користувача немає (пошук етапу 10 — назви, описи, посилання каталогу й фікстур, `[TEST]`, назви з тіл тестів — збігів 0).
- Висновок: ERROR лише для змодельованих збоїв запису й без вмісту полів; WARNING — заглушки груп 4–5 і очікувані відмови з кодами контракту.

**Питання до специфікації (передано людині):**
1. Нові ідентифікатори `constraint` за правилом «ключове слово схеми»: ADDITIONAL_PROPERTIES (поле іншого режиму, `additionalProperties: false` схем `TimeParameters` / `RepetitionsParameters`), MIN_PROPERTIES (порожнє тіло `PlanItemPatchRequest`, `minProperties: 1`), MAXIMUM для позиції поза етапом, REQUIRED для відсутнього поля режиму в add / replace. WITHIN_VARIANT_RANGE і NOT_EDITABLE — з прикладів контракту. Значення, менші за `minimum` схеми (0 раундів, −1 с відпочинку), позначено MINIMUM, а не WITHIN_VARIANT_RANGE. Тести перевіряють лише `field`.
2. Позиція `n` (одразу після останнього елемента; питання 2 етапу 9, «Відкладено»): реалізовано як допустиму — addOpenPlanItem вставляє в кінець, updateOpenPlanItem при перенесенні в інший етап — у кінець; у межах того самого етапу допустимі 0…n−1. Більше — 422 `position: MAXIMUM`.
3. Відсутні поля режиму в `parameters` addOpenPlanItem / replaceOpenPlanItem (питання 5 етапу 7, «Відкладено»): 422 VALIDATION_FAILED `REQUIRED`; в updateOpenPlanItem відсутні поля беруться з поточних параметрів.
4. Відсутні `openPlanId`, `sourcePlanId` чи `name` у тілі → 400 BAD_REQUEST (422 цих операцій описує інші коди; renameOpenPlan 422 не оголошує).
5. Зміна схеми без міграції (`warningsJson`, `schemaVersion` 1): БД розробки, створену до групи 3, треба видалити. Чи потрібна міграція / підвищення версії — вирішує людина (перед T-63 / релізом).
6. openSavedPlan копіює вміст збереженого плану разом з id елементів і збереженими попередженнями; після першої зміни FILTER_MISMATCH перераховується за поточним каталогом.
7. Після saveNewTrainingPlan / overwriteTrainingPlan відкритий план отримує назву збереженого (зокрема назву за замовчуванням). Контракт цього не визначає; тести не перевіряють.
8. Помилку SQLite з фонового ізолята в лозі видно лише як `DriftRemoteException` (без коду SQLite), бо розгорнути її без експериментального API не можна. Альтернатива — виконувач БД в основному ізоляті (`NativeDatabase`); не змінювалось.

**Знахідка аналізу логу (група 3):** витік вмісту полів користувача в записах ERROR сховища. Виявлено скриптом `log_check.py` у першому контрольному лозі групи 3: пошук даних користувача дав збіги (`[TEST] Розтяжка`, `[TEST] Комбінації на мішку`, `[TEST] Розминка в русі`, назва плану «План від …») у рядку `Causing statement: … parameters: …` тексту `SqliteException` трьох записів `ERROR storage: write failed`. Причина — `_write` у data/drift_repositories.dart передавав у лог сам виняток, а його `toString()` містить SQL-оператор і значення параметрів. Виправлення — опис винятку без тексту оператора й параметрів (`SqliteException(<код>): <повідомлення>` або лише тип, зокрема `DriftRemoteException`), стек зберігається. Повторний контрольний запуск: збігів 0, ERROR — 3 без вмісту полів. Логи першого й проміжного запусків видалено, у репозиторій не потрапили. Вимога: рішення 3 етапу 1, REQ-NF-004.

**Рішення людини щодо групи 3 (13.11.2026):**
1. ADDITIONAL_PROPERTIES, MIN_PROPERTIES, MAXIMUM (позиція), REQUIRED (поле режиму) — прийнято (правило «ключове слово схеми»). Перелік `constraint` реалізації: з прикладів контракту — MIN_LE_MAX, MINIMUM, TOTAL_GREATER_THAN_ZERO, DICTIONARY_VALUE, INVALID_JSON, WITHIN_VARIANT_RANGE, NOT_EDITABLE; за ключовими словами схеми — REQUIRED, MIN_LENGTH, MIN_ITEMS, INTEGER, HTTPS, MAXIMUM, ADDITIONAL_PROPERTIES, MIN_PROPERTIES.
2. Позиція `n` — рішення етапу 9, «Відкладено».
3. Відсутні поля режиму в add / replace (REQUIRED), 4. відсутні `openPlanId` / `sourcePlanId` / `name` (400), 7. назва відкритого плану після збереження — прийнято, «Відкладено»: специфікація не визначає, коди оголошені в контракті.
5. Міграція не потрібна: релізу й даних користувачів немає (D-26); `schemaVersion` 1; локальну БД розробки людина видалила.
6. Копіювання збережених попереджень в openSavedPlan і перерахунок FILTER_MISMATCH після зміни — прийнято (D-06).
8. Нічого не змінювати: тип винятку зі стеком без вмісту полів виконує рішення 3 етапу 1.

**Повний діалог:** не збережено агентом

**Коміт:** `ad4a0c0` feat: [agent] T-41, T-42 open plan editing and saved training plans (`git log --oneline -1`).

## Етап 13. Реалізація, група 4: T-44, T-45, T-46 (поточне заняття, завершення, історія, API-частина) — 13.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Та сама процедура й правила, що для груп 1–3. T-44: startCurrentSession, getCurrentSession (робоча копія плану, час і локальна дата старту, SESSION_ALREADY_ACTIVE, D-17, D-18 — лише в пам'яті). T-45: updateExecutedPlanItem, deleteExecutedPlanItem, completeTraining з атомарним записом у Drift і STORAGE_WRITE_FAILED, abortCurrentSession (D-19, EXECUTED_PLAN_EMPTY, NO_CURRENT_SESSION). T-46: listCompletedTrainings (від новіших до старіших за часом старту), getCompletedTraining (копії лише для читання, D-20).
2. Коміт `feat: [agent] T-44, T-45, T-46 current session, completion and history` — зупинитися й показати `git diff --cached --stat`.

**Пропозиція агента та дії:**
- Тести групи — 5 файлів: current_session/session_start_test.dart (10, T-24 → T-44), current_session/session_finish_test.dart (24, T-25 → T-45), completed_trainings/history_test.dart (6, T-26 → T-46), storage/storage_test.dart (8; 3 червоні після групи 3), training_plans/save_reopen_test.dart (24; 1 червоний після групи 3).
- Червоний запуск до змін (src/ = коміт `ad4a0c0`): `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-red-g4-20261113.log dart test test/current_session/ test/completed_trainings/history_test.dart test/storage/storage_test.dart test/training_plans/save_reopen_test.dart --reporter compact --file-reporter json:../logs/app/control-red-g4-20261113.jsonl` → код виходу 1; `python3 -I tool/red_check.py …` → код виходу 0: 5 наборів, 72 тести; 43 `failure`, у кожного перша помилка — «status 501» (startCurrentSession — 35, listCompletedTrainings — 3, abortCurrentSession, completeTraining, deleteExecutedPlanItem, getCompletedTraining, getCurrentSession — по 1); інших причин і «Failed to load» — 0; пройшли 29 — тести груп 1–3 у storage_test (5) і save_reopen_test (23) та статичний D-20 history_test (1). Лог: 697 записів, INFO 631, WARNING 63, ERROR 3 (очікувані збої запису тестів AC-NF-003 групи 3, без вмісту полів); 274 запити, з них 43 — 501.
- Реалізація (лише src/; схема Drift не змінювалась):
  - `domain/training_json.dart` (новий) — wire-форма `ExecutedPlan`, `CurrentSession`, `CompletedTraining`; `format: date` (`YYYY-MM-DD`), локальна дата з локального часу;
  - `domain/plan_rules.dart` — `resolveItemParameters(…, withinVariant: false)` для фактичних значень (D-19, SRS §5.3): цілі ≥ 1 (відпочинок ≥ 0), межі варіанта не застосовуються, лише поля режиму;
  - сервіси (`application/training_services.dart`):
    - T-44 `startCurrentSession`: 409 SESSION_ALREADY_ACTIVE, якщо заняття вже є (дані наявного не змінюються, AC-F-012 п. 4) → 422 OPEN_PLAN_NOT_FOUND → 422 PLAN_EMPTY; `startedAt` і `localStartDate` — момент обробки за підставленим годинником; виконаний план — копія етапів відкритого плану; план не зберігається (D-17); `getCurrentSession` — 404 NO_CURRENT_SESSION (після перезапуску, D-18);
    - T-45 `updateExecutedPlanItem` (404 NO_CURRENT_SESSION → 404 NOT_FOUND → 422 VALIDATION_FAILED; тривалість елемента перераховується за §5.4), `deleteExecutedPlanItem` (повне спорожнення дозволене, BDD-028), `abortCurrentSession` (заняття закривається без запису), `completeTraining` (409 NO_CURRENT_SESSION → 422 EXECUTED_PLAN_EMPTY → запис → заняття більше не поточне; збій запису → 500 STORAGE_WRITE_FAILED, заняття лишається поточним);
    - T-46 `listCompletedTrainings` (новіші `startedAt` зверху, не за моментом завершення), `getCompletedTraining` (404 NOT_FOUND; збережена копія, D-20);
  - сховища: `InMemoryCurrentSessionStore` — одне заняття в пам'яті процесу; `DriftCompletedTrainingRepository` — вставка одним оператором INSERT (атомарно), читання, перелік; вибір за локальною датою (аналітика) — група 5, заглушка;
  - HTTP: декодер `ExecutedPlanItemPatchRequest` (поле поза `parameters`, зокрема `stage`, `position` → 422 `ADDITIONAL_PROPERTIES`; `repetitionTimeSeconds` → `NOT_EDITABLE`; поле іншого режиму → `ADDITIONAL_PROPERTIES`; 0 → `MINIMUM`; неціле → `INTEGER`), декодер `CompleteTrainingRequest` (тіло необов'язкове; відсутнє тіло, `{}` чи `note: null` — без примітки; неправильний тип → 400); кодувальники `CurrentSession` (201 з `Location: /current-session`), `CompletedTraining` (201 з `Location: /completed-trainings/{id}`), `CompletedTrainingList`; статус коду залежить від операції: NO_CURRENT_SESSION — 409 для completeTraining (`NoCurrentSessionConflict`), 404 для решти; SESSION_ALREADY_ACTIVE — 409; EXECUTED_PLAN_EMPTY — 422;
  - логування: логер `trainings` — старт (ID відкритого й вихідного плану, кількість вправ), зміна й видалення вправ виконаного плану (ID), припинення, завершення (ID запису, локальна дата, кількість вправ, `note=true|false`); текст примітки не логується.

**Запуски після реалізації (13.11.2026):**
- Тести групи (5 файлів): 70 `success`, 2 `failure` — `BDD-026 POS-29 AC-F-013 abortCurrentSession: … history, analytics for the period and the saved plan are unchanged …` і `BDD-046 D-18 CON-007 AC-F-012 … after a restart there is no current session; history and analytics are unchanged`: перша помилка — 501 на getAnalytics (група 5).
- Повний набір — він же контрольний запуск: `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-green-g4-20261113.log dart test --reporter compact --file-reporter json:../logs/app/control-green-g4-20261113.jsonl` → код виходу 1. Звірка `green_check.py` (множина реалізованих операцій — групи 1–4) з logs/app/control-green-g3-20261113.jsonl:
  - 325 тестів, «Failed to load» — 0;
  - пройшли 307 = 251 (групи 1–3) + 56: session_finish — 23, session_start — 9, contract (`never 501`) — 8, catalog_version — 7, history — 5, storage — 3, save_reopen — 1;
  - 18 `failure` — у кожного перша помилка 501 на getAnalytics (analytics_test.dart — 15, AC-NF-006 «never 501» для getAnalytics, BDD-026, BDD-046); інших причин — 0; регресій відносно групи 3 — 0.
- storage_test.dart — 8 з 8; save_reopen_test.dart — 24 з 24; history_test.dart — 6 з 6.
- BDD-035 (catalog_version_test.dart): усі 7 тестів проходять уже після групи 4 — їм потрібні лише операції груп 1–4. Встановлення версії test-2 у лозі: `catalog installed version=test-2 previous=test-1 … initial=8 markedDeprecated=[]` — 7 разів: у фікстурі ex-1 позначена застарілою в самих даних, тому гілка «початкова вправа відсутня в новій версії → застаріла» (питання 5 групи 1) тестами не виконується.
- `dart analyze --fatal-infos` у src/ і tests/ → «No issues found!»; `git diff --quiet 5962e33 -- tests spec` → без відмінностей.

**Аналіз логу logs/app/control-green-g4-20261113.log (скрипт `log_check.py`, поза репозиторієм):**
- 2496 записів, INFO — 2340, WARNING — 152, ERROR — 4; 156 рядків — кадри стеку чотирьох записів ERROR.
- ERROR — 4, усі очікувані збої запису тестів AC-NF-003 / BDD-021 зі сховищем лише для читання: `completedTraining.insert` (новий, BDD-021), `trainingPlan.insert`, `trainingPlan.update`, `trainingPlan.delete`; опис — лише `DriftRemoteException` і стек; кожному відповідає WARNING `STORAGE_WRITE_FAILED status=500`.
- 951 запит; операції групи 4: startCurrentSession 201 — 59, 409 — 1, 422 — 3; getCurrentSession 200 — 18, 404 — 5; abortCurrentSession 204 — 2, 404 — 2; updateExecutedPlanItem 200 — 3, 404 — 3, 422 — 10; deleteExecutedPlanItem 200 — 6, 404 — 3; completeTraining 201 — 33, 400 — 1, 409 — 3, 422 — 1, 500 — 1; listCompletedTrainings 200 — 14; getCompletedTraining 200 — 16, 404 — 2. getAnalytics — лише 501 (18).
- WARNING: 18 — `not implemented` (getAnalytics); 134 — `domain error` з кодами контракту; для updateExecutedPlanItem — `parameters.rounds:MINIMUM`, `parameters.sets:MINIMUM`, `parameters.repetitions:MINIMUM`, `parameters.intervalSeconds:MINIMUM`, `parameters.restSeconds:MINIMUM`, `parameters.rounds:INTEGER`, `parameters.rounds:ADDITIONAL_PROPERTIES`, `parameters.repetitionTimeSeconds:NOT_EDITABLE`, `stage:ADDITIONAL_PROPERTIES`, `position:ADDITIONAL_PROPERTIES`.
- Логер `trainings`: старт — 59 (з незбереженого плану — 48, зі збереженого — 11), завершення — 33 (з приміткою — 3), припинення — 2; тексту приміток немає.
- Тривалість запитів 0–366 мс (найдовший — перший запит процесу).
- Даних користувача й абсолютних шляхів немає (пошук етапу 10 і `/Users/` — збігів 0).
- Висновок: ERROR лише для змодельованих збоїв запису без вмісту полів; WARNING — заглушка getAnalytics і очікувані відмови з кодами контракту.

**Питання до специфікації (передано людині):**
1. Порядок перевірок startCurrentSession: спершу SESSION_ALREADY_ACTIVE (409), потім OPEN_PLAN_NOT_FOUND / PLAN_EMPTY (422). Контракт порядку не визначає; тести перевіряють кожен випадок окремо.
2. `ExecutedPlanItemPatchRequest`: поле поза `parameters` позначається `ADDITIONAL_PROPERTIES` під назвою самого поля (`stage`, `position`); `repetitionTimeSeconds` — `NOT_EDITABLE`, як у T-41. Тести перевіряють лише `field`.
3. Примітка — порожній рядок `""` зберігається як `""`, а не як `null` (контракт: «відсутня або null — порожнє значення»; про `""` не сказано). Не тестується.
4. Гілка D-06 «початкова вправа відсутня в новій версії → застаріла» (питання 5 групи 1) не виконується жодним тестом: фікстура catalog-v2 позначає ex-1 застарілою в даних. BDD-035 проходить.

**Рішення людини щодо групи 4 (13.11.2026):**
1. Спершу 409 SESSION_ALREADY_ACTIVE, потім 422 — прийнято, «Відкладено».
2. ADDITIONAL_PROPERTIES під назвою поля — прийнято.
3. Примітка `""` зберігається як `""` — прийнято, «Відкладено».
4. Гілку D-06 «відсутня в новій версії → застаріла» покрити тестом (вимога ЛР-5: для кожної реалізованої вимоги — тест) окремим кроком після групи 5: фікстура tests/fixtures/catalogs/catalog-v2-ex1-missing.json (test-2 без ex-1), тест «BDD-035 D-06 AC-F-001», доказ змістовності (тимчасово вимкнена гілка → тест падає, лог logs/app/control-red-d06-<дата>.log; код повернуто), TG-012 у logs/test-gate.md без зміни остаточного рішення, коміт `test: [agent] BDD-035 D-06 deprecation of missing exercise (TG-012)`.

**Повний діалог:** не збережено агентом

**Коміт:** `72eb9fb` feat: [agent] T-44, T-45, T-46 current session, completion and history (`git log --oneline -1`).

## Етап 14. Реалізація, група 5: T-47 (аналітика, API-частина) — 13.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Та сама процедура й правила. T-47: getAnalytics — період за замовчуванням (сьогодні й 29 попередніх днів), межі включно, INVALID_PERIOD, END_DATE_IN_FUTURE (D-21, D-22, D-35); день — локальна дата старту; частота — кількість тренувань із вправою.
2. Після групи 5 окремо: чи проходять усі 7 тестів BDD-035 і всі 325 тестів.
3. Коміт `feat: [agent] T-47 analytics` після показу `git diff --cached --stat`.

**Пропозиція агента та дії:**
- Тести групи — analytics/analytics_test.dart (15, T-27 → T-47) і тести інших файлів, що викликають getAnalytics: session_start_test.dart (BDD-046), session_finish_test.dart (BDD-026), operation_coverage_test.dart («never 501» для getAnalytics).
- Червоний запуск до змін (src/ = коміт `72eb9fb`): `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-red-g5-20261113.log dart test test/analytics/analytics_test.dart test/current_session/ test/contract/operation_coverage_test.dart --reporter compact --file-reporter json:../logs/app/control-red-g5-20261113.jsonl` → код виходу 1; `python3 -I tool/red_check.py …` → код виходу 0: 4 набори, 78 тестів; 18 `failure`, у кожного перша помилка — «getAnalytics: status 501 is not declared»; інших причин і «Failed to load» — 0; пройшли 60 — тести груп 1–4 у цих файлах. Лог: INFO 643, WARNING 64, ERROR 0; 290 запитів, з них 18 — 501.
- Реалізація (лише src/; схема Drift не змінювалась):
  - `domain/analytics_rules.dart` (новий): `resolvePeriod` — обидві дати відсутні → `to` = сьогодні (локальна дата за підставленим годинником), `from` = `to` − 29 днів (AC-F-015); лише одна дата → 422 INVALID_PERIOD (D-35; `to: REQUIRED_WITH_FROM` з прикладу контракту, для відсутньої `from` — `from: REQUIRED`); `from` > `to` → INVALID_PERIOD (`from: NOT_AFTER_TO`); `to` > сьогодні → END_DATE_IN_FUTURE (`to: NOT_AFTER_TODAY`, D-21); довжина не обмежена; `computeAnalytics` — `dailyCounts` для кожного дня періоду, зокрема 0 (D-22); сума дорівнює `completedTrainingCount`; день — локальна дата старту; частота — кількість тренувань, у яких вправа (за `exerciseId`) трапляється хоча б раз, незалежно від кількості включень і варіантів (AC-F-016); назва — з копії в найновішому тренуванні періоду (D-22);
  - сервіс `AnalyticsService.getAnalytics` — лише завершені тренування (поточне заняття не враховується, BDD-019); логує період і кількості;
  - репозиторій: `findByLocalStartDate` — `local_start_date BETWEEN from AND to` (текст `YYYY-MM-DD`, межі включно);
  - HTTP: декодер `from` / `to` (`format: date`; некоректна дата → 400 BAD_REQUEST — питання 7 етапу 7), кодувальник `Analytics`; статуси INVALID_PERIOD, END_DATE_IN_FUTURE — 422;
  - `errorStatus` тепер покриває всі 22 коди `Error.code`, тому гілку «код без статусу → 500» видалено з `middleware.dart`; заглушок `UnimplementedError` у src/ не лишилося (обробка 501 у middleware лишилась без змін).

**Запуски після реалізації (13.11.2026):**
- Тести групи (4 файли): 78 з 78 `success`.
- Повний набір — він же контрольний запуск: `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-green-g5-20261113.log dart test --reporter compact --file-reporter json:../logs/app/control-green-g5-20261113.jsonl` → код виходу 0, «+325: All tests passed!». Звірка `green_check.py` з logs/app/control-green-g4-20261113.jsonl: 325 тестів, 325 `success`, «Failed to load» — 0; нові — 18 (analytics — 15, BDD-026, BDD-046, «never 501» getAnalytics); регресій — 0.
- Окремо за запитом: **усі 325 тестів проходять**; **усі 7 тестів BDD-035** (catalog_version_test.dart) проходять — з групи 4.
- `dart analyze --fatal-infos` у src/ і tests/ → «No issues found!»; `git diff --quiet 5962e33 -- tests spec` → без відмінностей.

**Аналіз логу logs/app/control-green-g5-20261113.log (скрипт `log_check.py`, поза репозиторієм):**
- 2537 записів, INFO — 2393, WARNING — 140, ERROR — 4; 156 рядків — кадри стеку записів ERROR.
- ERROR — 4, ті самі очікувані збої запису, що в групі 4 (AC-NF-003, BDD-021; лише `DriftRemoteException` і стек).
- 971 запит; жодного 501; `not implemented` — 0. getAnalytics: 200 — 17, 422 — 4 (`INVALID_PERIOD from:NOT_AFTER_TO`, `INVALID_PERIOD to:REQUIRED_WITH_FROM`, `INVALID_PERIOD from:REQUIRED`, `END_DATE_IN_FUTURE to:NOT_AFTER_TODAY`).
- WARNING — 140, усі `domain error` з кодами контракту.
- Логер `trainings`: `analytics computed from=… to=… trainings=… exercises=…` — 17.
- Тривалість запитів 0–338 мс (найдовший — перший запит процесу).
- Даних користувача й абсолютних шляхів немає (пошук етапу 10 і `/Users/` — збігів 0).
- Висновок: усі операції реалізовано; ERROR лише для змодельованих збоїв запису без вмісту полів; WARNING — очікувані відмови з кодами контракту.

**Питання до специфікації (передано людині):**
1. Задано лише `to` → 422 INVALID_PERIOD з `from: REQUIRED` (ключове слово схеми; аналога REQUIRED_WITH_FROM для `from` у контракті немає; тест перевіряє лише код).
2. Некоректна дата в query (`2026-13-01`, не `YYYY-MM-DD`) → 400 BAD_REQUEST (питання 7 етапу 7, «Відкладено»). Не тестується.
3. Якщо одночасно `from` > `to` і `to` > сьогодні, повертається INVALID_PERIOD (перевірка порядку дат іде першою). Контракт порядку не визначає; не тестується.
4. Порядок `exerciseFrequencies` — порядок першої появи вправи в тренуваннях періоду від старіших до новіших (контракт: «порядок не визначається»).

**Наступний крок (рішення 4 групи 4):** тест гілки D-06 «відсутня в новій версії → застаріла» (TG-012) — після коміту групи 5.

**Рішення людини щодо групи 5 (13.11.2026):** питання 1–4 — прийнято, «Відкладено»: специфікація не визначає, використано коди контракту. Перед комітом підтвердити, що після видалення гілки «код без статусу → 500» непередбачений виняток записується як ERROR зі стеком (рішення 3 етапу 1).

**Підтвердження (13.11.2026):** гілка `catch (error, stackTrace)` в `operation()` (src/lib/src/http/middleware.dart) і `requestLogging()` не змінювались; видалено лише перевірку `status == null`, яка стала недосяжною. Перевірка запуском: скрипт поза репозиторієм (scratchpad, `dart --packages=.dart_tool/package_config.json unhandled_probe.dart`) склав `requestLogging()` + `operation('probeOperation', …)` з обробником, що кидає `StateError`. Вивід: `ERROR http: unhandled exception operationId=probeOperation`, `error: Bad state: probe failure`, `stack:` з кадрами `middleware.dart:32` і `:68`; далі `INFO http: request … status=500`. src/ і tests/ не змінювались, тому повний набір не повторювався.

**Спостереження під час перевірки (передано людині, не змінювалось):**
1. Непередбачений виняток дає 500 без тіла, а контракт описує модель `Error` для всіх 4xx / 5xx (рішення 4 групи 1 стосувалося ініціалізації каталогу). Код 500 у контракті є лише GENERATION_FAILED (generatePlan) і STORAGE_WRITE_FAILED (операції запису).
2. Для непередбаченого винятку в лог іде `error.toString()`. Збій читання SQLite (`SqliteException` / `DriftRemoteException`) містив би SQL-оператор і параметри, як у знахідці групи 3. Записи шляхом відсіювання тут не застосовано.

**Повний діалог:** не збережено агентом

**Коміт:** `e5a7406` feat: [agent] T-47 analytics (`git log --oneline -1`).

## Етап 15. TG-012: тест гілки D-06 «відсутня в новій версії → застаріла» — 13.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Рішення 4 групи 4: фікстура tests/fixtures/catalogs/catalog-v2-ex1-missing.json — версія test-2 без ex-1 (решта як test-1); тест з ID «BDD-035 D-06 AC-F-001»: після встановлення цієї версії getExercise ex-1 → `deprecated: true`, listExercises її не показує; наявні тести не змінювати.
2. Довести змістовність: тимчасово вимкнути гілку в src/ → тест падає (вивід — logs/app/control-red-d06-<дата>.log), повернути код → тест проходить; у src/ після кроку змін немає.
3. TG-012 у logs/test-gate.md («доповнення після GO»), без зміни остаточного рішення. Коміт `test: [agent] BDD-035 D-06 deprecation of missing exercise (TG-012)`.

**Пропозиція агента та дії:**
- Фікстуру виведено скриптом Python із src/assets/catalog/test-catalog.json (без ex-1, `catalogVersion: test-2`, власний `source`), записано інструментом Write; звірка скриптом: довідники й 7 вправ (ex-2, ex-3, ex-4, ex-6, ex-7, ex-8, ex-9) дорівнюють test-1 без ex-1.
- Тест — новий файл tests/test/exercises/catalog_missing_exercise_test.dart (наявні файли тестів не змінено): старт на test-1 (ex-1 `deprecated: false`), перезапуск на тій самій БД з новою версією (як у catalog_version_test.dart), getExercise ex-1 → `deprecated: true`, listExercises без ex-1. Джерела: ADD-001 D-06, AC-F-001 пп. 5–6, BDD-035, контракт getExercise / listExercises.
- Тест із робочою реалізацією: 1 з 1 `success`.
- Доказ змістовності: у `installCatalog` (src/lib/src/data/drift_repositories.dart) умову позначення застарілих тимчасово вимкнено (`false && …`). Запуск `dart test test/exercises/catalog_missing_exercise_test.dart --no-color --reporter compact --file-reporter expanded:../logs/app/control-red-d06-20261113.log` → код виходу 1; причина — `Expected: true, Actual: <false>` (рядок 33, `card['deprecated']`), не помилка компіляції; лог застосунку цього запуску (scratchpad): `catalog installed version=test-2 previous=test-1 … initial=7 markedDeprecated=[]`.
- Код повернуто інструментом редагування; `git diff --quiet e5a7406 -- src` → без відмінностей. Повторний запуск тесту — 1 з 1 `success`; лог застосунку: `markedDeprecated=[ex-1]`.
- Повний набір: `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-green-tg012-20261113.log dart test --reporter compact --file-reporter json:../logs/app/control-green-tg012-20261113.jsonl` → код виходу 0; 326 тестів (325 + новий), 326 `success`, регресій 0. Лог: INFO 2401, WARNING 140, ERROR 4 (ті самі змодельовані збої запису); даних користувача й абсолютних шляхів немає.
- `dart analyze --fatal-infos` у src/ і tests/ → «No issues found!».
- logs/test-gate.md: у реєстр додано рядок TG-012 і примітку «TG-012 додано 13.11.2026 після GO; «Остаточне рішення» не змінюється». Розділ «Остаточне рішення» не змінено.
- Коміт: CLAUDE.md дозволяє агентові комітити лише src/, tests/, docs/, logs/app/, logs/agent-session-lab5.md; logs/test-gate.md до переліку не входить, тому його зміну не проіндексовано — рішення про коміт цього файлу передано людині.

**Повний діалог:** не збережено агентом

**Рішення людини (13.11.2026):** коміт TG-012 у показаному складі підтверджено; logs/test-gate.md людина комітить сама.

**Коміт:** `bcf6e35` test: [agent] BDD-035 D-06 deprecation of missing exercise (TG-012) (`git log --oneline -1`).

## Етап 16. Логування непередбачених винятків без вмісту полів (REQ-NF-004) — 13.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Рішення людини щодо спостережень етапу 14 (13.11.2026):**
1. Ризик 1 (500 без тіла для непередбаченого винятку) — не змінювати: у enum `Error.code` немає загального коду, 500 оголошено лише для операцій запису; будь-яка відповідь була б поза контрактом. Статус «Відкладено».
2. Ризик 2 (текст винятку в лозі) — виправити: у загальному catch логувати так само, як для збою запису (тип винятку, код SQLite, якщо доступний, і стек, без тексту винятку); перевірити окремим скриптом зі `StateError` і `SqliteException`; повний набір тестів, `dart analyze`, контрольний лог control-green-logfix-<дата>.log з аналізом. Коміт `feat: [agent] sanitize unexpected exception logging (REQ-NF-004)`.

**Пропозиція агента та дії:**
- Пошук `severe(` у src/lib і src/bin: сирий виняток (`error`) передавався в лог у 6 місцях — загальний catch `operation()` і `requestLogging()` (http/middleware.dart), технічна помилка генератора (application/plan_services.dart), збій ініціалізації каталогу (composition_root.dart), два `startup failed` (bin/server.dart). У запису сховища (data/drift_repositories.dart) уже діяв безпечний опис групи 3.
- Опис винесено в модуль логування: `safeErrorDescription` (logging/app_logging.dart) — для `SqliteException` код результату, повідомлення й пояснення SQLite (без `causingStatement` і `parametersToStatement`), для будь-якого іншого винятку — лише тип (зокрема `DriftRemoteException`, бо його текст — повний текст SQLite). Застосовано в усіх 7 місцях; локальну функцію drift_repositories.dart видалено. Відповіді клієнтові не змінювались (ризик 1).
- Перевірка скриптом поза репозиторієм (scratchpad, `dart --packages=src/.dart_tool/package_config.json logfix_probe.dart`): `requestLogging()` + `operation(…)` з обробником, що кидає (а) `StateError('[TEST] Секретна назва плану')`, (б) `SqliteException` з `causingStatement` `SELECT * FROM "training_plans" WHERE "name" = ?` і параметром `[TEST] Спаринговий день`. Лог: `ERROR http: unhandled exception operationId=probeStateError` / `error: StateError` / `stack:` і `ERROR http: unhandled exception operationId=probeSqlite` / `error: SqliteException(11): database disk image is malformed, corrupt` / `stack:`; відповідь — 500 без тіла. Пошук у лозі `[TEST]`, `Секретна`, `Спаринговий`, `SELECT`, `training_plans`, `parameters` — збігів 0; записів зі стеком — 2.
- Збій ініціалізації каталогу (`dart run bin/server.dart --db=:memory: --catalog=assets/catalog/missing.json`, лог у scratchpad): код виходу 1; `ERROR app: catalog initialization failed` / `error: PathNotFoundException` / `stack:`; `ERROR server: startup aborted …`. Шлях до ресурсу каталогу видно в записі `app composed … catalog=…`; текст винятку (зокрема шлях) у записі ERROR більше не з'являється — порівняно з logs/app/control-T-32-20261113.log.
- `dart analyze --fatal-infos` у src/ і tests/ → «No issues found!».
- Повний набір — контрольний запуск: `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-green-logfix-20261113.log dart test --reporter compact --file-reporter json:../logs/app/control-green-logfix-20261113.jsonl` → код виходу 0; 326 тестів, 326 `success`; звірка з logs/app/control-green-tg012-20261113.jsonl — регресій 0. `git diff --quiet bcf6e35 -- tests spec` → без відмінностей.

**Аналіз логу logs/app/control-green-logfix-20261113.log (скрипт `log_check.py`, поза репозиторієм):**
- 2545 записів, INFO — 2401, WARNING — 140, ERROR — 4; 156 рядків — кадри стеку записів ERROR.
- ERROR — 4, змодельовані збої запису (AC-NF-003, BDD-021): `completedTraining.insert`, `trainingPlan.insert`, `trainingPlan.update`, `trainingPlan.delete`; опис — `DriftRemoteException` і стек. `unhandled exception` — 0 (у тестах непередбачених винятків немає).
- 974 запити, 501 — 0; WARNING — 140, усі `domain error` з кодами контракту.
- Тривалість запитів 0–499 мс (найдовший — перший запит процесу).
- Даних користувача й шляхів до домашнього каталогу немає (пошук етапу 10 і `/Users/` — збігів 0); шлях тимчасової БД тестів у записі `app composed` — системний (уточнено за рішенням людини 14.11.2026, етап 18, IG-002).
- Висновок: записи ERROR будь-якого походження містять лише тип винятку (і код SQLite, якщо доступний) та стек; вмісту полів і SQL у лозі немає.

**Повний діалог:** не збережено агентом

**Коміт:** `274638a` feat: [agent] sanitize unexpected exception logging (REQ-NF-004) — створено людиною вручну (коміт агента перервано). Наступний коміт людини: `1003649` docs: [agent] add TG-012 to TEST-GATE record (logs/test-gate.md). Хеші — з `git log --oneline -5`.

## Етап 17. Крок 3: рефакторинг без зміни зовнішньої поведінки; скрипт перевірки через Prism proxy — 14.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запити:**
1. Аналіз без змін: проблеми коду з посиланнями на файли й рядки (дублювання, задовгі методи й файли, змішування відповідальностей, магічні значення) і план малими кроками; зупинитися до погодження. Змінювати лише src/; tests/ і spec/ не змінювати; нової функціональності не додавати; межі компонентів і семантика логування зберігаються.
2. Після погодження — кожен крок окремо: зміна → повний набір (326) → `dart analyze --fatal-infos` → `git diff --cached --stat` → коміт `refactor: [agent] …`.
3. Контрольний лог control-green-refactor-<дата>.log і порівняння з еталоном за типами й рівнями записів, без даних користувача.
4. Скрипт tests/tool/prism_check.sh для людини: curl-запити до Prism proxy 127.0.0.1:4010, кожна з 27 операцій хоча б раз (POS із docs/api/scenarios.md з підготовкою стану; NEG без стану), заголовки `sl-violations`, підсумок у logs/app/contract-prism-<дата>.log; не запускати.

**Аналіз (крок 1, без змін; довжини методів — скрипт `method_lengths.py` поза репозиторієм):**
- Дублювання: робочі списки етапів і пошук елемента (plan_services.dart / training_services.dart), підрахунок елементів, перенумерація позицій, перетворення `StorageWriteException` → STORAGE_WRITE_FAILED у трьох сервісах, ручне копіювання `PlanItem` / `PlanContent`, `_wire` = `_enum` (plan_json / exercise_json), серіалізація етапів (і подвійний `planContentToJson` у сховищі), `_recommended` / `_bound` генератора, повтор завершення в bin/server.dart.
- Задовгі методи / файли: `buildRouter` 209 рядків, `PlanGenerator.generate` 114, `buildApp` 94, `generatePlan` 74, `exerciseInput` 72; json_mapping.dart 734 рядки (чотири відповідальності), plan_services.dart 567 (три сервіси).
- Змішування відповідальностей: правило попереджень у `recomputePlan` разом із читанням репозиторію; доменна `localDateOf` у модулі формату передачі.
- Магічні значення: 3600 / 60 / 59, 9 / 10 / 11 (допуск), нижні межі SRS §5.3 (1 / 0) у двох модулях, −29 (період D-21), `'completeTraining'`, content-type, RegExp дати, 16 / 256 (id).
- Публічні назви, які використовують тести (`grep` по tests/test): `buildApp`, `AppConfig`, `Clock`, `RandomSource`, `LogSink`, `operationIds` — не змінювались.

**Рішення людини (14.11.2026):** гілку `UnimplementedError` → 501 не видаляти (змінило б поведінку); два розбори дат лишити окремими (різна поведінка при помилці); у prism_check.sh id витягувати python3, не jq; кроки R1–R10 і серію комітів погоджено; перед комітом виводити `git diff --cached --stat` і результат тестів без очікування підтвердження; зупинитися, якщо не 326 з 326, є зауваження analyze або потрібна зміна tests/, spec/, текстів логів чи публічних назв, що їх використовують тести.

**Пропозиція агента та дії (крок 2).** Для кожного кроку — скрипт `check_step.sh` поза репозиторієм: `dart test` (лог застосунку — у scratchpad) і `dart analyze --fatal-infos` у src/ і tests/. Результат кожного кроку: 326 тестів, 326 `success`; analyze — «No issues found!» в обох пакетах. Зупинок не було.

| Крок | Зміна | Коміт |
|---|---|---|
| R1 | `itemCount`, `stageWorkingLists`, `locateItem`, `renumberStages` у domain/plan_rules.dart замість копій у двох сервісах | `d4c44d5` refactor: [agent] extract shared stage list helpers |
| R2 | `PlanItem.copyWith`, `PlanContent.copyWith`; `withName` видалено | `406c6b0` refactor: [agent] add copyWith to plan item and content |
| R3 | `guardStorageWrite` (application/storage_write.dart) у трьох сервісах | `9655c2b` refactor: [agent] unify storage write failure mapping |
| R4 | доменне `planWarnings(...)`; `recomputePlan` лише читає каталог | `616004f` refactor: [agent] move plan warnings rule to domain |
| R5 | `enumFromJson`, `stagesToJson`, `warningsToJson`; `localDateOf` → domain/training.dart | `7961e5f` refactor: [agent] deduplicate wire helpers |
| R6 | іменовані константи (`secondsPerHour`, `maxTargetMinutes`, межі допуску, `minCountValue`, `minRestSeconds`, `defaultPeriodDays`, `jsonContentType`, шаблон дати, довжина id) | `ce0ed52` refactor: [agent] name magic values |
| R7 | json_mapping.dart → request_decoder.dart, body_reader.dart, response_encoder.dart, error_mapping.dart; `_variant` виділено з `exerciseInput` | `759cfe7` refactor: [agent] split http json mapping by responsibility |
| R8 | plan_services.dart → plan_generation_service.dart, open_plan_service.dart, training_plan_service.dart; експорти boxing_api.dart оновлено | `13ff5da` refactor: [agent] split plan services into files |
| R9 | `generate` → `_candidates`, `_requireNoCandidateGap`, `_requireVolumeWithinBounds`, `_search`; `_pick`, `_rests`; у `generatePlan` — `_toOpenPlan`, `_reasonsForLog` | `7a2ef7e` refactor: [agent] split plan generator steps |
| R10 | `buildRouter` → групи маршрутів класу `_Routes`; `_openDatabase`, `_buildServices`; у server.dart `closeSinks` / `abort` | `d60d9de` refactor: [agent] split router and composition root |

- Збереження поведінки: порядок викликів `random` і `ids` у генерації не змінювався (від нього залежать детерміновані тести); перенесений код R7 і R8 звірено `diff` з попередньою версією (відмінність лише у виділеному `_variant`); для R10 скриптом перевірено, що 27 маршрутів зареєстровано в тому самому порядку і з тими самими викликами decode / service / encode.
- bin/server.dart тести не покривають, тому окремо запущено сервер (логи в scratchpad): `--catalog=assets/catalog/missing.json` → код виходу 1, `ERROR app: catalog initialization failed`, `ERROR server: startup aborted …` (як на етапі 16); звичайний старт → `listExercises` 200, SIGINT → `stopping` / `stopped`, код виходу 0.
- Файли json_mapping.dart і plan_services.dart прибрано командами `git rm` / `git mv` (інструмент редагування не видаляє файли), вміст перенесено інструментом Write / Edit.
- Після рефакторингу найдовші методи (той самий скрипт): `resolveItemParameters` 95, `_Routes.plans` 77 (таблиця маршрутів), `_fit` 63, `buildApp` 61; найбільший файл — plan_generator.dart, 461 рядок. `resolveItemParameters` і `_fit` не змінювались: їх немає в погодженому плані.

**Контрольний запуск (крок 3):** `BOXING_API_TEST_LOG_DIR=../logs/app BOXING_API_TEST_LOG_FILE=control-green-refactor-20261114.log dart test --reporter compact --file-reporter json:../logs/app/control-green-refactor-20261114.jsonl` → код виходу 0; `dart analyze --fatal-infos` у src/ і tests/ → «No issues found!».

**Аналіз логу logs/app/control-green-refactor-20261114.log (скрипт `log_compare.py`, поза репозиторієм; еталон — logs/app/control-green-logfix-20261113.log, src/ на `274638a`):**
- Записів 2545 / 2545; INFO 2401, WARNING 140, ERROR 4 — як в еталоні.
- Логер + рівень: app INFO 365, catalog INFO 466, http INFO 974, http WARNING 140, plans INFO 452, storage ERROR 4, trainings INFO 144 — збігаються.
- Шаблони повідомлень (значення `key=value` замінено на `*`): 37 / 37, множини й кількості збігаються.
- ERROR — 4 змодельовані збої запису (`completedTraining.insert`, `trainingPlan.insert`, `trainingPlan.update`, `trainingPlan.delete`), опис `DriftRemoteException`, зі стеком. Рядків логу 2710 проти 2709: у стеку `completedTraining.insert` з'явився кадр `guardStorageWrite` (раніше там був inline try); текст записів не змінився.
- WARNING — коди контракту, розподіл за кодами збігається з еталоном; `unhandled exception` — 0, `not implemented` — 0; запитів 974 / 974.
- Пошук `[TEST]`, `/Users/`, `SELECT`, `INSERT`, `Секретна`, `Ранкове` — збігів 0.
- Тести: 326 / 326 `success`, ті самі назви, регресій 0 (звірка з control-green-logfix-20261113.jsonl).
- Висновок: зовнішня поведінка й записи логу за типами й рівнями не змінились; даних користувача й шляхів до домашнього каталогу в лозі немає (шлях тимчасової БД тестів — системний; уточнено за рішенням людини 14.11.2026, етап 18, IG-002).

**Скрипт tests/tool/prism_check.sh (крок 4, не запускався):**
- Передумови в шапці: API на 127.0.0.1:8080 з `--db=:memory:` і тестовим каталогом (свіжий старт), Prism proxy `npx -y --registry=https://registry.npmjs.org/ @stoplight/prism-cli@5 proxy spec/openapi.yaml http://127.0.0.1:8080 -h 127.0.0.1 -p 4010`, curl і python3.
- 15 NEG без стану (NEG-02, 04, 05, 06, 13, 20, 24, 25, 27–33; NEG-24, 25, 30, 31 — до появи сесії); NEG-32 і NEG-33 порушують схему навмисно, тож порушення запиту для них очікуване.
- POS у порядку з підготовкою стану: власна вправа (id і варіант — з відповіді), генерація, зміни відкритого плану (id елемента — з `Location`), збереження, відкриття збереженого, перезапис, сесія (поле фактичного значення — за режимом елемента), завершення, історія, аналітика за останні 30 днів і без параметрів, друга сесія → abort, видалення плану. id витягуються python3 (рішення людини).
- У лог: для кожного виклику — ID сценарію, operationId, метод, шлях, статус, `sl-violations` і лише `code` тіла (без вмісту полів). Підсумок: кількість викликів, покриття 27 операцій, розбіжності статусів, очікувані й неочікувані порушення. Код виходу 0 / 1 / 2.
- Перевірки без запуску: `bash -n` — без помилок; у тексті 27 різних operationId у викликах `call`. Тіло POS-09 окремо перевірено запитом до локального сервера (не через скрипт): генерація успішна, три етапи. Права виконання встановлено `chmod +x`.
- Виконати скрипт і проаналізувати logs/app/contract-prism-<дата>.log має людина.

**Повний діалог:** не збережено агентом

**Коміт:** docs: [agent] refactoring control run and prism check script — журнал, контрольний лог (.log, .jsonl) і скрипт; хеш — у `git log` після коміту.

### Контрактна перевірка кроку 3 через Prism proxy — 14.11.2026
**Модель:** Claude Opus 5.5 (claude-opus-5-5), Claude Code у VS Code
**Запит:** людина запустила tests/tool/prism_check.sh через Prism proxy; проаналізувати logs/app/contract-prism-20261114.log і лог застосунку цього запуску: порушення `sl-violations` (крім очікуваних NEG-32, NEG-33), покриття 27 операцій, ERROR / WARNING і відсутність даних користувача. Якщо порушень немає — записати в журнал і закомітити; якщо є — зупинитися.

**Запуск (людина):** API на 127.0.0.1:8080 (`--db=:memory:`, тестовий каталог; лог logs/app/api-20261114-160403.log), Prism proxy на 127.0.0.1:4010, скрипт 14.11.2026 16:04:57.

**Аналіз logs/app/contract-prism-20261114.log (підсумок скрипта звірено окремим скриптом Python за рядками викликів):**
- Викликів 48; різних operationId — 27 з 27; не викликано — жодної.
- Розбіжностей статусів 0. Статуси: 200 — 23, 201 — 8, 204 — 2, 403 — 1, 404 — 4, 409 — 1, 422 — 9.
- `sl-violations` лише у двох викликах — NEG-32 `generatePlan` (`request.body.targetDuration.hours`, `minimum`) і NEG-33 `generatePlan` (`request.body`, `required` для `level`); обидва навмисно порушують схему, сервер відповів 422 VALIDATION_FAILED. Неочікуваних порушень (запитів і відповідей) — 0.
- Коди NEG збігаються з docs/api/scenarios.md: NO_CURRENT_SESSION (NEG-24, 25, 30, 31), NOT_FOUND (NEG-02), UNKNOWN_DICTIONARY_VALUE (NEG-05), INITIAL_EXERCISE_READ_ONLY (NEG-06), VALIDATION_FAILED (NEG-04, 32, 33), PLAN_NOT_FOUND (NEG-13), OPEN_PLAN_NOT_FOUND (NEG-20), INVALID_PERIOD (NEG-27, 28), END_DATE_IN_FUTURE (NEG-29).

**Аналіз logs/app/api-20261114-160403.log (скрипт Python поза репозиторієм):**
- 96 записів: INFO 81, WARNING 15, ERROR 0; записів зі стеком 0, `unhandled exception` 0.
- Запитів 49 по 27 operationId (48 викликів скрипта + перевірка доступності `GET /training-plans` на початку скрипта: `listTrainingPlans` — 3 записи); `operationId=-` — 0, статус 501 — 0.
- WARNING — 15 `domain error` з кодами контракту, по одному на кожен NEG-виклик: NO_CURRENT_SESSION 4, VALIDATION_FAILED 3, INVALID_PERIOD 2, NOT_FOUND, UNKNOWN_DICTIONARY_VALUE, INITIAL_EXERCISE_READ_ONLY, PLAN_NOT_FOUND, OPEN_PLAN_NOT_FOUND, END_DATE_IN_FUTURE — по 1.
- Даних користувача немає: пошук `[TEST]`, `Стрибки`, `Ранкове`, `віджимань` (тексти тіл запитів скрипта), `/Users/`, `SELECT`, `INSERT` — збігів 0. Шлях до логу у записі `starting` — відносний (`../logs/app/…`).
- Висновок: після рефакторингу реальні відповіді всіх 27 операцій відповідають spec/openapi.yaml за перевіркою Prism; порушення є лише в навмисно невалідних запитах NEG-32 і NEG-33.

**Рішення людини (14.11.2026):** logs/app/.gitignore пропускає лише `control-*.log`; лог перевірки додати `git add -f`, правила .gitignore не змінювати. Лог застосунку api-20261114-160403.log лишається локальним.

**Повний діалог:** не збережено агентом

**Коміт:** docs: [agent] Prism contract check after refactoring — журнал і logs/app/contract-prism-20261114.log; хеш — у `git log` після коміту.

## Етап 18. T-65: незалежна перевірка реалізації для IMPL-GATE (API-частина) — 14.11.2026
**Модель:** Claude Sonnet 5.5 (claude-sonnet-5-5), Claude Code у VS Code, нова сесія `ca768817-5f97-4133-a25a-98d5cb90b16b` (інша модель, ніж Claude Opus 5.5, що писала реалізацію, етапи 10–17)
**Запити:**
1. Незалежна перевірка для T-65 (гілка impl/lab5), нічого не змінювати в src/, tests/, spec/. Перевірити: (1) умови GO T-65 з plan.md §1.1 з урахуванням рішення людини про обсяг; (2) тести не послаблено (`git diff 90e0952..HEAD -- tests/ spec/`); (3) повний набір у tests/; (4) версії зафіксовано, Prism 5.16.0; (5) контрактна перевірка Prism; (6) логування; (7) поділ на компоненти; (8) рефакторинг не змінив поведінку.
2. Створити logs/impl-gate.md (чернетка за структурою logs/test-gate.md, «Остаточне рішення» порожнє); додати цей етап; закомітити лише журнал.

**Пропозиція агента та дії:**
- Прочитано умову GO T-65 (plan.md §1.1, decomposition.md), logs/test-gate.md (GO, базовий коміт `90e0952`, TG-012) і журнал (етапи 1, 10–17). Зовнішніх дій у трекері не виконувалось: `gh issue list` — лише читання.
- Результати за пунктами запиту (деталі й докази — logs/impl-gate.md):
  - п. 2: `git diff --name-status 90e0952..HEAD -- tests/ spec/` — лише три додані файли (фікстура й тест TG-012, `tests/tool/prism_check.sh`), 546 доданих рядків, видалених 0; `spec/` і `src/assets/catalog/test-catalog.json` (SHA-256 `f29ec074…9839`, TG-007) без змін. Виконано;
  - п. 3: `dart analyze --fatal-infos` у `tests/` і `src/` — «No issues found!»; `dart test` — 326 з 326 `success` (скрипт за JSON-звітом; код виходу процесу не знято, бо вивід передано в `tail`); `throw UnimplementedError` у `src/lib`, `src/bin` — 0. Виконано;
  - п. 4: Dart-пакети й SDK — точні версії, обидва `pubspec.lock` закомічено, `dart pub get --enforce-lockfile --offline` — код 0. **Не виконано:** у `prism_check.sh` рядок 16 — `@stoplight/prism-cli@5`, не `5.16.0`; версії Prism немає й у логу (IG-001);
  - п. 5: `logs/app/contract-prism-20261114.log` — 48 викликів, 27 з 27 операцій, розбіжностей статусів 0, порушення лише в навмисних NEG-32 і NEG-33, неочікуваних 0. Виконано (Prism агент не запускав);
  - п. 6: скрипт за 8 логами `control-green-*.log` — кожен запит має метод, operationId, статус, тривалість; усі 140 відповідей ≥ 400 мають WARNING `domain error`; 4 ERROR зі стеком; даних користувача й SQL немає. **Не виконано:** у всіх логах запис `app composed` містить абсолютний шлях до тимчасового файла БД (365 із 2545 записів у refactor-логу) — IG-002; шлях `unhandled exception` у закомічених логах не виконується — IG-005;
  - п. 7: усі сім компонентів наявні; `domain` не має імпортів інших шарів і пакетів; `http` не імпортує `data`. Виконано;
  - п. 8: logfix і refactor-логи — 2545 / 2545 записів, 28 / 28 шаблонів, однакова послідовність, повідомлення збігаються з точністю до ID, шляху й тривалості. Виконано;
  - п. 1: умова (в) «усі Feature закрито» виконана частково в межах обсягу: усі 21 issues `OPEN`, API-частини 14 тікетів реалізовано (IG-003).
- Реєстр зауважень IG-001…IG-005: блокувальне — IG-001 (версія Prism); неблокувальні — IG-002 (абсолютний шлях у логу), IG-003 (часткове закриття Feature), IG-004 (гілка 501 у middleware, прийнято раніше), IG-005 (непередбачені винятки не в закомічених логах).
- Дата гейту 14.11.2026; орієнтовна за plan.md §6.4 — 06.04.2027; відхилення −143 дні (скрипт Python).
- Скрипти аналізу (`ig_log_check.py`, `ig_compare.py`) і лог тестового запуску збережено поза репозиторієм (scratchpad сесії). `src/`, `tests/`, `spec/` не змінено; `git status --short` до і після перевірок порожній, окрім нових `logs/impl-gate.md` і цього журналу.
- logs/impl-gate.md створено інструментом запису; до переліку CLAUDE.md для комітів агента він не входить, тому не комітиться — його комітить людина. «Остаточне рішення» порожнє.

**Рішення людини щодо зауважень (14.11.2026):**
- IG-001: запуск 14.11.2026 людина виконала з `@stoplight/prism-cli@5.16.0`; рядок 16 `prism_check.sh` людина виправляє окремим комітом; після цього зауваження закрито.
- IG-002: неблокувальне; шлях тимчасової БД тестів — системний шлях, не дані користувача (REQ-NF-004 не порушено); код не змінюється. Формулювання етапів 16–17 уточнено: «шляхів до домашнього каталогу немає».
- IG-003: прийнято, issues не закриваються.
- IG-004: прийнято, рішення людини від 14.11.2026 (етап 17).
- IG-005: прийнято; тестових ендпоінтів немає за рішенням 5 етапу 1, перевірку скриптом записано в журнал (етап 16).
- Реєстр у logs/impl-gate.md оновлено (не індексується, коміт — за людиною). GO / REVISE за IMPL-GATE — за людиною.

**Повний діалог:** не збережено агентом

**Коміт:** docs: [agent] IMPL-GATE review stage — лише журнал; хеш — у `git log` після коміту.
