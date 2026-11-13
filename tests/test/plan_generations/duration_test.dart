/// T-18 (#19): durations of plan items and of the plan (API part; rounding
/// for display «Орієнтовно: …» is the client, T-21).
///
/// Sources: AC-F-007; REQ-F-007; BDD-008, BDD-009, BDD-022; SRS §5.4, §5.5;
/// spec/openapi.yaml generatePlan, getOpenPlan, addOpenPlanItem,
/// updateOpenPlanItem (PlanItem.estimatedDurationSeconds, Plan
/// .estimatedDurationSeconds — exact seconds before rounding).
/// Readiness of T-18: separate cases 660 s, 150 s, 810 s; the tolerance check
/// uses the exact time before rounding.
library;

import 'package:test/test.dart';

import '../support/flows.dart';
import '../support/json.dart';
import '../support/seeded_random.dart';
import '../support/test_app.dart';

void main() {
  late TestApp app;

  group('T-18 addOpenPlanItem: durations of AC-F-007 (supplied catalog)', () {
    late Json open;
    late String openId;

    setUp(() async {
      app = await TestApp.start();
      open = await app.api.generateOk();
      openId = open['id'].asString;
    });

    test('BDD-008 AC-F-007 addOpenPlanItem: 3 rounds × 180 s with 60 s rest '
        '→ 660 s', () async {
      final plan = await app.api.addItemOk(
        openId,
        exerciseId: 'ex-1',
        stage: 'warm-up',
        parameters: timeParams(3, 180, 60),
      );
      final item = stageItems(plan, 'warm-up').last;
      expect(item['exerciseId'], 'ex-1');
      expect(item['estimatedDurationSeconds'], 660);
    });

    test('BDD-009 AC-F-007 addOpenPlanItem: 3 sets × 10 repetitions × 3 s with '
        '30 s rest → 150 s', () async {
      final plan = await app.api.addItemOk(
        openId,
        exerciseId: 'ex-3',
        stage: 'main',
        parameters: repetitionParams(3, 10, 30),
      );
      final item = stageItems(plan, 'main').last;
      expect(item['exerciseId'], 'ex-3');
      expect(item['parameters'].asJson['repetitionTimeSeconds'], 3);
      expect(item['estimatedDurationSeconds'], 150);
    });

    test('AC-F-007 addOpenPlanItem getOpenPlan: the two elements together add '
        '810 s to the plan', () async {
      final before = open['estimatedDurationSeconds'].asInt;
      await app.api.addItemOk(
        openId,
        exerciseId: 'ex-1',
        stage: 'warm-up',
        parameters: timeParams(3, 180, 60),
      );
      final plan = await app.api.addItemOk(
        openId,
        exerciseId: 'ex-3',
        stage: 'main',
        parameters: repetitionParams(3, 10, 30),
      );
      expect(plan['estimatedDurationSeconds'], before + 810);
      expect((await app.api.getOpenPlanOk(openId))['estimatedDurationSeconds'], before + 810);
    });
  });

  group('T-18 generatePlan: durations follow SRS §5.4', () {
    for (final seed in fixedSeeds) {
      test('AC-F-007 BDD-008 BDD-009 generatePlan: seed $seed — each element and '
          'the plan total are computed by the formulas of §5.4', () async {
        app = await TestApp.start(seed: seed);
        final plan = await app.api.generateOk(generationParams(hours: 1, minutes: 30));
        for (final item in allItems(plan)) {
          expect(
            item['estimatedDurationSeconds'],
            expectedItemDuration(item),
            reason: '${item['exerciseId']} ${item['parameters']}',
          );
        }
        expect(plan['estimatedDurationSeconds'], expectedPlanDuration(plan));
      });
    }
  });

  group('T-18 updateOpenPlanItem: exact seconds, no rounding (tunable fixture)', () {
    late String openId;
    late Map<String, String> itemOfStage;

    setUp(() async {
      app = await TestApp.start(catalog: fixtureCatalog('duration-tunable.json'));
      final open = await app.api.generateOk(generationParams(availableEquipment: const []));
      openId = open['id'].asString;
      itemOfStage = {
        for (final stage in stageOrder) stage: stageItems(open, stage).single['id'].asString,
      };
    });

    /// Sets intervals of the single warm-up, main and cool-down items
    /// (1 round, no rest): the exact total is w + m + c seconds.
    Future<Json> setTotal(int w, int m, int c) async {
      await app.api.patchItemOk(openId, itemOfStage['main']!, {'parameters': timeParams(1, m, 0)});
      await app.api.patchItemOk(openId, itemOfStage['cool-down']!, {
        'parameters': timeParams(1, c, 0),
      });
      return app.api.patchItemOk(openId, itemOfStage['warm-up']!, {
        'parameters': timeParams(1, w, 0),
      });
    }

    test('BDD-022 AC-F-007 updateOpenPlanItem: total 5429 s is returned as exact '
        'seconds, not rounded to minutes', () async {
      final plan = await setTotal(1200, 3600, 629);
      expect(plan['estimatedDurationSeconds'], 5429);
    });

    test('AC-F-007 AC-F-010 updateOpenPlanItem: tolerance uses the exact time — '
        '3239 s gives DURATION_OUT_OF_TOLERANCE although it rounds to 54 min', () async {
      final plan = await setTotal(239, 2400, 600);
      expect(plan['estimatedDurationSeconds'], 3239);
      expect(warningCodes(plan), contains('DURATION_OUT_OF_TOLERANCE'));
    });

    test('AC-F-007 AC-F-010 updateOpenPlanItem: 3240 s and 3960 s are inside the '
        'tolerance, 3961 s is outside', () async {
      var plan = await setTotal(240, 2400, 600);
      expect(plan['estimatedDurationSeconds'], 3240);
      expect(warningCodes(plan), isNot(contains('DURATION_OUT_OF_TOLERANCE')));
      plan = await setTotal(960, 2400, 600);
      expect(plan['estimatedDurationSeconds'], 3960);
      expect(warningCodes(plan), isNot(contains('DURATION_OUT_OF_TOLERANCE')));
      plan = await setTotal(961, 2400, 600);
      expect(plan['estimatedDurationSeconds'], 3961);
      expect(warningCodes(plan), contains('DURATION_OUT_OF_TOLERANCE'));
    });
  });
}
