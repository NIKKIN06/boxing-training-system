/// T-23 (#24): saving and reopening a plan, independence from the catalog,
/// no empty plan.
///
/// Sources: AC-F-011; REQ-F-011; BDD-014, BDD-015, BDD-023, BDD-033, BDD-042,
/// BDD-043, BDD-044 (D-16), BDD-051 (ADD-002 D-30); D-14, ADD-002 D-31, D-32;
/// SPEC-GATE v1.1 REV-009 (human decision: `modifiedAt` is set at a successful
/// saveNewTrainingPlan or overwriteTrainingPlan; renameOpenPlan does not change
/// it; the order for equal `modifiedAt` is not checked); SRS §4.3.6, §4.5;
/// spec/openapi.yaml saveNewTrainingPlan, overwriteTrainingPlan,
/// getTrainingPlan, listTrainingPlans, deleteTrainingPlan, openSavedPlan,
/// renameOpenPlan, getOpenPlan; docs/api/scenarios.md POS-10, POS-12, POS-13,
/// POS-19…POS-24, NEG-13, NEG-19…NEG-22.
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

void expectSameModifiedAt(Json saved, DateTime localTime) {
  expect(
    DateTime.parse(saved['modifiedAt'].asString).isAtSameMomentAs(localTime),
    isTrue,
    reason: 'modifiedAt ${saved['modifiedAt']} must be the save moment $localTime',
  );
}

/// First time-mode item of a plan and a different admissible number of rounds.
(Json, int) roundsChange(Json plan) {
  final item = allItems(plan).firstWhere(
    (i) => i['variant'].asJson['mode'] == 'time' &&
        i['variant'].asJson['rounds'].asJson['min'] != i['variant'].asJson['rounds'].asJson['max'],
  );
  final range = item['variant'].asJson['rounds'].asJson;
  final current = item['parameters'].asJson['rounds'].asInt;
  return (item, current == range['min'] ? range['min'].asInt + 1 : range['min'].asInt);
}

void main() {
  late TestApp app;

  setUp(() async => app = await TestApp.start());

  group('T-23 saveNewTrainingPlan / getTrainingPlan', () {
    test('POS-21 POS-22 AC-F-011 D-14 D-31 saveNewTrainingPlan getTrainingPlan '
        'getOpenPlan: the saved plan has the same stages, order, variants, '
        'parameters and five generation parameters; Location; the open plan is '
        'linked to it', () async {
      final open = await app.api.generateOk();
      final openId = open['id'].asString;
      final res = await app.api.send(
        'saveNewTrainingPlan',
        body: {'openPlanId': openId},
      );
      expectStatus(res, 201);
      final saved = res.body;
      final planId = saved['id'].asString;
      expect(stagesWithoutIds(saved), stagesWithoutIds(open));
      for (final key in [
        'generationParameters',
        'targetDurationSeconds',
        'durationTolerance',
        'estimatedDurationSeconds',
        'warnings',
      ]) {
        expect(saved[key], open[key], reason: key);
      }
      expect(Uri.parse(res.location!).path, '/training-plans/$planId');
      expect(await app.api.getTrainingPlanOk(planId), saved);
      expect((await app.api.getOpenPlanOk(openId))['sourcePlanId'], planId);
    });

    test('BDD-042 D-16 D-32 AC-F-011 saveNewTrainingPlan renameOpenPlan '
        'overwriteTrainingPlan: unsaved plan has no name; saved on 12.11.2026 at '
        '18:05 it is «План від 12.11.2026 18:05»; renamed «Спаринговий день»; '
        'with a cleared name it gets the default name of that save', () async {
      app.clock.set(DateTime(2026, 11, 12, 18, 5));
      final open = await app.api.generateOk();
      final openId = open['id'].asString;
      expect(open['name'], isNull);

      final saved = await app.api.saveNewOk(openId);
      final planId = saved['id'].asString;
      expect(saved['name'], 'План від 12.11.2026 18:05');

      app.clock.set(DateTime(2026, 11, 12, 18, 10));
      await app.api.renameOk(openId, 'Спаринговий день');
      expect((await app.api.overwriteOk(planId, openId))['name'], 'Спаринговий день');

      app.clock.set(DateTime(2026, 11, 12, 18, 20));
      await app.api.renameOk(openId, '');
      final cleared = await app.api.overwriteOk(planId, openId);
      expect(cleared['name'], 'План від 12.11.2026 18:20');
      expect((await app.api.getTrainingPlanOk(planId))['name'], 'План від 12.11.2026 18:20');
    });

    test('REV-009 D-16 AC-F-011 saveNewTrainingPlan renameOpenPlan '
        'overwriteTrainingPlan: modifiedAt is the moment of a successful save or '
        'overwrite; renaming the open plan does not change it', () async {
      final t1 = DateTime(2026, 6, 30, 17, 45);
      final t2 = DateTime(2026, 6, 30, 17, 50);
      final t3 = DateTime(2026, 6, 30, 17, 55);
      app.clock.set(t1);
      final open = await app.api.generateOk();
      final openId = open['id'].asString;
      final saved = await app.api.saveNewOk(openId);
      final planId = saved['id'].asString;
      expectSameModifiedAt(saved, t1);

      app.clock.set(t2);
      await app.api.renameOk(openId, '[TEST] Ранкове тренування');
      expectSameModifiedAt(await app.api.getTrainingPlanOk(planId), t1);
      final listed = (await app.api.listTrainingPlansOk()).single;
      expect(
        DateTime.parse(listed['modifiedAt'].asString).isAtSameMomentAs(t1),
        isTrue,
      );

      app.clock.set(t3);
      expectSameModifiedAt(await app.api.overwriteOk(planId, openId), t3);
    });

    test('POS-13 D-32 renameOpenPlan saveNewTrainingPlan: a generated unsaved plan '
        'gets a name before the first save; sourcePlanId stays null; the name '
        'is saved', () async {
      final open = await app.api.generateOk();
      final openId = open['id'].asString;
      final renamed = await app.api.renameOk(openId, '[TEST] Ранкове тренування');
      expect(renamed['name'], '[TEST] Ранкове тренування');
      expect(renamed['sourcePlanId'], isNull);
      expect(renamed['stages'], open['stages']);
      expect((await app.api.saveNewOk(openId))['name'], '[TEST] Ранкове тренування');
    });

    test('D-16 AC-F-011 saveNewTrainingPlan: names of saved plans need not be '
        'unique', () async {
      for (var i = 0; i < 2; i++) {
        final open = await app.api.generateOk();
        await app.api.renameOk(open['id'].asString, '[TEST] Однакова назва');
        await app.api.saveNewOk(open['id'].asString);
      }
      final names = (await app.api.listTrainingPlansOk()).map((p) => p['name']);
      expect(names, ['[TEST] Однакова назва', '[TEST] Однакова назва']);
    });
  });

  group('T-23 listTrainingPlans / deleteTrainingPlan', () {
    test('POS-20 D-16 listTrainingPlans: no saved plans → items []', () async {
      final res = await app.api.send('listTrainingPlans');
      expectStatus(res, 200);
      expect(res.body['items'], isEmpty);
    });

    test('BDD-043 POS-19 POS-24 D-16 AC-F-011 listTrainingPlans '
        'deleteTrainingPlan getTrainingPlan: P2 changed later is above P1; '
        'after deletion P1 is absent', () async {
      app.clock.set(DateTime(2026, 6, 30, 17, 45));
      final p1 = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      app.clock.set(DateTime(2026, 7, 1, 8, 30));
      final p2 = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);

      final list = await app.api.listTrainingPlansOk();
      expect(list.map((p) => p['id']), [p2['id'], p1['id']]);
      expect(list.first, {'id': p2['id'], 'name': p2['name'], 'modifiedAt': p2['modifiedAt']});

      final del = await app.api.send(
        'deleteTrainingPlan',
        path: {'planId': p1['id'].asString},
      );
      expectStatus(del, 204);
      expect(del.text, isEmpty);
      expect((await app.api.listTrainingPlansOk()).map((p) => p['id']), [p2['id']]);
      final gone = await app.api.send(
        'getTrainingPlan',
        path: {'planId': p1['id'].asString},
      );
      expectError(gone, 404, 'NOT_FOUND');
    });

    test('REV-009 D-16 AC-F-011 listTrainingPlans overwriteTrainingPlan: an overwrite '
        'moves P1 above P2', () async {
      app.clock.set(DateTime(2026, 6, 30, 17, 45));
      final open1 = (await app.api.generateOk())['id'].asString;
      final p1 = await app.api.saveNewOk(open1);
      app.clock.set(DateTime(2026, 7, 1, 8, 30));
      final p2 = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      app.clock.set(DateTime(2026, 7, 1, 9));
      await app.api.overwriteOk(p1['id'].asString, open1);
      expect(
        (await app.api.listTrainingPlansOk()).map((p) => p['id']),
        [p1['id'], p2['id']],
      );
    });

    test('AC-F-011 D-16 SRS §4.5 deleteTrainingPlan: the history and the current session '
        'keep their own copies', () async {
      final open = await app.api.generateOk();
      final openId = open['id'].asString;
      final saved = await app.api.saveNewOk(openId);
      await app.api.startOk(openId);
      final training = await app.api.completeOk();
      final session = await app.api.startOk(openId);
      final del = await app.api.send(
        'deleteTrainingPlan',
        path: {'planId': saved['id'].asString},
      );
      expectStatus(del, 204);
      expect(await app.api.currentSessionOk(), session);
      expect(await app.api.completedTrainingOk(training['id'].asString), training);
    });

    test('AC-F-011 D-16 getTrainingPlan deleteTrainingPlan: unknown plan → 404 NOT_FOUND', () async {
      expectError(
        await app.api.send('getTrainingPlan', path: {'planId': 'plan-404'}),
        404,
        'NOT_FOUND',
      );
      expectError(
        await app.api.send('deleteTrainingPlan', path: {'planId': 'plan-404'}),
        404,
        'NOT_FOUND',
      );
    });
  });

  group('T-23 openSavedPlan / overwriteTrainingPlan', () {
    test('POS-10 POS-12 BDD-015 AC-F-011 openSavedPlan getOpenPlan: the opened '
        'copy has the saved name, sourcePlanId and the same stages; Location', () async {
      final saved = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      final planId = saved['id'].asString;
      final res = await app.api.send('openSavedPlan', body: {'sourcePlanId': planId});
      expectStatus(res, 201);
      final opened = res.body;
      expect(opened['sourcePlanId'], planId);
      expect(opened['name'], saved['name']);
      expect(stagesWithoutIds(opened), stagesWithoutIds(saved));
      expect(opened['generationParameters'], saved['generationParameters']);
      final openId = opened['id'].asString;
      expect(Uri.parse(res.location!).path, '/open-plans/$openId');
      expect(await app.api.getOpenPlanOk(openId), opened);
    });

    test('BDD-044 D-16 AC-F-011 openSavedPlan updateOpenPlanItem '
        'overwriteTrainingPlan listTrainingPlans: saving the opened plan P1 '
        'overwrites it — one plan P1 with the changed rounds', () async {
      final saved = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      final planId = saved['id'].asString;
      final opened = await app.api.openSavedOk(planId);
      final openId = opened['id'].asString;
      final (item, rounds) = roundsChange(opened);
      await app.api.patchItemOk(openId, item['id'].asString, {
        'parameters': {'rounds': rounds},
      });
      final res = await app.api.send(
        'overwriteTrainingPlan',
        path: {'planId': planId},
        body: {'openPlanId': openId},
      );
      expectStatus(res, 200);
      final list = await app.api.listTrainingPlansOk();
      expect(list.map((p) => p['id']), [planId]);
      final after = await app.api.getTrainingPlanOk(planId);
      final changed = stageItems(after, item['stage'].asString)[item['position'].asInt];
      expect(changed['parameters'].asJson['rounds'], rounds);
      expect(after, res.body);
    });

    test('NEG-13 AC-F-011 openSavedPlan: unknown saved plan → 422 PLAN_NOT_FOUND', () async {
      final res = await app.api.send('openSavedPlan', body: {'sourcePlanId': 'plan-404'});
      expectError(res, 422, 'PLAN_NOT_FOUND');
    });

    test('NEG-19 D-16 AC-F-011 saveNewTrainingPlan: an open plan linked to a '
        'saved plan → 409 OPEN_PLAN_ALREADY_SAVED, no new plan', () async {
      final openId = (await app.api.generateOk())['id'].asString;
      final saved = await app.api.saveNewOk(openId);
      final again = await app.api.send('saveNewTrainingPlan', body: {'openPlanId': openId});
      expectError(again, 409, 'OPEN_PLAN_ALREADY_SAVED');
      final opened = await app.api.openSavedOk(saved['id'].asString);
      final fromOpened = await app.api.send(
        'saveNewTrainingPlan',
        body: {'openPlanId': opened['id']},
      );
      expectError(fromOpened, 409, 'OPEN_PLAN_ALREADY_SAVED');
      expect(await app.api.listTrainingPlansOk(), hasLength(1));
    });

    test('NEG-20 AC-F-011 saveNewTrainingPlan overwriteTrainingPlan: unknown open '
        'plan → 422 OPEN_PLAN_NOT_FOUND', () async {
      expectError(
        await app.api.send('saveNewTrainingPlan', body: {'openPlanId': 'open-404'}),
        422,
        'OPEN_PLAN_NOT_FOUND',
      );
      final saved = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      expectError(
        await app.api.send(
          'overwriteTrainingPlan',
          path: {'planId': saved['id'].asString},
          body: {'openPlanId': 'open-404'},
        ),
        422,
        'OPEN_PLAN_NOT_FOUND',
      );
    });

    test('NEG-22 AC-F-011 overwriteTrainingPlan: the open plan of P1 saved to P2 '
        '→ 409 OPEN_PLAN_SOURCE_MISMATCH, P2 unchanged', () async {
      final p1 = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      final p2 = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      final opened = await app.api.openSavedOk(p1['id'].asString);
      final res = await app.api.send(
        'overwriteTrainingPlan',
        path: {'planId': p2['id'].asString},
        body: {'openPlanId': opened['id']},
      );
      expectError(res, 409, 'OPEN_PLAN_SOURCE_MISMATCH');
      expect(await app.api.getTrainingPlanOk(p2['id'].asString), p2);
    });

    test('AC-F-011 overwriteTrainingPlan: an unsaved generated plan '
        '(sourcePlanId null) → 409 OPEN_PLAN_SOURCE_MISMATCH', () async {
      final p1 = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      final unsaved = await app.api.generateOk();
      final res = await app.api.send(
        'overwriteTrainingPlan',
        path: {'planId': p1['id'].asString},
        body: {'openPlanId': unsaved['id']},
      );
      expectError(res, 409, 'OPEN_PLAN_SOURCE_MISMATCH');
      expect(await app.api.getTrainingPlanOk(p1['id'].asString), p1);
    });

    test('D-16 AC-F-011 overwriteTrainingPlan: the saved plan was deleted after '
        'opening → 404 NOT_FOUND', () async {
      final saved = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      final planId = saved['id'].asString;
      final opened = await app.api.openSavedOk(planId);
      expectStatus(
        await app.api.send('deleteTrainingPlan', path: {'planId': planId}),
        204,
      );
      final res = await app.api.send(
        'overwriteTrainingPlan',
        path: {'planId': planId},
        body: {'openPlanId': opened['id']},
      );
      expectError(res, 404, 'NOT_FOUND');
      expect(await app.api.listTrainingPlansOk(), isEmpty);
    });
  });

  group('T-23 empty plan and warnings on save', () {
    test('BDD-033 NEG-21 AC-F-010 AC-F-011 deleteOpenPlanItem saveNewTrainingPlan '
        'overwriteTrainingPlan: without the warm-up the plan is saved with '
        'STAGE_EMPTY; after deleting the rest it is not saved (422 PLAN_EMPTY)', () async {
      final open = await app.api.generateOk();
      final openId = open['id'].asString;
      for (final item in stageItems(open, 'warm-up')) {
        await app.api.deleteItemOk(openId, item['id'].asString);
      }
      final saved = await app.api.saveNewOk(openId);
      expect(warningCodes(saved), contains('STAGE_EMPTY'));
      for (final item in allItems(await app.api.getOpenPlanOk(openId))) {
        await app.api.deleteItemOk(openId, item['id'].asString);
      }
      final res = await app.api.send(
        'overwriteTrainingPlan',
        path: {'planId': saved['id'].asString},
        body: {'openPlanId': openId},
      );
      expectError(res, 422, 'PLAN_EMPTY');
      expect(await app.api.getTrainingPlanOk(saved['id'].asString), saved);
    });

    test('NEG-21 BDD-033 AC-F-011 saveNewTrainingPlan: a completely empty '
        'generated plan → 422 PLAN_EMPTY, nothing saved', () async {
      final open = await app.api.generateOk();
      final openId = open['id'].asString;
      for (final item in allItems(open)) {
        await app.api.deleteItemOk(openId, item['id'].asString);
      }
      final res = await app.api.send('saveNewTrainingPlan', body: {'openPlanId': openId});
      expectError(res, 422, 'PLAN_EMPTY');
      expect(await app.api.listTrainingPlansOk(), isEmpty);
      expect((await app.api.getOpenPlanOk(openId))['sourcePlanId'], isNull);
    });

    test('BDD-014 POS-23 AC-F-010 AC-F-011 saveNewTrainingPlan '
        'overwriteTrainingPlan: a manually changed plan outside ±10 % is saved '
        'with DURATION_OUT_OF_TOLERANCE', () async {
      app = await TestApp.start(catalog: fixtureCatalog('duration-tunable.json'));
      final open = await app.api.generateOk(generationParams(availableEquipment: const []));
      final openId = open['id'].asString;
      final saved = await app.api.saveNewOk(openId);
      final warm = stageItems(open, 'warm-up').single['id'].asString;
      final main = stageItems(open, 'main').single['id'].asString;
      final cool = stageItems(open, 'cool-down').single['id'].asString;
      await app.api.patchItemOk(openId, main, {'parameters': timeParams(1, 2400, 0)});
      await app.api.patchItemOk(openId, cool, {'parameters': timeParams(1, 600, 0)});
      final edited = await app.api.patchItemOk(openId, warm, {'parameters': timeParams(1, 1, 0)});
      expect(edited['estimatedDurationSeconds'], 3001);
      expect(warningCodes(edited), contains('DURATION_OUT_OF_TOLERANCE'));
      final res = await app.api.send(
        'overwriteTrainingPlan',
        path: {'planId': saved['id'].asString},
        body: {'openPlanId': openId},
      );
      expectStatus(res, 200);
      expect(res.body['estimatedDurationSeconds'], 3001);
      expect(warningCodes(res.body), contains('DURATION_OUT_OF_TOLERANCE'));
    });
  });

  group('T-23 open plans and restart (ADD-002 D-30)', () {
    test('BDD-051 D-30 AC-F-011 getOpenPlan listTrainingPlans: an unsaved open '
        'plan is absent after a restart; saved P1 is in the list', () async {
      final p1 = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      final unsaved = await app.api.generateOk();
      await app.restart();
      final res = await app.api.send(
        'getOpenPlan',
        path: {'openPlanId': unsaved['id'].asString},
      );
      expectError(res, 404, 'NOT_FOUND');
      expect((await app.api.listTrainingPlansOk()).map((p) => p['id']), [p1['id']]);
    });

    test('AC-F-011 D-30 getOpenPlan renameOpenPlan: unknown open plan → 404 NOT_FOUND', () async {
      expectError(
        await app.api.send('getOpenPlan', path: {'openPlanId': 'open-404'}),
        404,
        'NOT_FOUND',
      );
      expectError(
        await app.api.send(
          'renameOpenPlan',
          path: {'openPlanId': 'open-404'},
          body: {'name': '[TEST] Назва'},
        ),
        404,
        'NOT_FOUND',
      );
    });

    test('AC-F-011 D-16 renameOpenPlan: name of a wrong JSON type → 400 BAD_REQUEST', () async {
      final open = await app.api.generateOk();
      final res = await app.api.send(
        'renameOpenPlan',
        path: {'openPlanId': open['id'].asString},
        body: {'name': 5},
      );
      expectError(res, 400, 'BAD_REQUEST');
      expect((await app.api.getOpenPlanOk(open['id'].asString))['name'], isNull);
    });
  });
}
