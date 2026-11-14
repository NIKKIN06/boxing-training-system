/// T-26 (#27): history — order of records, fields of details, independence
/// from the catalog, empty state.
///
/// Sources: AC-F-014; REQ-F-014; BDD-016, BDD-017, BDD-020; D-06 (BDD-035 —
/// see catalog_version_test.dart), D-20; SRS §4.3.5, §4.5; spec/openapi.yaml
/// listCompletedTrainings, getCompletedTraining, completeTraining;
/// docs/api/scenarios.md POS-32, POS-33, POS-34.
/// Readiness of T-26: editing a custom exercise after a completed training
/// (BDD-017) and a new catalog version with a renamed or deprecated exercise
/// (BDD-035) do not change the details of the history.
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

void main() {
  late TestApp app;

  setUp(() async => app = await TestApp.start());

  Future<Json> completeAt(DateTime start, {Object? body = noBody}) async {
    app.clock.set(start);
    await app.api.startOk((await app.api.generateOk())['id'].asString);
    app.clock.advance(const Duration(hours: 1));
    return app.api.completeOk(body: body);
  }

  test('POS-33 BDD-020 AC-F-014 listCompletedTrainings: an empty history → '
      'items []', () async {
    final res = await app.api.send('listCompletedTrainings');
    expectStatus(res, 200);
    expect(res.body['items'], isEmpty);
  });

  test('POS-32 AC-F-014 listCompletedTrainings: records are ordered by start '
      'time from newer to older, not by the moment of completion', () async {
    final a = await completeAt(DateTime(2026, 6, 30, 18));
    final b = await completeAt(DateTime(2026, 7, 1, 9));
    final c = await completeAt(DateTime(2026, 6, 29, 7));
    final items = await app.api.historyOk();
    expect(items.map((t) => t['id']), [b['id'], a['id'], c['id']]);
    for (final item in items) {
      final record = [a, b, c].firstWhere((r) => r['id'] == item['id']);
      expect(item['startedAt'], record['startedAt']);
    }
  });

  test('POS-34 BDD-016 AC-F-014 getCompletedTraining: details have the start date '
      'and time, the local date, the exercises with execution parameters and '
      'the note', () async {
    final start = DateTime(2026, 6, 30, 18);
    final record = await completeAt(
      start,
      body: {'note': '[TEST] Зроблено додаткові підходи віджимань.'},
    );
    final details = await app.api.completedTrainingOk(record['id'].asString);
    expect(details, record);
    expect(DateTime.parse(details['startedAt'].asString).isAtSameMomentAs(start), isTrue);
    expect(details['localStartDate'], '2026-06-30');
    expect(details['note'], '[TEST] Зроблено додаткові підходи віджимань.');
    final executed = details['executedPlan'].asJson;
    expect(stagesOf(executed), stageOrder);
    for (final item in allItems(executed)) {
      expect(item['exerciseName'], isA<String>());
      expect(item['parameters'], isA<Map<String, Object?>>());
      expect(item['variant'], isA<Map<String, Object?>>());
    }
  });

  test('BDD-017 AC-F-014 updateExercise getCompletedTraining: changing the name '
      'and parameters of a custom exercise in the catalog does not change its '
      'copy in the history', () async {
    final exercise = await app.api.createExerciseOk(ropeExerciseInput());
    final exerciseId = exercise['id'].asString;
    final variant = exercise['variants'].asJsonList.single;
    final openId = (await app.api.generateOk())['id'].asString;
    await app.api.addItemOk(
      openId,
      exerciseId: exerciseId,
      variantId: variant['id'].asString,
      stage: 'warm-up',
      parameters: timeParams(3, 120, 60),
    );
    await app.api.startOk(openId);
    final record = await app.api.completeOk();

    final res = await app.api.send(
      'updateExercise',
      path: {'exerciseId': exerciseId},
      body: {
        ...ropeExerciseInput(),
        'name': '[TEST] Скакалка — нова назва',
        'variants': [
          {
            ...variant,
            'rounds': {'min': 2, 'max': 5, 'recommended': 4},
          },
        ],
      },
    );
    expectStatus(res, 200);

    final details = await app.api.completedTrainingOk(record['id'].asString);
    expect(details, record);
    final copy = allItems(
      details['executedPlan'].asJson,
    ).firstWhere((i) => i['exerciseId'] == exerciseId);
    expect(copy['exerciseName'], '[TEST] Стрибки на скакалці');
    expect(copy['variant'], variant);
    expect(copy['parameters'], timeParams(3, 120, 60));
  });

  test('AC-F-014 getCompletedTraining: unknown record → 404 NOT_FOUND', () async {
    final res = await app.api.send(
      'getCompletedTraining',
      path: {'trainingId': 'training-404'},
    );
    expectError(res, 404, 'NOT_FOUND');
  });

  test('D-20 AC-F-014 getCompletedTraining: records are read-only — the contract '
      'has no operation to change or delete a completed training', () {
    final ops = app.api.contract.operations.values.where(
      (op) => op.pathTemplate.startsWith('/completed-trainings'),
    );
    expect(
      ops.map((op) => '${op.method} ${op.pathTemplate}').toSet(),
      {
        'POST /completed-trainings',
        'GET /completed-trainings',
        'GET /completed-trainings/{trainingId}',
      },
    );
  });
}
