/// T-22 (#23): manual editing of a plan — add, replace, delete, order,
/// parameters, moving between stages, warnings.
///
/// Sources: AC-F-010; REQ-F-010; BDD-013, BDD-014, BDD-023, BDD-032, BDD-033,
/// BDD-041 (D-15); D-06 (BDD-035 — see catalog_version_test.dart), D-08, D-14,
/// D-33; spec/openapi.yaml addOpenPlanItem, replaceOpenPlanItem,
/// updateOpenPlanItem, deleteOpenPlanItem, getOpenPlan; docs/api/scenarios.md
/// POS-14…POS-18, NEG-14…NEG-18.
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

/// Items of the plan except [itemId], comparable as a whole.
List<Json> othersThan(Json plan, String itemId) =>
    allItems(plan).where((i) => i['id'] != itemId).toList();

/// Warnings of one item.
List<Json> warningsOf(Json plan, String itemId) =>
    plan['warnings'].asJsonList.where((w) => w['itemId'] == itemId).toList();

/// Asserts positions 0..n-1 in array order in every stage.
void expectContiguousPositions(Json plan) {
  for (final stage in stageOrder) {
    final items = stageItems(plan, stage);
    expect(
      items.map((i) => i['position']),
      List.generate(items.length, (i) => i),
      reason: '$stage positions',
    );
    expect(items.map((i) => i['stage']), everyElement(stage));
  }
}

void main() {
  late TestApp app;
  late Json open;
  late String openId;

  setUp(() async {
    app = await TestApp.start();
    open = await app.api.generateOk();
    openId = open['id'].asString;
  });

  /// Adds ex-1/var-1 (rounds max 5) to the warm-up and returns the new item.
  Future<(Json, Json)> addShadow() async {
    final plan = await app.api.addItemOk(
      openId,
      exerciseId: 'ex-1',
      stage: 'warm-up',
      parameters: timeParams(3, 180, 60),
    );
    return (plan, stageItems(plan, 'warm-up').last);
  }

  /// Adds ex-3/var-1 (repetitions, e = 3) to the main part.
  Future<(Json, Json)> addPushUps() async {
    final plan = await app.api.addItemOk(
      openId,
      exerciseId: 'ex-3',
      stage: 'main',
      parameters: repetitionParams(3, 10, 30),
    );
    return (plan, stageItems(plan, 'main').last);
  }

  group('T-22 updateOpenPlanItem: execution parameters', () {
    test('BDD-013 AC-F-010 updateOpenPlanItem getOpenPlan: rounds of one element '
        'changed within the limits — total recalculated, other elements '
        'unchanged', () async {
      final (before, item) = await addShadow();
      final itemId = item['id'].asString;
      final res = await app.api.send(
        'updateOpenPlanItem',
        path: {'openPlanId': openId, 'itemId': itemId},
        body: {
          'parameters': {'rounds': 4},
        },
      );
      expectStatus(res, 200);
      final after = res.body;
      final changed = itemById(after, itemId);
      expect(changed['parameters'], timeParams(4, 180, 60));
      expect(changed['estimatedDurationSeconds'], 4 * 180 + 3 * 60);
      expect(
        after['estimatedDurationSeconds'],
        before['estimatedDurationSeconds'].asInt - 660 + 900,
      );
      expect(othersThan(after, itemId), othersThan(before, itemId));
      expect(await app.api.getOpenPlanOk(openId), after);
    });

    test('BDD-032 NEG-17 AC-F-010 updateOpenPlanItem: 6 rounds for a variant with '
        'at most 5 → 422 VALIDATION_FAILED WITHIN_VARIANT_RANGE, plan unchanged', () async {
      final (before, item) = await addShadow();
      final res = await app.api.send(
        'updateOpenPlanItem',
        path: {'openPlanId': openId, 'itemId': item['id'].asString},
        body: {
          'parameters': {'rounds': 6},
        },
      );
      expectError(res, 422, 'VALIDATION_FAILED');
      expectDetail(res, 'parameters.rounds', constraint: 'WITHIN_VARIANT_RANGE');
      expect(await app.api.getOpenPlanOk(openId), before);
    });

    test('NEG-18 D-08 AC-F-010 updateOpenPlanItem: repetitionTimeSeconds → 422 '
        'VALIDATION_FAILED NOT_EDITABLE, e unchanged', () async {
      final (before, item) = await addPushUps();
      final res = await app.api.send(
        'updateOpenPlanItem',
        path: {'openPlanId': openId, 'itemId': item['id'].asString},
        body: {
          'parameters': {'repetitionTimeSeconds': 5},
        },
      );
      expectError(res, 422, 'VALIDATION_FAILED');
      expectDetail(res, 'parameters.repetitionTimeSeconds', constraint: 'NOT_EDITABLE');
      expect(await app.api.getOpenPlanOk(openId), before);
    });

    final invalid = <({String name, Json body, String? field})>[
      (
        name: 'zero rounds',
        body: {
          'parameters': {'rounds': 0},
        },
        field: 'parameters.rounds',
      ),
      (
        name: 'negative rest',
        body: {
          'parameters': {'restSeconds': -1},
        },
        field: 'parameters.restSeconds',
      ),
      (
        name: 'non-integer interval',
        body: {
          'parameters': {'intervalSeconds': 120.5},
        },
        field: 'parameters.intervalSeconds',
      ),
      (
        name: 'field of the other mode (sets for a time variant)',
        body: {
          'parameters': {'sets': 2},
        },
        field: 'parameters.sets',
      ),
      (name: 'position outside the stage', body: {'position': 99}, field: 'position'),
      (name: 'empty body', body: <String, Object?>{}, field: null),
    ];
    for (final c in invalid) {
      test('AC-F-010 updateOpenPlanItem: ${c.name} → 422 VALIDATION_FAILED, plan '
          'unchanged', () async {
        final (before, item) = await addShadow();
        final res = await app.api.send(
          'updateOpenPlanItem',
          path: {'openPlanId': openId, 'itemId': item['id'].asString},
          body: c.body,
        );
        expectError(res, 422, 'VALIDATION_FAILED');
        if (c.field != null) expectDetail(res, c.field!);
        expect(await app.api.getOpenPlanOk(openId), before);
      });
    }

    test('AC-F-010 updateOpenPlanItem: unknown element → 404 NOT_FOUND', () async {
      final res = await app.api.send(
        'updateOpenPlanItem',
        path: {'openPlanId': openId, 'itemId': 'item-404'},
        body: {
          'parameters': {'rounds': 2},
        },
      );
      expectError(res, 404, 'NOT_FOUND');
    });

    test('D-14 AC-F-010 updateOpenPlanItem: generation parameters stay in the '
        'open plan after edits', () async {
      final (_, item) = await addShadow();
      final after = await app.api.patchItemOk(openId, item['id'].asString, {
        'parameters': {'rounds': 2},
      });
      expect(after['generationParameters'], open['generationParameters']);
      expect(after['targetDurationSeconds'], open['targetDurationSeconds']);
    });
  });

  group('T-22 updateOpenPlanItem: order and moving between stages', () {
    test('BDD-023 AC-F-010 updateOpenPlanItem getExercise saveNewTrainingPlan: '
        'ex-2 (main only) moved to the warm-up is allowed, its catalog '
        'classification is unchanged and the plan can be saved', () async {
      final added = await app.api.addItemOk(
        openId,
        exerciseId: 'ex-2',
        stage: 'main',
        parameters: timeParams(2, 180, 60),
      );
      final itemId = stageItems(added, 'main').last['id'].asString;
      final moved = await app.api.patchItemOk(openId, itemId, {'stage': 'warm-up', 'position': 0});
      final item = itemById(moved, itemId);
      expect(item['stage'], 'warm-up');
      expect(stageItems(moved, 'warm-up').first['id'], itemId);
      expect(stagesOf(moved), stageOrder);
      expectContiguousPositions(moved);
      expect((await app.api.getExerciseOk('ex-2'))['allowedStages'], ['main']);
      final saved = await app.api.saveNewOk(openId);
      expect(stageItems(saved, 'warm-up').first['exerciseId'], 'ex-2');
    });

    test('AC-F-010 updateOpenPlanItem: order within a stage is changed, '
        'positions stay contiguous, stage order is fixed', () async {
      await addShadow();
      final (plan, last) = await addShadow();
      final lastId = last['id'].asString;
      final idsBefore = stageItems(plan, 'warm-up').map((i) => i['id']).toList();
      final moved = await app.api.patchItemOk(openId, lastId, {'position': 0});
      final idsAfter = stageItems(moved, 'warm-up').map((i) => i['id']).toList();
      expect(idsAfter, [lastId, ...idsBefore.where((id) => id != lastId)]);
      expectContiguousPositions(moved);
      expect(stagesOf(moved), stageOrder);
      expect(moved['estimatedDurationSeconds'], plan['estimatedDurationSeconds']);
    });
  });

  group('T-22 addOpenPlanItem', () {
    test('POS-14 BDD-013 AC-F-010 addOpenPlanItem: ex-1 added to the cool-down '
        'outside its stages — appended at the end, total recalculated, Location '
        'of the new element', () async {
      final coolBefore = stageItems(open, 'cool-down');
      final res = await app.api.send(
        'addOpenPlanItem',
        path: {'openPlanId': openId},
        body: {
          'exerciseId': 'ex-1',
          'variantId': 'var-1',
          'stage': 'cool-down',
          'parameters': timeParams(1, 120, 30),
        },
      );
      expectStatus(res, 201);
      final plan = res.body;
      final cool = stageItems(plan, 'cool-down');
      expect(cool, hasLength(coolBefore.length + 1));
      final item = cool.last;
      expect(item['exerciseId'], 'ex-1');
      expect(item['exerciseName'], '[TEST] Бій з тінню');
      expect(item['variant'].asJson['id'], 'var-1');
      expect(item['position'], coolBefore.length);
      expect(item['estimatedDurationSeconds'], 120);
      expect(
        plan['estimatedDurationSeconds'],
        open['estimatedDurationSeconds'].asInt + 120,
      );
      expect(othersThan(plan, item['id'].asString), allItems(open));
      expect(
        Uri.parse(res.location!).path,
        '/open-plans/$openId/items/${item['id']}',
      );
    });

    test('AC-F-010 addOpenPlanItem: position 0 inserts at the beginning of the '
        'stage, positions stay contiguous', () async {
      final plan = await app.api.addItemOk(
        openId,
        exerciseId: 'ex-1',
        stage: 'main',
        position: 0,
        parameters: timeParams(2, 120, 30),
      );
      expect(stageItems(plan, 'main').first['exerciseId'], 'ex-1');
      expectContiguousPositions(plan);
    });

    test('BDD-041 D-15 AC-F-010 addOpenPlanItem: the same variant V of E1 added '
        'again is allowed and the plan contains V twice', () async {
      final first = stageItems(open, 'warm-up').first;
      final exerciseId = first['exerciseId'].asString;
      final variantId = first['variant'].asJson['id'].asString;
      final p = first['parameters'].asJson;
      final plan = await app.api.addItemOk(
        openId,
        exerciseId: exerciseId,
        variantId: variantId,
        stage: 'warm-up',
        parameters: Map.of(p)..remove('repetitionTimeSeconds'),
      );
      expect(
        allItems(plan).where(
          (i) => i['exerciseId'] == exerciseId && i['variant'].asJson['id'] == variantId,
        ),
        hasLength(2),
      );
    });

    test('AC-F-010 addOpenPlanItem: an exercise that does not match the source '
        'filters gets FILTER_MISMATCH warnings', () async {
      final rope = await app.api.createExerciseOk(ropeExerciseInput());
      final plan = await app.api.addItemOk(
        openId,
        exerciseId: rope['id'].asString,
        variantId: rope['variants'].asJsonList.single['id'].asString,
        stage: 'main',
        parameters: timeParams(1, 120, 60),
      );
      final itemId = stageItems(plan, 'main').last['id'].asString;
      final attributes = warningsOf(
        plan,
        itemId,
      ).where((w) => w['code'] == 'FILTER_MISMATCH').map((w) => w['attribute']).toSet();
      expect(attributes, {'intensity', 'availableEquipment', 'emphasis'});
    });

    final rejected = <({String name, Json body, int status, String code, String? field})>[
      (
        name: 'NEG-14 unknown exercise',
        body: {
          'exerciseId': 'ex-404',
          'variantId': 'var-1',
          'stage': 'main',
          'parameters': timeParams(3, 180, 60),
        },
        status: 422,
        code: 'EXERCISE_NOT_FOUND',
        field: null,
      ),
      (
        name: 'NEG-15 D-33 variant not of the exercise',
        body: {
          'exerciseId': 'ex-1',
          'variantId': 'var-404',
          'stage': 'main',
          'parameters': timeParams(3, 180, 60),
        },
        status: 422,
        code: 'VARIANT_NOT_FOUND',
        field: null,
      ),
      (
        name: 'NEG-16 D-06 deprecated exercise ex-9',
        body: {
          'exerciseId': 'ex-9',
          'variantId': 'var-1',
          'stage': 'main',
          'parameters': timeParams(3, 180, 60),
        },
        status: 422,
        code: 'EXERCISE_DEPRECATED',
        field: null,
      ),
      (
        name: 'NEG-17 BDD-032 6 rounds above the variant maximum 5',
        body: {
          'exerciseId': 'ex-1',
          'variantId': 'var-1',
          'stage': 'warm-up',
          'parameters': timeParams(6, 180, 60),
        },
        status: 422,
        code: 'VALIDATION_FAILED',
        field: 'parameters.rounds',
      ),
      (
        name: 'D-08 repetitionTimeSeconds is not accepted',
        body: {
          'exerciseId': 'ex-3',
          'variantId': 'var-1',
          'stage': 'main',
          'parameters': {...repetitionParams(3, 10, 30), 'repetitionTimeSeconds': 5},
        },
        status: 422,
        code: 'VALIDATION_FAILED',
        field: 'parameters.repetitionTimeSeconds',
      ),
      (
        name: 'position outside the stage',
        body: {
          'exerciseId': 'ex-1',
          'variantId': 'var-1',
          'stage': 'warm-up',
          'position': 99,
          'parameters': timeParams(3, 180, 60),
        },
        status: 422,
        code: 'VALIDATION_FAILED',
        field: 'position',
      ),
    ];
    for (final c in rejected) {
      test('${c.name.startsWith('NEG') ? '' : 'AC-F-010 '}${c.name}: addOpenPlanItem → '
          '${c.status} ${c.code}, plan unchanged', () async {
        final res = await app.api.send(
          'addOpenPlanItem',
          path: {'openPlanId': openId},
          body: c.body,
        );
        expectError(res, c.status, c.code);
        if (c.code == 'VALIDATION_FAILED' && c.name.contains('NEG-17')) {
          expectDetail(res, c.field!, constraint: 'WITHIN_VARIANT_RANGE');
        } else if (c.name.startsWith('D-08')) {
          expectDetail(res, c.field!, constraint: 'NOT_EDITABLE');
        } else if (c.field != null) {
          expectDetail(res, c.field!);
        }
        expect(await app.api.getOpenPlanOk(openId), open);
      });
    }

    test('AC-F-010 addOpenPlanItem: unknown open plan → 404 NOT_FOUND', () async {
      final res = await app.api.send(
        'addOpenPlanItem',
        path: {'openPlanId': 'open-404'},
        body: {
          'exerciseId': 'ex-1',
          'variantId': 'var-1',
          'stage': 'warm-up',
          'parameters': timeParams(3, 180, 60),
        },
      );
      expectError(res, 404, 'NOT_FOUND');
    });
  });

  group('T-22 replaceOpenPlanItem', () {
    test('POS-15 AC-F-010 replaceOpenPlanItem: a main element replaced by the '
        'custom rope exercise keeps id, stage and position; FILTER_MISMATCH for '
        'intensity, availableEquipment and emphasis', () async {
      final rope = await app.api.createExerciseOk(ropeExerciseInput());
      final target = stageItems(open, 'main').first;
      final itemId = target['id'].asString;
      final res = await app.api.send(
        'replaceOpenPlanItem',
        path: {'openPlanId': openId, 'itemId': itemId},
        body: {
          'exerciseId': rope['id'],
          'variantId': rope['variants'].asJsonList.single['id'],
          'parameters': timeParams(1, 120, 60),
        },
      );
      expectStatus(res, 200);
      final plan = res.body;
      final item = itemById(plan, itemId);
      expect(item['exerciseId'], rope['id']);
      expect(item['exerciseName'], rope['name']);
      expect(item['stage'], 'main');
      expect(item['position'], target['position']);
      expect(item['parameters'], timeParams(1, 120, 60));
      expect(item['estimatedDurationSeconds'], 120);
      expect(
        plan['estimatedDurationSeconds'],
        open['estimatedDurationSeconds'].asInt - target['estimatedDurationSeconds'].asInt + 120,
      );
      final attributes = warningsOf(
        plan,
        itemId,
      ).where((w) => w['code'] == 'FILTER_MISMATCH').map((w) => w['attribute']).toSet();
      expect(attributes, {'intensity', 'availableEquipment', 'emphasis'});
      expect(othersThan(plan, itemId), othersThan(open, itemId));
    });

    test('AC-F-010 replaceOpenPlanItem: ex-7 (advanced, high, endurance, no '
        'equipment) gives FILTER_MISMATCH for level, intensity and emphasis only', () async {
      final target = stageItems(open, 'main').first;
      final itemId = target['id'].asString;
      final res = await app.api.send(
        'replaceOpenPlanItem',
        path: {'openPlanId': openId, 'itemId': itemId},
        body: {
          'exerciseId': 'ex-7',
          'variantId': 'var-1',
          'parameters': timeParams(3, 180, 60),
        },
      );
      expectStatus(res, 200);
      final attributes = warningsOf(
        res.body,
        itemId,
      ).where((w) => w['code'] == 'FILTER_MISMATCH').map((w) => w['attribute']).toSet();
      expect(attributes, {'level', 'intensity', 'emphasis'});
    });

    final rejected = <({String name, String itemId, Json body, int status, String code})>[
      (
        name: 'NEG-16 D-06 deprecated exercise ex-9',
        itemId: '',
        body: {'exerciseId': 'ex-9', 'variantId': 'var-1', 'parameters': timeParams(3, 180, 60)},
        status: 422,
        code: 'EXERCISE_DEPRECATED',
      ),
      (
        name: 'NEG-14 unknown exercise',
        itemId: '',
        body: {'exerciseId': 'ex-404', 'variantId': 'var-1', 'parameters': timeParams(3, 180, 60)},
        status: 422,
        code: 'EXERCISE_NOT_FOUND',
      ),
      (
        name: 'NEG-17 BDD-032 parameters outside the variant range',
        itemId: '',
        body: {'exerciseId': 'ex-1', 'variantId': 'var-1', 'parameters': timeParams(6, 180, 60)},
        status: 422,
        code: 'VALIDATION_FAILED',
      ),
      (
        name: 'NEG-18 D-08 repetitionTimeSeconds is not accepted',
        itemId: '',
        body: {
          'exerciseId': 'ex-3',
          'variantId': 'var-1',
          'parameters': {...repetitionParams(3, 10, 30), 'repetitionTimeSeconds': 5},
        },
        status: 422,
        code: 'VALIDATION_FAILED',
      ),
      (
        name: 'AC-F-010 unknown element',
        itemId: 'item-404',
        body: {'exerciseId': 'ex-1', 'variantId': 'var-1', 'parameters': timeParams(3, 180, 60)},
        status: 404,
        code: 'NOT_FOUND',
      ),
    ];
    for (final c in rejected) {
      test('${c.name}: replaceOpenPlanItem → ${c.status} ${c.code}, plan unchanged', () async {
        final itemId = c.itemId.isEmpty ? stageItems(open, 'main').first['id'].asString : c.itemId;
        final res = await app.api.send(
          'replaceOpenPlanItem',
          path: {'openPlanId': openId, 'itemId': itemId},
          body: c.body,
        );
        expectError(res, c.status, c.code);
        expect(await app.api.getOpenPlanOk(openId), open);
      });
    }
  });

  group('T-22 parameters exactly at the variant limits are accepted (TG-002; '
      'AC-F-010 «[мін., макс.]» inclusive, BDD-032)', () {
    // Variant limits of the supplied [TEST] catalog (T-57):
    // ex-1/var-1 (time): rounds 1–5, interval 60–300 s, rest 30–120 s;
    // ex-3/var-1 (repetitions, e = 3 s): sets 1–5, repetitions 5–20, rest 0–60 s.
    // Expected durations — SRS §5.4: T = n × t + (n − 1) × r, T = n × p × e + (n − 1) × r.
    final bounds = <({String name, String exerciseId, Json parameters, int seconds})>[
      (
        name: 'ex-1/var-1 every parameter = min (1 round, 60 s, rest 30 s)',
        exerciseId: 'ex-1',
        parameters: timeParams(1, 60, 30),
        seconds: 60,
      ),
      (
        name: 'ex-1/var-1 every parameter = max (5 rounds, 300 s, rest 120 s)',
        exerciseId: 'ex-1',
        parameters: timeParams(5, 300, 120),
        seconds: 5 * 300 + 4 * 120,
      ),
      (
        name: 'ex-3/var-1 every parameter = min (1 set, 5 repetitions, rest 0 s)',
        exerciseId: 'ex-3',
        parameters: repetitionParams(1, 5, 0),
        seconds: 1 * 5 * 3,
      ),
      (
        name: 'ex-3/var-1 every parameter = max (5 sets, 20 repetitions, rest 60 s)',
        exerciseId: 'ex-3',
        parameters: repetitionParams(5, 20, 60),
        seconds: 5 * 20 * 3 + 4 * 60,
      ),
    ];

    for (final b in bounds) {
      test('BDD-032 AC-F-010 addOpenPlanItem: ${b.name} → 201, parameters saved, '
          'duration ${b.seconds} s', () async {
        final res = await app.api.send(
          'addOpenPlanItem',
          path: {'openPlanId': openId},
          body: {
            'exerciseId': b.exerciseId,
            'variantId': 'var-1',
            'stage': 'main',
            'parameters': b.parameters,
          },
        );
        expectStatus(res, 201);
        final item = stageItems(res.body, 'main').last;
        expect(item['exerciseId'], b.exerciseId);
        expect(Map.of(item['parameters'].asJson)..remove('repetitionTimeSeconds'), b.parameters);
        expect(item['estimatedDurationSeconds'], b.seconds);
        expect(
          res.body['estimatedDurationSeconds'],
          open['estimatedDurationSeconds'].asInt + b.seconds,
        );
      });
    }

    for (final b in bounds) {
      test('BDD-032 AC-F-010 replaceOpenPlanItem: ${b.name} → 200, parameters '
          'saved, duration ${b.seconds} s', () async {
        final target = stageItems(open, 'main').first;
        final itemId = target['id'].asString;
        final res = await app.api.send(
          'replaceOpenPlanItem',
          path: {'openPlanId': openId, 'itemId': itemId},
          body: {'exerciseId': b.exerciseId, 'variantId': 'var-1', 'parameters': b.parameters},
        );
        expectStatus(res, 200);
        final item = itemById(res.body, itemId);
        expect(item['exerciseId'], b.exerciseId);
        expect(Map.of(item['parameters'].asJson)..remove('repetitionTimeSeconds'), b.parameters);
        expect(item['estimatedDurationSeconds'], b.seconds);
        expect(
          res.body['estimatedDurationSeconds'],
          open['estimatedDurationSeconds'].asInt -
              target['estimatedDurationSeconds'].asInt +
              b.seconds,
        );
      });
    }

    for (final b in bounds) {
      test('BDD-032 AC-F-010 updateOpenPlanItem getOpenPlan: ${b.name} → 200, '
          'parameters saved, duration ${b.seconds} s', () async {
        final (_, item) = b.exerciseId == 'ex-1' ? await addShadow() : await addPushUps();
        final itemId = item['id'].asString;
        final after = await app.api.patchItemOk(openId, itemId, {'parameters': b.parameters});
        final changed = itemById(after, itemId);
        expect(Map.of(changed['parameters'].asJson)..remove('repetitionTimeSeconds'), b.parameters);
        expect(changed['estimatedDurationSeconds'], b.seconds);
        expect(await app.api.getOpenPlanOk(openId), after);
      });
    }

    test('BDD-032 AC-F-010 updateOpenPlanItem: exactly 5 rounds (the variant '
        'maximum) for ex-1/var-1 → 200, other parameters unchanged', () async {
      final (_, item) = await addShadow();
      final itemId = item['id'].asString;
      final after = await app.api.patchItemOk(openId, itemId, {
        'parameters': {'rounds': 5},
      });
      expect(itemById(after, itemId)['parameters'], timeParams(5, 180, 60));
      expect(itemById(after, itemId)['estimatedDurationSeconds'], 5 * 180 + 4 * 60);
    });

    test('BDD-032 AC-F-010 updateOpenPlanItem: exactly 1 round (the variant '
        'minimum) for ex-1/var-1 → 200, other parameters unchanged', () async {
      final (_, item) = await addShadow();
      final itemId = item['id'].asString;
      final after = await app.api.patchItemOk(openId, itemId, {
        'parameters': {'rounds': 1},
      });
      expect(itemById(after, itemId)['parameters'], timeParams(1, 180, 60));
      expect(itemById(after, itemId)['estimatedDurationSeconds'], 180);
    });
  });

  group('T-22 positions on the bounds of a stage are accepted (TG-002; '
      'AC-F-010, spec/openapi.yaml «position поза межами етапу»)', () {
    // Position 0 is covered by «addOpenPlanItem: position 0 inserts at the
    // beginning» and «updateOpenPlanItem: order within a stage is changed».
    // Here — the last position of the stage (n − 1). Whether position n
    // (right after the last element) is inside the stage is not defined by the
    // contract and is not tested (TG-002, question 2).
    test('AC-F-010 addOpenPlanItem: position of the last element (n − 1) inserts '
        'before it, positions stay contiguous', () async {
      final mainBefore = stageItems(open, 'main');
      final last = mainBefore.length - 1;
      final plan = await app.api.addItemOk(
        openId,
        exerciseId: 'ex-1',
        stage: 'main',
        position: last,
        parameters: timeParams(2, 120, 30),
      );
      final main = stageItems(plan, 'main');
      expect(main, hasLength(mainBefore.length + 1));
      expect(main[last]['exerciseId'], 'ex-1');
      expect(main.last['id'], mainBefore.last['id']);
      expectContiguousPositions(plan);
    });

    test('AC-F-010 updateOpenPlanItem: the first element moved to the last '
        'position (n − 1) of its stage, positions stay contiguous', () async {
      await addShadow();
      final (plan, _) = await addShadow();
      final idsBefore = stageItems(plan, 'warm-up').map((i) => i['id']).toList();
      final firstId = idsBefore.first;
      final moved = await app.api.patchItemOk(openId, firstId.asString, {
        'position': idsBefore.length - 1,
      });
      final idsAfter = stageItems(moved, 'warm-up').map((i) => i['id']).toList();
      expect(idsAfter, [...idsBefore.skip(1), firstId]);
      expectContiguousPositions(moved);
      expect(stagesOf(moved), stageOrder);
      expect(moved['estimatedDurationSeconds'], plan['estimatedDurationSeconds']);
    });
  });

  group('T-22 deleteOpenPlanItem', () {
    test('POS-18 BDD-033 AC-F-010 deleteOpenPlanItem: emptying the warm-up gives '
        'STAGE_EMPTY for the warm-up and recalculates the total', () async {
      var plan = open;
      for (final item in stageItems(open, 'warm-up')) {
        plan = await app.api.deleteItemOk(openId, item['id'].asString);
      }
      expect(stageItems(plan, 'warm-up'), isEmpty);
      expect(stagesOf(plan), stageOrder);
      expect(warningKeys(plan), contains('STAGE_EMPTY||warm-up|'));
      final removed = stageItems(open, 'warm-up').fold<int>(
        0,
        (sum, i) => sum + i['estimatedDurationSeconds'].asInt,
      );
      expect(
        plan['estimatedDurationSeconds'],
        open['estimatedDurationSeconds'].asInt - removed,
      );
      expect(await app.api.getOpenPlanOk(openId), plan);
    });

    test('AC-F-010 deleteOpenPlanItem: unknown element → 404 NOT_FOUND', () async {
      final res = await app.api.send(
        'deleteOpenPlanItem',
        path: {'openPlanId': openId, 'itemId': 'item-404'},
      );
      expectError(res, 404, 'NOT_FOUND');
    });
  });
}
