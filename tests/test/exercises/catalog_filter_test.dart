/// T-14 (#15): filtering of the catalog; shared dictionaries.
///
/// Sources: AC-F-003; REQ-F-003, REQ-F-005; BDD-004, BDD-037 (D-09, ADD-002
/// D-34); D-06; SPEC-GATE v1.1 REV-004 (human decision: `not-applicable`
/// filter → 200 and an empty list); SRS §4.4; spec/openapi.yaml
/// listExercises, getDictionary; docs/api/scenarios.md POS-01, POS-02, POS-08,
/// NEG-05. Expected ids are derived from the supplied [TEST] catalog (T-57)
/// by the rules of AC-F-003 and D-09.
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

void main() {
  final catalog = CatalogData.load(baseCatalog);
  late TestApp app;

  setUp(() async => app = await TestApp.start());

  Future<Set<String>> filter(Map<String, Object> query) async {
    final res = await app.api.send('listExercises', query: query);
    expectStatus(res, 200);
    return res.body['items'].asJsonList.map((e) => e['id'].asString).toSet();
  }

  group('T-14 listExercises: each attribute (AC-F-003, D-09)', () {
    final cases = <(String, Map<String, Object>, Set<String>)>[
      ('stage warm-up', {'stage': 'warm-up'}, {'ex-1', 'ex-3', 'ex-8'}),
      ('stage main', {'stage': 'main'}, {'ex-2', 'ex-3', 'ex-6', 'ex-7'}),
      ('stage cool-down', {'stage': 'cool-down'}, {'ex-4'}),
      ('type single-punch', {'type': 'single-punch'}, {'ex-6'}),
      ('type combination', {'type': 'combination'}, {'ex-2', 'ex-7'}),
      ('level level-advanced', {'level': 'level-advanced'}, {'ex-7'}),
      (
        'level level-intermediate',
        {'level': 'level-intermediate'},
        {'ex-1', 'ex-4', 'ex-6'},
      ),
      ('intensity intensity-low', {'intensity': 'intensity-low'}, {'ex-1', 'ex-4'}),
      (
        'intensity intensity-high',
        {'intensity': 'intensity-high'},
        {'ex-2', 'ex-6', 'ex-7', 'ex-8'},
      ),
      ('emphasis emphasis-endurance', {'emphasis': 'emphasis-endurance'}, {'ex-2', 'ex-7'}),
      (
        'loadCharacter special-physical',
        {'loadCharacter': 'special-physical'},
        {'ex-1', 'ex-2', 'ex-6', 'ex-7', 'ex-8'},
      ),
      ('executionMeans means-pairs', {'executionMeans': 'means-pairs'}, {'ex-7'}),
      (
        'executionMeans means-no-equipment',
        {'executionMeans': 'means-no-equipment'},
        {'ex-1', 'ex-3', 'ex-4', 'ex-8'},
      ),
      ('equipment equipment-bag', {'equipment': 'equipment-bag'}, {'ex-2', 'ex-6'}),
      ('equipment equipment-pads', {'equipment': 'equipment-pads'}, {'ex-6'}),
    ];
    for (final (name, query, expected) in cases) {
      test('AC-F-003 listExercises: filter by $name', () async {
        expect(await filter(query), expected);
      });
    }
  });

  group('T-14 listExercises: «OR» within one attribute, «AND» across attributes', () {
    test('AC-F-003 D-09 listExercises: two stages are combined by OR', () async {
      expect(
        await filter({
          'stage': ['warm-up', 'cool-down'],
        }),
        {'ex-1', 'ex-3', 'ex-4', 'ex-8'},
      );
    });

    test('AC-F-003 D-09 listExercises: different attributes are combined by AND', () async {
      expect(await filter({'stage': 'main', 'level': 'level-beginner'}), {'ex-2', 'ex-3'});
      expect(
        await filter({
          'stage': 'main',
          'intensity': 'intensity-high',
          'emphasis': 'emphasis-endurance',
        }),
        {'ex-2', 'ex-7'},
      );
    });

    test('BDD-037 D-09 D-34 AC-F-003 listExercises: levels «beginner» OR '
        '«intermediate» give A, B and C; adding load character «ЗФП» leaves '
        'only A; C with «not applicable» is not shown; no filters give all', () async {
      // A = ex-3 (beginner, ЗФП), B = ex-6 (intermediate, СФП),
      // C = ex-4 (beginner, not applicable) — T-57, stage 5 of lab 5.
      final levels = ['level-beginner', 'level-intermediate'];
      expect(await filter({'level': levels}), containsAll(['ex-3', 'ex-6', 'ex-4']));
      expect(
        await filter({'level': levels, 'loadCharacter': 'general-physical'}),
        {'ex-3'},
      );
      expect(
        await filter({'loadCharacter': ['general-physical', 'special-physical']}),
        isNot(contains('ex-4')),
      );
      expect(
        await filter({}),
        catalog.activeExercises.map((e) => e['id']).toSet(),
      );
    });

    test('REV-004 D-09 D-34 AC-F-003 listExercises: filter loadCharacter '
        'not-applicable → 200 and an empty list', () async {
      final res = await app.api.send(
        'listExercises',
        query: {'loadCharacter': 'not-applicable'},
      );
      expectStatus(res, 200);
      expect(res.body['items'], isEmpty);
    });

    test('POS-02 AC-F-003 listExercises: no result → 200 and items []', () async {
      final res = await app.api.send(
        'listExercises',
        query: {'stage': 'cool-down', 'type': 'combination'},
      );
      expectStatus(res, 200);
      expect(res.body['items'], isEmpty);
    });

    test('POS-01 AC-F-003 listExercises: items have id, name, type and origin of '
        'the catalog exercise', () async {
      final res = await app.api.send(
        'listExercises',
        query: {'stage': 'warm-up', 'level': 'level-beginner'},
      );
      expectStatus(res, 200);
      for (final item in res.body['items'].asJsonList) {
        final source = catalog.exercise(item['id'].asString);
        expect(item, {
          'id': source['id'],
          'name': source['name'],
          'type': source['type'],
          'origin': source['origin'],
        });
      }
    });
  });

  group('T-14 listExercises: execution means and equipment of one variant', () {
    test('BDD-004 AC-F-003 listExercises: ex-6 (pads without bag, bag without '
        'pads) is not found by means «pads» AND equipment «bag»', () async {
      expect(
        await filter({'executionMeans': 'means-pads', 'equipment': 'equipment-bag'}),
        isNot(contains('ex-6')),
      );
    });

    test('BDD-004 AC-F-003 listExercises: ex-6 is found when means and '
        'equipment belong to the same variant', () async {
      expect(
        await filter({'executionMeans': 'means-pads', 'equipment': 'equipment-pads'}),
        {'ex-6'},
      );
      expect(
        await filter({'executionMeans': 'means-apparatus', 'equipment': 'equipment-bag'}),
        {'ex-2', 'ex-6'},
      );
    });

    test('AC-F-003 createExercise listExercises: custom exercises are filtered '
        'together with initial ones', () async {
      final created = await app.api.createExerciseOk(ropeExerciseInput());
      expect(await filter({'equipment': 'equipment-rope'}), {created['id']});
      expect(await filter({}), contains(created['id']));
    });
  });

  group('T-14 listExercises: unknown filter values', () {
    test('NEG-05 AC-F-003 listExercises: unknown dictionary value → 422 '
        'UNKNOWN_DICTIONARY_VALUE', () async {
      final res = await app.api.send(
        'listExercises',
        query: {'level': 'level-unknown'},
      );
      expectError(res, 422, 'UNKNOWN_DICTIONARY_VALUE');
      expectDetail(res, 'level', constraint: 'DICTIONARY_VALUE');
    });

    test('AC-F-003 listExercises: value outside the stage enumeration → 422 '
        'UNKNOWN_DICTIONARY_VALUE', () async {
      final res = await app.api.send(
        'listExercises',
        query: {'stage': 'stretching'},
      );
      expectError(res, 422, 'UNKNOWN_DICTIONARY_VALUE');
      expectDetail(res, 'stage');
    });
  });

  group('T-14 getDictionary: shared dictionaries (SRS §4.4)', () {
    const names = [
      'training-levels',
      'intensities',
      'emphases',
      'equipment',
      'execution-means',
    ];
    for (final name in names) {
      test('POS-08 getDictionary: $name has the values of the supplied data', () async {
        final res = await app.api.send(
          'getDictionary',
          path: {'dictionaryName': name},
        );
        expectStatus(res, 200);
        expect(res.body, catalog.dictionary(name));
      });
    }
  });
}
