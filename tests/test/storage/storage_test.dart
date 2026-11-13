/// T-12 (#13): local storage — recovery after a restart, a simulated write
/// failure, the moment of the success response.
///
/// Sources: AC-NF-002, AC-NF-003; REQ-NF-002, REQ-NF-003; BDD-015 (also T-23),
/// BDD-021 (also T-25); SRS §4.5; spec/openapi.yaml `info.description`
/// («успіх … лише після повного завершення запису»), saveNewTrainingPlan,
/// overwriteTrainingPlan, deleteTrainingPlan, completeTraining (500
/// STORAGE_WRITE_FAILED: «запис не завершено, діє попередній стан»),
/// getCurrentSession; docs/api/scenarios.md NEG-07.
///
/// Restart = a new composition on the same database file (stage 1,
/// decision 4). The write failure is simulated by the operating system: the
/// database file is read-only after a restart (support/test_app.dart).
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

void main() {
  late TestApp app;

  setUp(() async => app = await TestApp.start());

  group('T-12 recovery after a restart (AC-NF-002)', () {
    test('AC-NF-002 createExercise saveNewTrainingPlan completeTraining: after a '
        'confirmed save and a restart the custom exercise, the saved plan and '
        'the completed training are restored with the same values, order and '
        'note', () async {
      final exercise = await app.api.createExerciseOk(ropeExerciseInput());
      final open = await app.api.generateOk();
      final openId = open['id'].asString;
      await app.api.addItemOk(
        openId,
        exerciseId: exercise['id'].asString,
        variantId: exercise['variants'].asJsonList.single['id'].asString,
        stage: 'warm-up',
        position: 0,
        parameters: timeParams(2, 90, 45),
      );
      final plan = await app.api.saveNewOk(openId);
      await app.api.startOk(openId);
      final training = await app.api.completeOk(
        body: {'note': '[TEST] Примітка до перезапуску.'},
      );

      await app.restart();

      expect(await app.api.getExerciseOk(exercise['id'].asString), exercise);
      expect(await app.api.getTrainingPlanOk(plan['id'].asString), plan);
      expect(await app.api.completedTrainingOk(training['id'].asString), training);
      expect((await app.api.historyOk()).map((t) => t['id']), [training['id']]);
    });

    test('BDD-015 AC-F-011 AC-NF-002 updateExercise getTrainingPlan: a saved plan '
        'with a custom exercise keeps the previous name and saved parameters '
        'after the exercise is changed and the app restarted', () async {
      final exercise = await app.api.createExerciseOk(ropeExerciseInput());
      final exerciseId = exercise['id'].asString;
      final variant = exercise['variants'].asJsonList.single;
      final open = await app.api.generateOk();
      final openId = open['id'].asString;
      await app.api.addItemOk(
        openId,
        exerciseId: exerciseId,
        variantId: variant['id'].asString,
        stage: 'warm-up',
        parameters: timeParams(3, 120, 60),
      );
      final plan = await app.api.saveNewOk(openId);

      final changed = await app.api.send(
        'updateExercise',
        path: {'exerciseId': exerciseId},
        body: {
          ...ropeExerciseInput(),
          'name': '[TEST] Скакалка — нова назва',
          'variants': [
            {
              ...variant,
              'rounds': {'min': 1, 'max': 5, 'recommended': 5},
              'intervalSeconds': {'min': 60, 'max': 180, 'recommended': 180},
            },
          ],
        },
      );
      expectStatus(changed, 200);
      await app.restart();

      final after = await app.api.getTrainingPlanOk(plan['id'].asString);
      expect(after, plan);
      final item = allItems(after).firstWhere((i) => i['exerciseId'] == exerciseId);
      expect(item['exerciseName'], '[TEST] Стрибки на скакалці');
      expect(item['parameters'], timeParams(3, 120, 60));
      expect(item['variant'], variant);
    });

    test('AC-NF-003 saveNewTrainingPlan: success is reported only after the write '
        'is complete — a restart right after 201 finds the plan', () async {
      final plan = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      await app.restart();
      expect(await app.api.getTrainingPlanOk(plan['id'].asString), plan);
    });

    test('AC-NF-003 completeTraining: success is reported only after the write is '
        'complete — a restart right after 201 finds the record', () async {
      final openId = (await app.api.generateOk())['id'].asString;
      await app.api.startOk(openId);
      final training = await app.api.completeOk();
      await app.restart();
      expect(await app.api.completedTrainingOk(training['id'].asString), training);
    });
  });

  group('T-12 simulated write failure (AC-NF-003)', () {
    test('BDD-021 NEG-07 AC-NF-003 completeTraining getCurrentSession '
        'listCompletedTrainings: a storage error → 500 STORAGE_WRITE_FAILED, no '
        'partial record, the session stays current', () async {
      await app.restartWithReadOnlyStorage();
      final openId = (await app.api.generateOk())['id'].asString;
      final session = await app.api.startOk(openId);
      final res = await app.api.send(
        'completeTraining',
        body: {'note': '[TEST] Не має зберегтися.'},
      );
      expectError(res, 500, 'STORAGE_WRITE_FAILED');
      expect(res.location, isNull);
      expect(await app.api.currentSessionOk(), session);
      expect(await app.api.historyOk(), isEmpty);

      await app.restartWithWritableStorage();
      expect(await app.api.historyOk(), isEmpty);
    });

    test('AC-NF-003 saveNewTrainingPlan: a storage error → 500 '
        'STORAGE_WRITE_FAILED, no plan is saved and the open plan stays '
        'unsaved', () async {
      await app.restartWithReadOnlyStorage();
      final openId = (await app.api.generateOk())['id'].asString;
      final res = await app.api.send('saveNewTrainingPlan', body: {'openPlanId': openId});
      expectError(res, 500, 'STORAGE_WRITE_FAILED');
      expect(res.location, isNull);
      expect(await app.api.listTrainingPlansOk(), isEmpty);
      expect((await app.api.getOpenPlanOk(openId))['sourcePlanId'], isNull);

      await app.restartWithWritableStorage();
      expect(await app.api.listTrainingPlansOk(), isEmpty);
    });

    test('AC-NF-003 overwriteTrainingPlan: a storage error → 500 '
        'STORAGE_WRITE_FAILED, the previous saved plan stays in full', () async {
      final plan = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      final planId = plan['id'].asString;
      await app.restartWithReadOnlyStorage();
      final opened = await app.api.openSavedOk(planId);
      final openId = opened['id'].asString;
      for (final item in stageItems(opened, 'warm-up')) {
        await app.api.deleteItemOk(openId, item['id'].asString);
      }
      final res = await app.api.send(
        'overwriteTrainingPlan',
        path: {'planId': planId},
        body: {'openPlanId': openId},
      );
      expectError(res, 500, 'STORAGE_WRITE_FAILED');
      expect(await app.api.getTrainingPlanOk(planId), plan);

      await app.restartWithWritableStorage();
      expect(await app.api.getTrainingPlanOk(planId), plan);
    });

    test('AC-NF-003 deleteTrainingPlan: a storage error → 500 '
        'STORAGE_WRITE_FAILED, the plan is not deleted', () async {
      final plan = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      await app.restartWithReadOnlyStorage();
      final res = await app.api.send(
        'deleteTrainingPlan',
        path: {'planId': plan['id'].asString},
      );
      expectError(res, 500, 'STORAGE_WRITE_FAILED');
      expect(await app.api.getTrainingPlanOk(plan['id'].asString), plan);
    });
  });
}
