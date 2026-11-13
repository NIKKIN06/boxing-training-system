/// T-25 (#26): completion with saving and abort without saving; a repeated
/// completion; refinement of the executed plan (D-19).
///
/// Sources: AC-F-013; REQ-F-013; BDD-016, BDD-017 (see history_test.dart),
/// BDD-021 (see storage_test.dart), BDD-026, BDD-028, BDD-029, BDD-047 (D-19),
/// D-17; SRS §5.3; spec/openapi.yaml completeTraining, abortCurrentSession,
/// updateExecutedPlanItem, deleteExecutedPlanItem, getCurrentSession;
/// docs/api/scenarios.md POS-27…POS-31, NEG-25, NEG-26, NEG-30, NEG-31, NEG-34.
/// BDD-027 (rejecting the confirmation) has no API operation: the client does
/// not send a request (spec/openapi.yaml abortCurrentSession: «ознаки
/// підтвердження в API немає»).
/// Readiness of T-25: one test — after changes of the working copy (parameters,
/// deleted exercise) and a confirmed abort the history, analytics for the
/// period and the saved plan are unchanged; separately — a plan started
/// unsaved is not saved automatically (D-17).
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

void main() {
  late TestApp app;
  final start = DateTime(2026, 6, 30, 18);

  setUp(() async => app = await TestApp.start(now: start));

  /// Starts a session from a generated plan with ex-1/var-1 (rounds max 5) in
  /// the warm-up and ex-3/var-1 (sets max 5, repetitions) in the main part.
  Future<(Json session, String shadowId, String pushUpsId)> startKnown({
    String? openPlanId,
  }) async {
    final openId = openPlanId ?? (await app.api.generateOk())['id'].asString;
    await app.api.addItemOk(
      openId,
      exerciseId: 'ex-1',
      stage: 'warm-up',
      parameters: timeParams(3, 180, 60),
    );
    await app.api.addItemOk(
      openId,
      exerciseId: 'ex-3',
      stage: 'main',
      parameters: repetitionParams(3, 10, 30),
    );
    final session = await app.api.startOk(openId);
    final executed = session['executedPlan'].asJson;
    return (
      session,
      stageItems(executed, 'warm-up').last['id'].asString,
      stageItems(executed, 'main').last['id'].asString,
    );
  }

  Future<ApiResponse> patchExecuted(String itemId, Json body) =>
      app.api.send('updateExecutedPlanItem', path: {'itemId': itemId}, body: body);

  group('T-25 completeTraining', () {
    test('BDD-016 POS-27 POS-30 NEG-25 AC-F-013 updateExecutedPlanItem '
        'completeTraining listCompletedTrainings getCurrentSession '
        'startCurrentSession: started at 18:00, refined sets and a note → one '
        'record with 18:00, the refined plan and the note; the session is no '
        'longer current; a repeated completion creates no second record; '
        'another training can be started', () async {
      final (_, _, pushUpsId) = await startKnown();
      final patched = await patchExecuted(pushUpsId, {
        'parameters': {'sets': 6},
      });
      expectStatus(patched, 200);
      final refinedItem = itemById(patched.body['executedPlan'].asJson, pushUpsId);
      expect(refinedItem['parameters'].asJson['sets'], 6);
      expect(refinedItem['estimatedDurationSeconds'], expectedItemDuration(refinedItem));

      app.clock.advance(const Duration(minutes: 70));
      final res = await app.api.send(
        'completeTraining',
        body: {'note': '[TEST] Зроблено додаткові підходи віджимань.'},
      );
      expectStatus(res, 201);
      final record = res.body;
      expect(DateTime.parse(record['startedAt'].asString).isAtSameMomentAs(start), isTrue);
      expect(record['localStartDate'], '2026-06-30');
      expect(
        stagesWithoutIds(record['executedPlan'].asJson),
        stagesWithoutIds(patched.body['executedPlan'].asJson),
      );
      expect(record['note'], '[TEST] Зроблено додаткові підходи віджимань.');
      expect(Uri.parse(res.location!).path, '/completed-trainings/${record['id']}');

      expectError(await app.api.send('getCurrentSession'), 404, 'NO_CURRENT_SESSION');
      final again = await app.api.send('completeTraining', body: {'note': '[TEST] Повторно.'});
      expectError(again, 409, 'NO_CURRENT_SESSION');
      expect((await app.api.historyOk()).map((t) => t['id']), [record['id']]);

      expectStatus(
        await app.api.send(
          'startCurrentSession',
          body: {'openPlanId': (await app.api.generateOk())['id']},
        ),
        201,
      );
    });

    final noNote = <(String, Object?)>[
      ('body {}', <String, Object?>{}),
      ('note null', <String, Object?>{'note': null}),
      ('no body (requestBody is optional)', noBody),
    ];
    for (final (name, body) in noNote) {
      test('POS-31 AC-F-013 completeTraining: without a note ($name) → the record '
          'has note null', () async {
        await startKnown();
        final record = await app.api.completeOk(body: body);
        expect(record['note'], isNull);
      });
    }

    test('BDD-029 AC-F-013 completeTraining: 90 minutes after the start of a '
        '1 h plan the result is saved', () async {
      await startKnown();
      app.clock.advance(const Duration(minutes: 90));
      final record = await app.api.completeOk();
      expect(DateTime.parse(record['startedAt'].asString).isAtSameMomentAs(start), isTrue);
      expect(await app.api.historyOk(), hasLength(1));
    });

    test('NEG-25 AC-F-013 completeTraining: no current session → 409 '
        'NO_CURRENT_SESSION', () async {
      expectError(await app.api.send('completeTraining', body: {}), 409, 'NO_CURRENT_SESSION');
      expect(await app.api.historyOk(), isEmpty);
    });

    test('AC-F-013 completeTraining: note of a wrong JSON type → 400 BAD_REQUEST, '
        'the session stays current', () async {
      final (session, _, _) = await startKnown();
      expectError(await app.api.send('completeTraining', body: {'note': 5}), 400, 'BAD_REQUEST');
      expect(await app.api.currentSessionOk(), session);
    });
  });

  group('T-25 updateExecutedPlanItem / deleteExecutedPlanItem (D-19)', () {
    test('BDD-047 D-19 AC-F-013 updateExecutedPlanItem: 7 rounds above the variant '
        'maximum 5 are accepted; 0 rounds are rejected; there is no operation '
        'to add exercises to the executed plan', () async {
      final (_, shadowId, _) = await startKnown();
      final seven = await patchExecuted(shadowId, {
        'parameters': {'rounds': 7},
      });
      expectStatus(seven, 200);
      final item = itemById(seven.body['executedPlan'].asJson, shadowId);
      expect(item['parameters'], timeParams(7, 180, 60));
      expect(item['estimatedDurationSeconds'], 7 * 180 + 6 * 60);

      final zero = await patchExecuted(shadowId, {
        'parameters': {'rounds': 0},
      });
      expectError(zero, 422, 'VALIDATION_FAILED');
      expectDetail(zero, 'parameters.rounds', constraint: 'MINIMUM');
      expect(await app.api.currentSessionOk(), seven.body);

      final adding = app.api.contract.operations.values.where(
        (op) => op.method == 'POST' && op.pathTemplate.startsWith('/current-session/'),
      );
      expect(adding, isEmpty, reason: 'D-19: adding exercises is not available');
    });

    final invalid = <({String name, bool pushUps, Json body, String field, String? constraint})>[
      (
        name: 'NEG-34 zero sets',
        pushUps: true,
        body: {
          'parameters': {'sets': 0},
        },
        field: 'parameters.sets',
        constraint: 'MINIMUM',
      ),
      (
        name: 'D-19 zero repetitions',
        pushUps: true,
        body: {
          'parameters': {'repetitions': 0},
        },
        field: 'parameters.repetitions',
        constraint: 'MINIMUM',
      ),
      (
        name: 'D-19 zero interval',
        pushUps: false,
        body: {
          'parameters': {'intervalSeconds': 0},
        },
        field: 'parameters.intervalSeconds',
        constraint: 'MINIMUM',
      ),
      (
        name: 'D-19 negative rest',
        pushUps: false,
        body: {
          'parameters': {'restSeconds': -1},
        },
        field: 'parameters.restSeconds',
        constraint: 'MINIMUM',
      ),
      (
        name: 'D-19 non-integer rounds',
        pushUps: false,
        body: {
          'parameters': {'rounds': 2.5},
        },
        field: 'parameters.rounds',
        constraint: null,
      ),
      (
        name: 'D-19 field of the other mode (rounds for repetitions)',
        pushUps: true,
        body: {
          'parameters': {'rounds': 2},
        },
        field: 'parameters.rounds',
        constraint: null,
      ),
      (
        name: 'D-08 D-19 repetitionTimeSeconds',
        pushUps: true,
        body: {
          'parameters': {'repetitionTimeSeconds': 5},
        },
        field: 'parameters.repetitionTimeSeconds',
        constraint: null,
      ),
      (
        name: 'D-19 stage outside the allowed fields',
        pushUps: false,
        body: {
          'parameters': {'rounds': 2},
          'stage': 'main',
        },
        field: 'stage',
        constraint: null,
      ),
      (
        name: 'D-19 position outside the allowed fields',
        pushUps: false,
        body: {
          'parameters': {'rounds': 2},
          'position': 0,
        },
        field: 'position',
        constraint: null,
      ),
    ];
    for (final c in invalid) {
      test('${c.name.startsWith('NEG') ? '' : 'AC-F-013 '}${c.name}: '
          'updateExecutedPlanItem → 422 VALIDATION_FAILED, session unchanged', () async {
        final (session, shadowId, pushUpsId) = await startKnown();
        final res = await patchExecuted(c.pushUps ? pushUpsId : shadowId, c.body);
        expectError(res, 422, 'VALIDATION_FAILED');
        expectDetail(res, c.field, constraint: c.constraint);
        expect(await app.api.currentSessionOk(), session);
      });
    }

    test('POS-28 D-19 AC-F-013 deleteExecutedPlanItem: the exercise is removed '
        'from the executed plan; the open plan is unchanged', () async {
      final open = await app.api.generateOk();
      final openId = open['id'].asString;
      final (_, _, pushUpsId) = await startKnown(openPlanId: openId);
      final openBefore = await app.api.getOpenPlanOk(openId);
      final res = await app.api.send('deleteExecutedPlanItem', path: {'itemId': pushUpsId});
      expectStatus(res, 200);
      expect(
        allItems(res.body['executedPlan'].asJson).map((i) => i['id']),
        isNot(contains(pushUpsId)),
      );
      expect(await app.api.currentSessionOk(), res.body);
      expect(await app.api.getOpenPlanOk(openId), openBefore);
    });

    test('NEG-30 AC-F-013 deleteExecutedPlanItem updateExecutedPlanItem: unknown '
        'element → 404 NOT_FOUND', () async {
      await startKnown();
      expectError(
        await app.api.send('deleteExecutedPlanItem', path: {'itemId': 'item-404'}),
        404,
        'NOT_FOUND',
      );
      expectError(
        await patchExecuted('item-404', {
          'parameters': {'rounds': 2},
        }),
        404,
        'NOT_FOUND',
      );
    });

    test('AC-F-013 deleteExecutedPlanItem updateExecutedPlanItem: no current '
        'session → 404 NO_CURRENT_SESSION', () async {
      expectError(
        await app.api.send('deleteExecutedPlanItem', path: {'itemId': 'item-1'}),
        404,
        'NO_CURRENT_SESSION',
      );
      expectError(
        await patchExecuted('item-1', {
          'parameters': {'rounds': 2},
        }),
        404,
        'NO_CURRENT_SESSION',
      );
    });
  });

  group('T-25 abortCurrentSession', () {
    test('BDD-026 POS-29 AC-F-013 abortCurrentSession: a session from a saved plan '
        'with changed parameters and a deleted exercise is closed; changes are '
        'discarded; history, analytics for the period and the saved plan are '
        'unchanged; another training can be started', () async {
      final saved = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
      final planId = saved['id'].asString;
      final opened = await app.api.openSavedOk(planId);
      final historyBefore = await app.api.historyOk();
      final analyticsBefore = await app.api.analyticsOk();
      final (_, shadowId, pushUpsId) = await startKnown(openPlanId: opened['id'].asString);
      expectStatus(
        await patchExecuted(shadowId, {
          'parameters': {'rounds': 5},
        }),
        200,
      );
      expectStatus(
        await app.api.send('deleteExecutedPlanItem', path: {'itemId': pushUpsId}),
        200,
      );

      final res = await app.api.send('abortCurrentSession');
      expectStatus(res, 204);
      expect(res.text, isEmpty);
      expectError(await app.api.send('getCurrentSession'), 404, 'NO_CURRENT_SESSION');
      expect(await app.api.historyOk(), historyBefore);
      expect(await app.api.analyticsOk(), analyticsBefore);
      expect(await app.api.getTrainingPlanOk(planId), saved);
      expectStatus(
        await app.api.send('startCurrentSession', body: {'openPlanId': opened['id']}),
        201,
      );
    });

    test('D-17 AC-F-012 AC-F-013 abortCurrentSession: a plan started unsaved is '
        'not saved automatically', () async {
      final open = await app.api.generateOk();
      await startKnown(openPlanId: open['id'].asString);
      expectStatus(await app.api.send('abortCurrentSession'), 204);
      expect(await app.api.listTrainingPlansOk(), isEmpty);
      expect((await app.api.getOpenPlanOk(open['id'].asString))['sourcePlanId'], isNull);
    });

    test('BDD-028 NEG-26 AC-F-013 deleteExecutedPlanItem completeTraining '
        'abortCurrentSession: with all executed exercises deleted the completion '
        'is rejected (422 EXECUTED_PLAN_EMPTY) and the session stays; the abort '
        'closes it without a record; another training can be started', () async {
      final (session, _, _) = await startKnown();
      Json current = session;
      for (final item in allItems(session['executedPlan'].asJson)) {
        final res = await app.api.send(
          'deleteExecutedPlanItem',
          path: {'itemId': item['id'].asString},
        );
        expectStatus(res, 200);
        current = res.body;
      }
      expect(allItems(current['executedPlan'].asJson), isEmpty);
      expect(stagesOf(current['executedPlan'].asJson), stageOrder);

      final complete = await app.api.send('completeTraining', body: {});
      expectError(complete, 422, 'EXECUTED_PLAN_EMPTY');
      expect(await app.api.currentSessionOk(), current);
      expect(await app.api.historyOk(), isEmpty);

      expectStatus(await app.api.send('abortCurrentSession'), 204);
      expectError(await app.api.send('getCurrentSession'), 404, 'NO_CURRENT_SESSION');
      expect(await app.api.historyOk(), isEmpty);
      await startKnown();
    });

    test('NEG-31 AC-F-013 abortCurrentSession: no current session → 404 '
        'NO_CURRENT_SESSION', () async {
      expectError(await app.api.send('abortCurrentSession'), 404, 'NO_CURRENT_SESSION');
    });
  });
}
