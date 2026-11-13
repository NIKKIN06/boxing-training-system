/// Reusable preconditions of the tests. Each step goes through the contract
/// (operationId of spec/openapi.yaml) and asserts the success status declared
/// for it, so a failed precondition fails the test with the actual status.
library;

import 'contract.dart';
import 'json.dart';

/// Generation parameters for the supplied [TEST] catalog: candidates exist
/// for all three stages (T-57, stage 5 of lab 5). D = 1 h 0 min.
Json generationParams({
  int hours = 1,
  int minutes = 0,
  String level = 'level-beginner',
  String emphasis = 'emphasis-technique',
  List<String> availableEquipment = const ['equipment-bag'],
  String intensity = 'intensity-medium',
}) => {
  'targetDuration': {'hours': hours, 'minutes': minutes},
  'level': level,
  'emphasis': emphasis,
  'availableEquipment': availableEquipment,
  'intensity': intensity,
};

/// Parameters of a time-mode item (SRS §5.3).
Json timeParams(int rounds, int intervalSeconds, int restSeconds) => {
  'rounds': rounds,
  'intervalSeconds': intervalSeconds,
  'restSeconds': restSeconds,
};

/// Parameters of a repetitions-mode item (SRS §5.3); `e` is not accepted (D-08).
Json repetitionParams(int sets, int repetitions, int restSeconds) => {
  'sets': sets,
  'repetitions': repetitions,
  'restSeconds': restSeconds,
};

/// Body of the contract example `ExerciseInputCustomWithoutVideo` (D-07).
Json ropeExerciseInput() => {
  'name': '[TEST] Стрибки на скакалці',
  'description': '[TEST] Опис стрибків на скакалці.',
  'type': 'simple',
  'allowedStages': ['warm-up'],
  'allowedLevels': ['level-beginner'],
  'allowedIntensities': ['intensity-high'],
  'emphases': ['emphasis-endurance'],
  'loadCharacter': 'general-physical',
  'variants': [
    {
      'executionMeans': 'means-apparatus',
      'equipment': ['equipment-rope'],
      'mode': 'time',
      'rounds': {'min': 1, 'max': 5, 'recommended': 3},
      'intervalSeconds': {'min': 60, 'max': 180, 'recommended': 120},
      'restSeconds': {'min': 30, 'max': 90, 'recommended': 60},
    },
  ],
};

/// A custom exercise in repetitions mode with two variants (BDD-052).
Json twoVariantExerciseInput() => {
  'name': '[TEST] Присідання',
  'description': '[TEST] Опис присідань.',
  'type': 'simple',
  'allowedStages': ['warm-up', 'main'],
  'allowedLevels': ['level-beginner'],
  'allowedIntensities': ['intensity-medium'],
  'emphases': ['emphasis-technique'],
  'loadCharacter': 'general-physical',
  'variants': [
    {
      'executionMeans': 'means-no-equipment',
      'equipment': <String>[],
      'mode': 'repetitions',
      'sets': {'min': 1, 'max': 5, 'recommended': 3},
      'repetitions': {'min': 5, 'max': 20, 'recommended': 10},
      'restSeconds': {'min': 0, 'max': 60, 'recommended': 30},
      'repetitionTimeSeconds': 3,
    },
    {
      'executionMeans': 'means-apparatus',
      'equipment': ['equipment-rope'],
      'mode': 'time',
      'rounds': {'min': 1, 'max': 5, 'recommended': 3},
      'intervalSeconds': {'min': 60, 'max': 180, 'recommended': 120},
      'restSeconds': {'min': 30, 'max': 90, 'recommended': 60},
    },
  ],
};

extension Flows on ApiClient {
  Future<Json> createExerciseOk(Json input) async {
    final res = await send('createExercise', body: input);
    expectStatus(res, 201);
    return res.body;
  }

  Future<Json> getExerciseOk(String id) async {
    final res = await send('getExercise', path: {'exerciseId': id});
    expectStatus(res, 200);
    return res.body;
  }

  Future<Json> generateOk([Json? params]) async {
    final res = await send('generatePlan', body: params ?? generationParams());
    expectStatus(res, 201);
    return res.body;
  }

  Future<Json> getOpenPlanOk(String openPlanId) async {
    final res = await send('getOpenPlan', path: {'openPlanId': openPlanId});
    expectStatus(res, 200);
    return res.body;
  }

  Future<Json> addItemOk(
    String openPlanId, {
    required String exerciseId,
    String variantId = 'var-1',
    required String stage,
    required Json parameters,
    int? position,
  }) async {
    final res = await send(
      'addOpenPlanItem',
      path: {'openPlanId': openPlanId},
      body: {
        'exerciseId': exerciseId,
        'variantId': variantId,
        'stage': stage,
        'position': ?position,
        'parameters': parameters,
      },
    );
    expectStatus(res, 201);
    return res.body;
  }

  Future<Json> patchItemOk(String openPlanId, String itemId, Json body) async {
    final res = await send(
      'updateOpenPlanItem',
      path: {'openPlanId': openPlanId, 'itemId': itemId},
      body: body,
    );
    expectStatus(res, 200);
    return res.body;
  }

  Future<Json> deleteItemOk(String openPlanId, String itemId) async {
    final res = await send(
      'deleteOpenPlanItem',
      path: {'openPlanId': openPlanId, 'itemId': itemId},
    );
    expectStatus(res, 200);
    return res.body;
  }

  Future<Json> renameOk(String openPlanId, String name) async {
    final res = await send(
      'renameOpenPlan',
      path: {'openPlanId': openPlanId},
      body: {'name': name},
    );
    expectStatus(res, 200);
    return res.body;
  }

  Future<Json> saveNewOk(String openPlanId) async {
    final res = await send(
      'saveNewTrainingPlan',
      body: {'openPlanId': openPlanId},
    );
    expectStatus(res, 201);
    return res.body;
  }

  Future<Json> overwriteOk(String planId, String openPlanId) async {
    final res = await send(
      'overwriteTrainingPlan',
      path: {'planId': planId},
      body: {'openPlanId': openPlanId},
    );
    expectStatus(res, 200);
    return res.body;
  }

  Future<Json> getTrainingPlanOk(String planId) async {
    final res = await send('getTrainingPlan', path: {'planId': planId});
    expectStatus(res, 200);
    return res.body;
  }

  Future<List<Json>> listTrainingPlansOk() async {
    final res = await send('listTrainingPlans');
    expectStatus(res, 200);
    return res.body['items'].asJsonList;
  }

  Future<Json> openSavedOk(String planId) async {
    final res = await send('openSavedPlan', body: {'sourcePlanId': planId});
    expectStatus(res, 201);
    return res.body;
  }

  Future<Json> startOk(String openPlanId) async {
    final res = await send(
      'startCurrentSession',
      body: {'openPlanId': openPlanId},
    );
    expectStatus(res, 201);
    return res.body;
  }

  Future<Json> currentSessionOk() async {
    final res = await send('getCurrentSession');
    expectStatus(res, 200);
    return res.body;
  }

  Future<Json> completeOk({Object? body = noBody}) async {
    final res = await send('completeTraining', body: body);
    expectStatus(res, 201);
    return res.body;
  }

  Future<List<Json>> historyOk() async {
    final res = await send('listCompletedTrainings');
    expectStatus(res, 200);
    return res.body['items'].asJsonList;
  }

  Future<Json> completedTrainingOk(String trainingId) async {
    final res = await send(
      'getCompletedTraining',
      path: {'trainingId': trainingId},
    );
    expectStatus(res, 200);
    return res.body;
  }

  Future<Json> analyticsOk({String? from, String? to}) async {
    final res = await send(
      'getAnalytics',
      query: {'from': ?from, 'to': ?to},
    );
    expectStatus(res, 200);
    return res.body;
  }
}
