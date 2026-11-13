/// T-20 (#21): tolerance ±10 %, parameter limits, impossibility of generation,
/// difference between the technical search limit and proven impossibility.
///
/// Sources: AC-F-008, AC-F-009; REQ-F-008, REQ-F-009; BDD-007, BDD-010,
/// BDD-011, BDD-012, BDD-038, BDD-039 (D-10), BDD-040 (D-13, D-25), D-11;
/// SRS §5.6, §5.7; spec/openapi.yaml generatePlan (422 VALIDATION_FAILED /
/// PLAN_GENERATION_IMPOSSIBLE, 503 GENERATION_SEARCH_LIMIT_REACHED,
/// limitSeconds); docs/api/scenarios.md NEG-08, NEG-09, NEG-10, NEG-12.
/// Readiness of T-20: for D = 1 h 0 min 3240 s and 3960 s are admissible,
/// 3239 s and 3961 s are not; reduction to minimum (BDD-038); minimum volume
/// > 1.1·D → impossibility (BDD-039); the 3 s limit only with the substituted
/// clock: at 2.999 s the search goes on, at 3.000 s it stops (BDD-040).
///
/// `reasons[]` is optional in the contract, so a reason is checked only when
/// the response has reasons.
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/plan_properties.dart';
import '../support/seeded_random.dart';
import '../support/test_app.dart';

void expectReasonIfPresent(ApiResponse res, String code, {String? stage}) {
  if (res.reasons.isEmpty) return;
  expect(
    res.reasons.where((r) => r['code'] == code && (stage == null || r['stage'] == stage)),
    isNotEmpty,
    reason: 'reasons[] must contain $code${stage == null ? '' : ' ($stage)'}: ${res.text}',
  );
}

void main() {
  group('T-20 generatePlan: inclusive bounds of the tolerance (BDD-010)', () {
    final rows = <({String level, String intensity, int seconds, bool accepted})>[
      (level: 'level-beginner', intensity: 'intensity-low', seconds: 3239, accepted: false),
      (level: 'level-beginner', intensity: 'intensity-medium', seconds: 3240, accepted: true),
      (level: 'level-intermediate', intensity: 'intensity-low', seconds: 3960, accepted: true),
      (level: 'level-intermediate', intensity: 'intensity-medium', seconds: 3961, accepted: false),
    ];
    for (final row in rows) {
      test('BDD-010 AC-F-008 generatePlan: the only candidate of ${row.seconds} s '
          'for 1 h 0 min is ${row.accepted ? 'accepted' : 'rejected'}', () async {
        final app = await TestApp.start(
          catalog: fixtureCatalog('bdd-010-tolerance-bounds.json'),
        );
        final res = await app.api.send(
          'generatePlan',
          body: generationParams(
            level: row.level,
            intensity: row.intensity,
            availableEquipment: const [],
          ),
        );
        if (row.accepted) {
          expectStatus(res, 201);
          expect(res.body['estimatedDurationSeconds'], row.seconds);
          expect(res.body['durationTolerance'], {'minSeconds': 3240, 'maxSeconds': 3960});
        } else {
          expectError(res, 422, 'PLAN_GENERATION_IMPOSSIBLE');
          expect(res.location, isNull);
        }
      });
    }
  });

  group('T-20 generatePlan: tolerance and parameter limits hold (AC-F-008)', () {
    for (final seed in fixedSeeds) {
      for (final (hours, minutes) in [(0, 45), (1, 0), (1, 30)]) {
        test('AC-F-008 D-11 generatePlan: seed $seed, $hours h $minutes min — '
            '0.9·D ≤ total ≤ 1.1·D by exact seconds, parameters within '
            '[min; max]', () async {
          final app = await TestApp.start(seed: seed);
          final plan = await app.api.generateOk(
            generationParams(hours: hours, minutes: minutes),
          );
          final d = targetSeconds(hours, minutes);
          final total = plan['estimatedDurationSeconds'].asInt;
          expect(total * 10, greaterThanOrEqualTo(d * 9));
          expect(total * 10, lessThanOrEqualTo(d * 11));
          for (final item in allItems(plan)) {
            expectParametersWithinVariant(item, item['exerciseId'].asString);
          }
        });
      }
    }
  });

  group('T-20 generatePlan: volume correction within [min; max] (D-10)', () {
    test('BDD-038 D-10 AC-F-008 generatePlan: recommended values exceed 3960 s, '
        'the plan is reduced into 3240–3960 s and no parameter is below the '
        'minimum of its variant', () async {
      for (final seed in fixedSeeds) {
        final app = await TestApp.start(
          catalog: fixtureCatalog('bdd-038-reduce-to-minimum.json'),
          seed: seed,
        );
        final plan = await app.api.generateOk(
          generationParams(availableEquipment: const []),
        );
        expect(
          plan['estimatedDurationSeconds'].asInt,
          inInclusiveRange(3240, 3960),
          reason: 'seed $seed',
        );
        for (final item in allItems(plan)) {
          expectParametersWithinVariant(item, 'seed $seed ${item['exerciseId']}');
        }
      }
    });

    test('BDD-039 D-10 NEG-10 AC-F-009 generatePlan: even the minimum volume '
        'exceeds 3960 s → 422 PLAN_GENERATION_IMPOSSIBLE, no plan', () async {
      final app = await TestApp.start(catalog: fixtureCatalog('bdd-039-min-volume.json'));
      final res = await app.api.send(
        'generatePlan',
        body: generationParams(availableEquipment: const []),
      );
      expectError(res, 422, 'PLAN_GENERATION_IMPOSSIBLE');
      expectReasonIfPresent(res, 'MIN_VOLUME_ABOVE_UPPER_BOUND');
      expect(res.location, isNull);
    });

    test('BDD-012 NEG-09 AC-F-009 generatePlan: maximum volume of all eligible '
        'variants is 80 min for 2 h 0 min → 422 PLAN_GENERATION_IMPOSSIBLE '
        'without exceeding limits or duplicating variants', () async {
      final app = await TestApp.start(catalog: fixtureCatalog('bdd-012-max-volume.json'));
      final res = await app.api.send(
        'generatePlan',
        body: generationParams(hours: 2, availableEquipment: const []),
      );
      expectError(res, 422, 'PLAN_GENERATION_IMPOSSIBLE');
      expectReasonIfPresent(res, 'MAX_VOLUME_BELOW_LOWER_BOUND');
      expect(res.location, isNull);
    });

    test('BDD-011 NEG-08 AC-F-009 generatePlan: no exercises for the cool-down '
        '→ 422 PLAN_GENERATION_IMPOSSIBLE, no incomplete plan', () async {
      // Supplied catalog: for beginner / high / technique / [bag] only the
      // cool-down has no candidates (T-57, stage 5 of lab 5).
      final app = await TestApp.start();
      final res = await app.api.send(
        'generatePlan',
        body: generationParams(intensity: 'intensity-high'),
      );
      expectError(res, 422, 'PLAN_GENERATION_IMPOSSIBLE');
      expectReasonIfPresent(res, 'NO_CANDIDATES_FOR_STAGE', stage: 'cool-down');
      expect(res.location, isNull);
    });
  });

  group('T-20 generatePlan: technical search limit with the substituted clock '
      '(BDD-040, D-13, D-25)', () {
    final fixture = fixtureCatalog('bdd-040-search-limit.json');
    final params = generationParams(hours: 0, minutes: 45, availableEquipment: const []);

    test('BDD-040 D-25 AC-F-009 generatePlan: 2.999 s after the start the search '
        'goes on — the limit is not reported before 3.000 s', () async {
      final app = await TestApp.start(catalog: fixture);
      app.clock.armSearch(
        first: const Duration(milliseconds: 2999),
        firstCount: 1000,
        then: const Duration(seconds: 3),
      );
      final res = await app.api.send('generatePlan', body: params);
      app.clock.disarm();
      expect(res.status, anyOf(422, 503), reason: res.toString());
      if (res.status == 503) {
        expect(
          app.clock.maxElapsedServed,
          greaterThanOrEqualTo(const Duration(seconds: 3)),
          reason: 'stopped at 2.999 s',
        );
      } else {
        expectError(res, 422, 'PLAN_GENERATION_IMPOSSIBLE');
      }
    });

    test('BDD-040 D-13 D-25 NEG-12 AC-F-009 generatePlan: at 3.000 s the search '
        'stops → 503 GENERATION_SEARCH_LIMIT_REACHED with limitSeconds 3, '
        'different from proven impossibility; no open plan', () async {
      final app = await TestApp.start(catalog: fixture);
      app.clock.armSearch(
        first: const Duration(seconds: 3),
        firstCount: 0,
        then: const Duration(seconds: 3),
      );
      final res = await app.api.send('generatePlan', body: params);
      final served = app.clock.scriptedReadings;
      app.clock.disarm();
      expect(served, greaterThanOrEqualTo(2), reason: 'the clock must be read during the search');
      expectError(res, 503, 'GENERATION_SEARCH_LIMIT_REACHED');
      expect(res.body['limitSeconds'], 3);
      expect(res.errorCode, isNot('PLAN_GENERATION_IMPOSSIBLE'));
      expect(res.location, isNull);
    });
  });
}
