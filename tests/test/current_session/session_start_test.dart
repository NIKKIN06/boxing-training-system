/// T-24 (#25): start of a training — start time, working copy, one current
/// session, a repeated start request (API part; navigation is the client).
///
/// Sources: AC-F-012; REQ-F-012; BDD-019, BDD-025, BDD-045 (D-17),
/// BDD-046 (D-18); CON-007; spec/openapi.yaml startCurrentSession,
/// getCurrentSession (and generatePlan, openSavedPlan: «Поточне заняття
/// формуванню не заважає», «API не блокує відкриття плану»);
/// docs/api/scenarios.md POS-25, POS-26, NEG-23, NEG-24.
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

  test('POS-25 POS-26 BDD-045 D-17 AC-F-012 startCurrentSession getCurrentSession: '
      'start from an unsaved generated plan at 18:00 — start time, local start '
      'date, executed plan is a working copy; Location; the plan is not saved '
      'automatically', () async {
    final open = await app.api.generateOk();
    final openId = open['id'].asString;
    final res = await app.api.send('startCurrentSession', body: {'openPlanId': openId});
    expectStatus(res, 201);
    final session = res.body;
    expect(DateTime.parse(session['startedAt'].asString).isAtSameMomentAs(start), isTrue);
    expect(session['localStartDate'], '2026-06-30');
    expect(stagesWithoutIds(session['executedPlan'].asJson), stagesWithoutIds(open));
    expect(Uri.parse(res.location!).path, '/current-session');
    expect(await app.api.currentSessionOk(), session);
    expect(await app.api.listTrainingPlansOk(), isEmpty);
    expect((await app.api.getOpenPlanOk(openId))['sourcePlanId'], isNull);
  });

  test('D-17 AC-F-012 openSavedPlan startCurrentSession: a training starts from '
      'an opened saved plan', () async {
    final saved = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
    final opened = await app.api.openSavedOk(saved['id'].asString);
    final session = await app.api.startOk(opened['id'].asString);
    expect(stagesWithoutIds(session['executedPlan'].asJson), stagesWithoutIds(saved));
  });

  test('BDD-025 NEG-23 AC-F-012 startCurrentSession getCurrentSession: a repeated '
      'start of another plan B → 409 SESSION_ALREADY_ACTIVE; session A and its '
      'data are not overwritten', () async {
    final a = await app.api.generateOk();
    final sessionA = await app.api.startOk(a['id'].asString);
    app.clock.advance(const Duration(minutes: 5));
    final b = await app.api.generateOk(generationParams(hours: 1, minutes: 30));
    final res = await app.api.send(
      'startCurrentSession',
      body: {'openPlanId': b['id']},
    );
    expectError(res, 409, 'SESSION_ALREADY_ACTIVE');
    expect(await app.api.currentSessionOk(), sessionA);
  });

  test('REQ-F-012 AC-F-012 startCurrentSession: an empty open plan → 422 '
      'PLAN_EMPTY, no session', () async {
    final open = await app.api.generateOk();
    final openId = open['id'].asString;
    for (final item in allItems(open)) {
      await app.api.deleteItemOk(openId, item['id'].asString);
    }
    final res = await app.api.send('startCurrentSession', body: {'openPlanId': openId});
    expectError(res, 422, 'PLAN_EMPTY');
    expectError(await app.api.send('getCurrentSession'), 404, 'NO_CURRENT_SESSION');
  });

  test('AC-F-012 startCurrentSession: unknown open plan → 422 OPEN_PLAN_NOT_FOUND', () async {
    final res = await app.api.send('startCurrentSession', body: {'openPlanId': 'open-404'});
    expectError(res, 422, 'OPEN_PLAN_NOT_FOUND');
  });

  test('NEG-24 D-18 getCurrentSession: no current session → 404 NO_CURRENT_SESSION', () async {
    expectError(await app.api.send('getCurrentSession'), 404, 'NO_CURRENT_SESSION');
  });

  test('BDD-046 D-18 CON-007 AC-F-012 getCurrentSession listCompletedTrainings '
      'getAnalytics: after a restart there is no current session; history and '
      'analytics are unchanged', () async {
    final historyBefore = await app.api.historyOk();
    final analyticsBefore = await app.api.analyticsOk();
    await app.api.startOk((await app.api.generateOk())['id'].asString);
    await app.restart();
    expectError(await app.api.send('getCurrentSession'), 404, 'NO_CURRENT_SESSION');
    expect(await app.api.historyOk(), historyBefore);
    expect(await app.api.analyticsOk(), analyticsBefore);
  });

  test('BDD-019 AC-F-012 listCompletedTrainings: until completion the current '
      'session is not in the history', () async {
    await app.api.startOk((await app.api.generateOk())['id'].asString);
    expect(await app.api.historyOk(), isEmpty);
  });

  test('AC-F-012 startCurrentSession updateOpenPlanItem updateExecutedPlanItem: '
      'the executed plan is a copy independent of the open plan', () async {
    final open = await app.api.generateOk();
    final openId = open['id'].asString;
    final withShadow = await app.api.addItemOk(
      openId,
      exerciseId: 'ex-1',
      stage: 'warm-up',
      parameters: timeParams(3, 180, 60),
    );
    final session = await app.api.startOk(openId);
    final openItem = stageItems(withShadow, 'warm-up').last;
    await app.api.patchItemOk(openId, openItem['id'].asString, {
      'parameters': {'rounds': 2},
    });
    expect(await app.api.currentSessionOk(), session);

    final executedItem = stageItems(session['executedPlan'].asJson, 'warm-up').last;
    final res = await app.api.send(
      'updateExecutedPlanItem',
      path: {'itemId': executedItem['id'].asString},
      body: {
        'parameters': {'rounds': 5},
      },
    );
    expectStatus(res, 200);
    final openAfter = await app.api.getOpenPlanOk(openId);
    expect(itemById(openAfter, openItem['id'].asString)['parameters'], timeParams(2, 180, 60));
  });

  test('AC-F-012 generatePlan openSavedPlan: a current session does not block '
      'generation or opening a plan', () async {
    final saved = await app.api.saveNewOk((await app.api.generateOk())['id'].asString);
    await app.api.startOk((await app.api.generateOk())['id'].asString);
    expectStatus(await app.api.send('generatePlan', body: generationParams()), 201);
    expectStatus(
      await app.api.send('openSavedPlan', body: {'sourcePlanId': saved['id']}),
      201,
    );
  });
}
