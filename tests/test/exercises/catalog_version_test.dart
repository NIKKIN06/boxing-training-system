/// BDD-035 (D-06): update to a new catalog version with a deprecated exercise.
///
/// Tickets: T-13 (#14), T-14 (#15), T-19 (#20), T-22 (#23), T-23 (#24),
/// T-26 (#27) — each of them lists ADD-001 D-06 (BDD-035).
/// Sources: AC-F-001 pp. 5–6, AC-F-003, AC-F-006, AC-F-010, AC-F-011,
/// AC-F-014; SRS §4.3.1, §4.4, §4.5; spec/openapi.yaml listExercises,
/// getExercise, generatePlan, addOpenPlanItem, getTrainingPlan,
/// openSavedPlan, getCompletedTraining.
///
/// The catalog update is a restart with the next catalog version
/// (fixtures/catalogs/catalog-v2-ex1-deprecated.json: ex-1 deprecated, ex-2
/// renamed) on the same database — the catalog is updated only together with
/// the application (SRS §4.4).
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/seeded_random.dart';
import '../support/test_app.dart';

void main() {
  final v2 = fixtureCatalog('catalog-v2-ex1-deprecated.json');
  final v2Data = CatalogData.load(v2);
  late TestApp app;
  late Json custom;
  late Json savedPlan;
  late Json training;

  /// Given: a custom exercise, a saved plan with E1 = ex-1 and a completed
  /// training with ex-1, all created with catalog version test-1.
  setUp(() async {
    app = await TestApp.start();
    custom = await app.api.createExerciseOk(ropeExerciseInput());
    final open = await app.api.generateOk();
    final openId = open['id'].asString;
    await app.api.addItemOk(
      openId,
      exerciseId: 'ex-1',
      stage: 'warm-up',
      parameters: timeParams(3, 180, 60),
    );
    final saved = await app.api.saveNewOk(openId);
    savedPlan = await app.api.getTrainingPlanOk(saved['id'].asString);
    await app.api.startOk(openId);
    final completed = await app.api.completeOk();
    training = await app.api.completedTrainingOk(completed['id'].asString);
    await app.restart(catalog: v2);
  });

  test('BDD-035 D-06 AC-F-001 getExercise: the custom exercise is not changed '
      'by the new catalog version', () async {
    expect(await app.api.getExerciseOk(custom['id'].asString), custom);
  });

  test('BDD-035 D-06 AC-F-001 AC-F-003 listExercises: E1 is not shown in the '
      'catalog; renamed ex-2 is shown with the new name', () async {
    final res = await app.api.send('listExercises');
    expectStatus(res, 200);
    final items = res.body['items'].asJsonList;
    expect(items.map((e) => e['id']), isNot(contains('ex-1')));
    expect(items.map((e) => e['id']), contains(custom['id']));
    expect(
      items.firstWhere((e) => e['id'] == 'ex-2')['name'],
      v2Data.exercise('ex-2')['name'],
    );
  });

  test('BDD-035 D-06 AC-F-001 getExercise: E1 is not deleted — its card opens '
      'from the plan with deprecated true', () async {
    final card = await app.api.getExerciseOk('ex-1');
    expect(card['deprecated'], isTrue);
  });

  test('BDD-035 D-06 AC-F-006 generatePlan: the generator does not propose E1', () async {
    for (final seed in fixedSeeds) {
      await app.restart(seed: seed);
      final plan = await app.api.generateOk();
      expect(
        allItems(plan).map((i) => i['exerciseId']),
        isNot(contains('ex-1')),
        reason: 'seed $seed',
      );
    }
  });

  test('BDD-035 D-06 NEG-16 AC-F-010 addOpenPlanItem: E1 cannot be added to a '
      'plan manually → 422 EXERCISE_DEPRECATED', () async {
    final open = await app.api.generateOk();
    final res = await app.api.send(
      'addOpenPlanItem',
      path: {'openPlanId': open['id'].asString},
      body: {
        'exerciseId': 'ex-1',
        'variantId': 'var-1',
        'stage': 'warm-up',
        'parameters': timeParams(3, 180, 60),
      },
    );
    expectError(res, 422, 'EXERCISE_DEPRECATED');
  });

  test('BDD-035 D-06 AC-F-011 getTrainingPlan openSavedPlan: the saved plan '
      'still contains E1 and copies made before the update', () async {
    final planId = savedPlan['id'].asString;
    final after = await app.api.getTrainingPlanOk(planId);
    expect(after, savedPlan);
    expect(allItems(after).map((i) => i['exerciseId']), contains('ex-1'));
    final reopened = await app.api.openSavedOk(planId);
    expect(reopened['stages'], savedPlan['stages']);
  });

  test('BDD-035 D-06 AC-F-014 getCompletedTraining: history contains E1 and '
      'the details are not changed by the new version', () async {
    final after = await app.api.completedTrainingOk(training['id'].asString);
    expect(after, training);
    expect(
      allItems(after['executedPlan'].asJson).map((i) => i['exerciseId']),
      contains('ex-1'),
    );
  });
}
