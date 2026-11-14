/// T-69 (#70): search of the catalog by a part of the exercise name.
///
/// Sources: ADD-003 D-36, D-37, D-38, D-39 (spec/addenda/ADD-003.md);
/// REQ-F-003, AC-F-003 (SRS v1.2); BDD-053; spec/openapi.yaml 1.1.0
/// listExercises, parameter nameContains; docs/api/scenarios.md, section
/// «ADD-003»: POS-37…POS-42, NEG-35.
///
/// Data of BDD-053 (supplied [TEST] catalog, T-57, and createExercise):
/// - A = ex-6 «[TEST] Прямий удар», initial, type single-punch;
/// - B = custom «[TEST] Серія: удар знизу», type combination;
/// - C = custom «[TEST] Бій з тінню», the description contains «удар»;
/// - E = ex-9 «[TEST] Застаріла вправа», initial, deprecated.
///
/// Not tested (issue #70, criterion 2): apostrophes and NFC / NFD (a
/// clarification of D-37, not an item of AC-F-003); a repeated parameter
/// (Q-ADD3-01, deferred). Leading and trailing white space is checked with
/// the ordinary space (Q-ADD3-03). D-40 is checked by the log analysis.
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

/// Reason of every item assertion; the red check script looks for it.
const itemsReason = 'listExercises items (ADD-003)';

void main() {
  final catalog = CatalogData.load(baseCatalog);
  late TestApp app;
  late String b;
  late String c;

  setUp(() async {
    app = await TestApp.start();
    b = (await app.api.createExerciseOk({
      ...ropeExerciseInput(),
      'name': '[TEST] Серія: удар знизу',
      'type': 'combination',
    }))['id'].asString;
    c = (await app.api.createExerciseOk({
      ...ropeExerciseInput(),
      'name': '[TEST] Бій з тінню',
      'description': '[TEST] Опис: удар у повітря без партнера.',
    }))['id'].asString;
  });

  Future<Set<String>> search(Map<String, Object> query) async {
    final res = await app.api.send('listExercises', query: query);
    expectStatus(res, 200);
    return res.body['items'].asJsonList.map((e) => e['id'].asString).toSet();
  }

  Future<void> expectItems(Map<String, Object> query, Set<String> expected) async {
    expect(await search(query), expected, reason: '$itemsReason query $query');
  }

  Set<String> allActive() => {
    ...catalog.activeExercises.map((e) => e['id'].asString),
    b,
    c,
  };

  group('T-69 BDD-053 listExercises nameContains: steps of the scenario', () {
    test('BDD-053 POS-37 D-36 D-37 AC-F-003 listExercises: «удар» → only A '
        '(initial) and B (custom); C (only the description) and deprecated E '
        'are not shown', () async {
      await expectItems({'nameContains': 'удар'}, {'ex-6', b});
    });

    test('BDD-053 POS-38 D-37 AC-F-003 listExercises: «УДАР» → the same items '
        'as «удар» (case is ignored)', () async {
      await expectItems({'nameContains': 'УДАР'}, {'ex-6', b});
    });

    test('BDD-053 POS-39 D-38 AC-F-003 listExercises: «  удар  » → the same '
        'items as «удар» (leading and trailing spaces are dropped)', () async {
      await expectItems({'nameContains': '  удар  '}, {'ex-6', b});
    });

    test('BDD-053 POS-40 D-39 AC-F-003 listExercises: «удар» AND type '
        'combination → only B', () async {
      await expectItems({'nameContains': 'удар', 'type': 'combination'}, {b});
    });

    test('BDD-053 D-36 D-06 AC-F-003 listExercises: «застаріла» → 200 and '
        'items [] (deprecated E is not shown)', () async {
      await expectItems({'nameContains': 'застаріла'}, {});
    });

    test('BDD-053 POS-41 D-39 AC-F-003 listExercises: «аперкот» (no match) → '
        '200 and items []', () async {
      await expectItems({'nameContains': 'аперкот'}, {});
    });

    test('BDD-053 POS-42 D-38 AC-F-003 listExercises: «   » (empty after the '
        'spaces are dropped) → all non-deprecated exercises', () async {
      await expectItems({'nameContains': '   '}, allActive());
    });
  });

  group('T-69 listExercises nameContains: case of Cyrillic letters (D-37)', () {
    test('D-37 AC-F-003 listExercises: «ВІДЖИМАННЯ» finds initial ex-3 '
        '«[TEST] Віджимання» (І / і)', () async {
      await expectItems({'nameContains': 'ВІДЖИМАННЯ'}, {'ex-3'});
    });

    // Words of the custom exercise name start with Ґ, Є, І, Ї.
    const words = [
      ('ҐАНОК', 'ґанок'),
      ('ЄНОТ', 'єнот'),
      ('ІНІЙ', 'іній'),
      ('ЇЖАК', 'їжак'),
    ];
    for (final (upper, lower) in words) {
      test('D-37 AC-F-003 createExercise listExercises: «$upper» and «$lower» '
          'find the custom exercise «[TEST] Ґанок Єнот Іній Їжак»', () async {
        final letters = (await app.api.createExerciseOk({
          ...ropeExerciseInput(),
          'name': '[TEST] Ґанок Єнот Іній Їжак',
        }))['id'].asString;
        await expectItems({'nameContains': upper}, {letters});
        await expectItems({'nameContains': lower}, {letters});
      });
    }
  });

  group('T-69 listExercises nameContains: name only, initial and custom (D-36)', () {
    test('D-36 AC-F-003 listExercises: «опис виконання» (only in descriptions) '
        '→ 200 and items []', () async {
      await expectItems({'nameContains': 'опис виконання'}, {});
    });

    test('D-36 AC-F-003 createExercise listExercises: «серія» finds only the '
        'custom exercise B', () async {
      await expectItems({'nameContains': 'серія'}, {b});
    });
  });

  group('T-69 listExercises nameContains: spaces (D-37, D-38)', () {
    test('D-37 AC-F-003 listExercises: «прямий удар» (one inner space) finds '
        'A', () async {
      await expectItems({'nameContains': 'прямий удар'}, {'ex-6'});
    });

    test('D-37 AC-F-003 listExercises: «прямий  удар» (two inner spaces) → 200 '
        'and items [] (inner spaces are not changed)', () async {
      await expectItems({'nameContains': 'прямий  удар'}, {});
    });

    test('D-38 AC-F-003 listExercises: empty value «» does not restrict the '
        'selection → all non-deprecated exercises', () async {
      await expectItems({'nameContains': ''}, allActive());
    });
  });

  group('T-69 listExercises nameContains: «AND» with filters (D-39)', () {
    test('D-39 D-09 AC-F-003 listExercises: «удар» AND stage main → only A', () async {
      await expectItems({'nameContains': 'удар', 'stage': 'main'}, {'ex-6'});
    });

    test('D-39 D-09 AC-F-003 listExercises: «прямий» AND type combination → 200 '
        'and items []', () async {
      await expectItems({'nameContains': 'прямий', 'type': 'combination'}, {});
    });

    test('NEG-35 D-39 AC-F-003 listExercises: «удар» with level level-unknown → '
        '422 UNKNOWN_DICTIONARY_VALUE (the search does not cancel the check of '
        'other filters)', () async {
      final res = await app.api.send(
        'listExercises',
        query: {'nameContains': 'удар', 'level': 'level-unknown'},
      );
      expectError(res, 422, 'UNKNOWN_DICTIONARY_VALUE');
      expectDetail(res, 'level', constraint: 'DICTIONARY_VALUE');
    });
  });
}
