/// T-13 (#14): initialization of the initial catalog.
///
/// Sources: AC-F-001 pp. 1–3, AC-F-004 p. 1, AC-NF-001; BDD-001; SRS §4.3.1,
/// §4.4 (D-01, D-05, D-06); spec/openapi.yaml listExercises, getExercise;
/// docs/api/scenarios.md POS-04, POS-06. Expected exercises come from the
/// supplied [TEST] catalog data (T-57), not from the code. The new catalog
/// version (D-06, BDD-035) is covered in catalog_version_test.dart.
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

void main() {
  final catalog = CatalogData.load(baseCatalog);
  final activeIds = catalog.activeExercises.map((e) => e['id']).toSet();
  late TestApp app;

  setUp(() async => app = await TestApp.start());

  Future<List<Json>> listAll() async {
    final res = await app.api.send('listExercises');
    expectStatus(res, 200);
    return res.body['items'].asJsonList;
  }

  group('T-13 listExercises: initial catalog after the first start', () {
    test('BDD-001 AC-F-001 AC-NF-001 listExercises: after the first start all '
        'non-deprecated initial exercises are available without network', () async {
      final items = await listAll();
      expect(items.map((e) => e['id']).toSet(), activeIds);
      for (final item in items) {
        final source = catalog.exercise(item['id'].asString);
        expect(item['name'], source['name']);
        expect(item['type'], source['type']);
        expect(item['origin'], 'initial');
      }
    });

    test('BDD-001 AC-F-001 D-06 listExercises: deprecated initial exercise ex-9 '
        'is not shown in the catalog', () async {
      final items = await listAll();
      expect(items.map((e) => e['id']), isNot(contains('ex-9')));
    });

    test('BDD-001 AC-F-001 listExercises: a repeated start adds no duplicates', () async {
      final first = await listAll();
      await app.restart();
      await app.restart();
      final again = await listAll();
      final ids = again.map((e) => e['id']).toList();
      expect(ids.toSet(), hasLength(ids.length), reason: 'ids must be unique');
      expect(again, hasLength(first.length));
      expect(ids.toSet(), first.map((e) => e['id']).toSet());
    });

    test('D-05 AC-F-001 createExercise updateExercise getExercise: a repeated '
        'start keeps custom exercises and their changes', () async {
      final created = await app.api.createExerciseOk(ropeExerciseInput());
      final id = created['id'].asString;
      final res = await app.api.send(
        'updateExercise',
        path: {'exerciseId': id},
        body: {
          ...(Map.of(created)
            ..remove('id')
            ..remove('origin')
            ..remove('deprecated')),
          'description': '[TEST] Змінено до перезапуску.',
        },
      );
      expectStatus(res, 200);
      await app.restart();
      expect(await app.api.getExerciseOk(id), res.body);
      expect((await listAll()).map((e) => e['id']), contains(id));
    });
  });

  group('T-13 getExercise: cards of initial exercises', () {
    test('POS-04 AC-F-004 D-01 getExercise: every initial exercise card equals '
        'the supplied data and has a [TEST] name and example.com HTTPS links', () async {
      for (final source in catalog.exercises) {
        final id = source['id'].asString;
        final card = await app.api.getExerciseOk(id);
        expect(card, source, reason: id);
        expect(card['name'].asString, startsWith('[TEST]'), reason: id);
        for (final link in ['videoUrl', 'authorPageUrl']) {
          final uri = Uri.parse(card[link].asString);
          expect(uri.scheme, 'https', reason: '$id $link');
          expect(uri.host, 'example.com', reason: '$id $link');
        }
        expect(card['videoAuthorName'], isNotNull, reason: id);
      }
    });

    test('POS-06 D-06 getExercise: the card of deprecated ex-9 is available '
        'with deprecated true', () async {
      final card = await app.api.getExerciseOk('ex-9');
      expect(card['deprecated'], isTrue);
      expect(card['origin'], 'initial');
    });
  });
}
