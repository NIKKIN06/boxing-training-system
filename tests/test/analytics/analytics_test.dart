/// T-27 (#28): analytics — default period, bounds of the range, grouping by the
/// local date, indicators, zero data.
///
/// Sources: AC-F-015, AC-F-016; REQ-F-015, REQ-F-016; BDD-018, BDD-019,
/// BDD-020, BDD-026, BDD-030, BDD-048 (D-21), BDD-049 (D-22); ADD-002 D-35;
/// spec/openapi.yaml getAnalytics (dailyCounts contains every day of the
/// period; sum of counts = completedTrainingCount; grouping by exerciseId;
/// the name from the newest training of the period; the current session is
/// not counted; unlimited length); docs/api/scenarios.md POS-35, POS-36,
/// NEG-27, NEG-28, NEG-29.
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

/// Every date of `[from; to]` as `YYYY-MM-DD` (calendar days, UTC arithmetic).
List<String> daysOf(String from, String to) {
  final first = DateTime.parse('${from}T00:00:00Z');
  final last = DateTime.parse('${to}T00:00:00Z');
  return [
    for (var d = first; !d.isAfter(last); d = d.add(const Duration(days: 1))) isoDate(d),
  ];
}

/// Asserts the invariants of getAnalytics for [period] (AC-F-016, D-22).
void expectConsistent(Json analytics, String from, String to) {
  expect(analytics['period'], {'from': from, 'to': to});
  final daily = analytics['dailyCounts'].asJsonList;
  expect(daily.map((d) => d['date']), daysOf(from, to), reason: 'every day of the period');
  expect(
    daily.fold<int>(0, (s, d) => s + d['count'].asInt),
    analytics['completedTrainingCount'],
    reason: 'sum of daily counts',
  );
}

int countOn(Json analytics, String date) =>
    analytics['dailyCounts'].asJsonList.firstWhere((d) => d['date'] == date)['count'].asInt;

Json? frequencyOf(Json analytics, String exerciseId) {
  final found = analytics['exerciseFrequencies'].asJsonList.where(
    (f) => f['exerciseId'] == exerciseId,
  );
  return found.isEmpty ? null : found.single;
}

void main() {
  late TestApp app;

  setUp(() async => app = await TestApp.start(now: DateTime(2026, 6, 30, 20)));

  /// Completes a training that starts at [start] (local time) and contains
  /// the generated items plus [extra] items (exerciseId, variantId, params).
  Future<Json> completeAt(
    DateTime start, {
    List<(String, String, Json)> extra = const [],
  }) async {
    final saved = app.clock.current;
    app.clock.set(start);
    final openId = (await app.api.generateOk())['id'].asString;
    for (final (exerciseId, variantId, params) in extra) {
      await app.api.addItemOk(
        openId,
        exerciseId: exerciseId,
        variantId: variantId,
        stage: 'main',
        parameters: params,
      );
    }
    await app.api.startOk(openId);
    app.clock.advance(const Duration(minutes: 40));
    final record = await app.api.completeOk();
    app.clock.set(saved);
    return record;
  }

  final shadow = ('ex-1', 'var-1', timeParams(2, 120, 30));

  test('BDD-018 POS-35 AC-F-015 AC-F-016 getAnalytics: T1 on 1 June, T2 on 30 June, '
      'T3 on 1 July; E1 twice in T1 and once in T2; period 1–30 June → 2 '
      'trainings, sum of days 2, frequency of E1 = 2, T3 not counted', () async {
    app.clock.set(DateTime(2026, 7, 1, 20));
    await completeAt(DateTime(2026, 6, 1, 10), extra: [shadow, shadow]);
    await completeAt(DateTime(2026, 6, 30, 10), extra: [shadow]);
    await completeAt(DateTime(2026, 7, 1, 10), extra: [shadow]);
    final res = await app.api.send(
      'getAnalytics',
      query: {'from': '2026-06-01', 'to': '2026-06-30'},
    );
    expectStatus(res, 200);
    final a = res.body;
    expectConsistent(a, '2026-06-01', '2026-06-30');
    expect(a['completedTrainingCount'], 2);
    expect(countOn(a, '2026-06-01'), 1);
    expect(countOn(a, '2026-06-30'), 1);
    expect(frequencyOf(a, 'ex-1')?['trainingCount'], 2);
  });

  test('AC-F-016 getAnalytics getCompletedTraining: the frequency of each exercise '
      'equals the number of trainings of the period that contain its id', () async {
    final records = [
      await completeAt(DateTime(2026, 6, 10, 9), extra: [shadow]),
      await completeAt(DateTime(2026, 6, 12, 9)),
      await completeAt(DateTime(2026, 6, 14, 9), extra: [shadow, shadow]),
    ];
    final expected = <String, int>{};
    for (final r in records) {
      final details = await app.api.completedTrainingOk(r['id'].asString);
      final ids = allItems(details['executedPlan'].asJson).map((i) => i['exerciseId'].asString).toSet();
      for (final id in ids) {
        expected[id] = (expected[id] ?? 0) + 1;
      }
    }
    final a = await app.api.analyticsOk(from: '2026-06-01', to: '2026-06-30');
    expectConsistent(a, '2026-06-01', '2026-06-30');
    expect(a['completedTrainingCount'], 3);
    expect(
      {
        for (final f in a['exerciseFrequencies'].asJsonList)
          f['exerciseId'].asString: f['trainingCount'].asInt,
      },
      expected,
    );
  });

  test('AC-F-016 getAnalytics: several inclusions and different variants of one '
      'exercise in one training are counted once', () async {
    await completeAt(
      DateTime(2026, 6, 20, 9),
      extra: [
        ('ex-6', 'var-1', timeParams(2, 120, 30)),
        ('ex-6', 'var-2', timeParams(2, 120, 30)),
        ('ex-6', 'var-2', timeParams(3, 120, 30)),
      ],
    );
    final a = await app.api.analyticsOk(from: '2026-06-20', to: '2026-06-20');
    expect(frequencyOf(a, 'ex-6')?['trainingCount'], 1);
  });

  test('BDD-049 D-22 AC-F-016 getAnalytics: a day without trainings is shown with '
      '0; E1 renamed between T1 and T2 is counted twice under the name from the '
      'newest training of the period', () async {
    final e1 = await app.api.createExerciseOk({...ropeExerciseInput(), 'name': 'Джеб'});
    final e1Id = e1['id'].asString;
    final variant = e1['variants'].asJsonList.single;
    final item = (e1Id, variant['id'].asString, timeParams(2, 120, 30));
    await completeAt(DateTime(2026, 6, 1, 10), extra: [item]);
    expectStatus(
      await app.api.send(
        'updateExercise',
        path: {'exerciseId': e1Id},
        body: {...ropeExerciseInput(), 'name': 'Джеб з кроком', 'variants': [variant]},
      ),
      200,
    );
    await completeAt(DateTime(2026, 6, 3, 10), extra: [item]);
    final a = await app.api.analyticsOk(from: '2026-06-01', to: '2026-06-03');
    expectConsistent(a, '2026-06-01', '2026-06-03');
    expect(countOn(a, '2026-06-02'), 0);
    expect(frequencyOf(a, e1Id), {
      'exerciseId': e1Id,
      'exerciseName': 'Джеб з кроком',
      'trainingCount': 2,
    });
  });

  test('AC-F-015 getAnalytics: the day is the local start date fixed at the start, '
      'not the completion date', () async {
    app.clock.set(DateTime(2026, 6, 30, 23, 50));
    await app.api.startOk((await app.api.generateOk())['id'].asString);
    app.clock.set(DateTime(2026, 7, 1, 0, 30));
    final record = await app.api.completeOk();
    expect(record['localStartDate'], '2026-06-30');
    final a = await app.api.analyticsOk(from: '2026-06-30', to: '2026-07-01');
    expect(countOn(a, '2026-06-30'), 1);
    expect(countOn(a, '2026-07-01'), 0);
  });

  test('BDD-019 AC-F-016 startCurrentSession getAnalytics: a current unfinished '
      'session is not included in the indicators of its period', () async {
    await app.api.startOk((await app.api.generateOk())['id'].asString);
    final a = await app.api.analyticsOk(from: '2026-06-30', to: '2026-06-30');
    expect(a['completedTrainingCount'], 0);
    expect(a['exerciseFrequencies'], isEmpty);
  });

  test('BDD-020 POS-36 AC-F-016 getAnalytics: no completed trainings → count 0, '
      'every day with 0, empty frequencies', () async {
    final a = await app.api.analyticsOk(from: '2026-06-29', to: '2026-06-30');
    expectConsistent(a, '2026-06-29', '2026-06-30');
    expect(a['completedTrainingCount'], 0);
    expect(a['dailyCounts'].asJsonList.map((d) => d['count']), everyElement(0));
    expect(a['exerciseFrequencies'], isEmpty);
  });

  test('BDD-026 AC-F-013 AC-F-016 abortCurrentSession getAnalytics: an aborted '
      'session does not change the indicators', () async {
    await completeAt(DateTime(2026, 6, 15, 9), extra: [shadow]);
    final before = await app.api.analyticsOk();
    await app.api.startOk((await app.api.generateOk())['id'].asString);
    expectStatus(await app.api.send('abortCurrentSession'), 204);
    expect(await app.api.analyticsOk(), before);
  });

  group('T-27 getAnalytics: period (AC-F-015, D-21, D-35)', () {
    test('BDD-030 AC-F-015 getAnalytics: without a range on 30 June 2026 the '
        'period is 1–30 June inclusive (today and 29 previous days)', () async {
      final a = await app.api.analyticsOk();
      expectConsistent(a, '2026-06-01', '2026-06-30');
      expect(a['dailyCounts'].asList, hasLength(30));
    });

    test('BDD-030 NEG-27 AC-F-015 getAnalytics: start after the end → 422 '
        'INVALID_PERIOD', () async {
      final res = await app.api.send(
        'getAnalytics',
        query: {'from': '2026-06-30', 'to': '2026-06-01'},
      );
      expectError(res, 422, 'INVALID_PERIOD');
      expectDetail(res, 'from', constraint: 'NOT_AFTER_TO');
    });

    test('BDD-030 NEG-28 D-35 AC-F-015 getAnalytics: only the start → 422 '
        'INVALID_PERIOD', () async {
      final res = await app.api.send('getAnalytics', query: {'from': '2026-06-01'});
      expectError(res, 422, 'INVALID_PERIOD');
      expectDetail(res, 'to', constraint: 'REQUIRED_WITH_FROM');
    });

    test('BDD-030 D-35 AC-F-015 getAnalytics: only the end → 422 INVALID_PERIOD', () async {
      final res = await app.api.send('getAnalytics', query: {'to': '2026-06-30'});
      expectError(res, 422, 'INVALID_PERIOD');
    });

    test('BDD-048 NEG-29 D-21 AC-F-015 getAnalytics: on 30 June 2026 the period '
        '1 June – 1 July → 422 END_DATE_IN_FUTURE', () async {
      final res = await app.api.send(
        'getAnalytics',
        query: {'from': '2026-06-01', 'to': '2026-07-01'},
      );
      expectError(res, 422, 'END_DATE_IN_FUTURE');
      expectDetail(res, 'to', constraint: 'NOT_AFTER_TODAY');
    });

    test('D-21 AC-F-015 getAnalytics: the end date equal to today is accepted; '
        'bounds are inclusive', () async {
      await completeAt(DateTime(2026, 6, 1, 0, 5));
      await completeAt(DateTime(2026, 6, 30, 19));
      final a = await app.api.analyticsOk(from: '2026-06-01', to: '2026-06-30');
      expect(a['completedTrainingCount'], 2);
    });

    test('D-21 AC-F-015 getAnalytics: the length of the range is not limited', () async {
      final a = await app.api.analyticsOk(from: '2020-01-01', to: '2026-06-30');
      expectConsistent(a, '2020-01-01', '2026-06-30');
    });
  });
}
