/// T-19 (#20): selection rules for variants and the three-stage structure.
///
/// Sources: AC-F-006, AC-F-008 p. 3; REQ-F-006; BDD-007; SRS §5.1, §5.2;
/// D-06 (BDD-035 — see catalog_version_test.dart), D-11, D-12, D-15, D-33;
/// AC-NF-006; spec/openapi.yaml generatePlan (guarantees of a successful
/// response), getOpenPlan. Readiness of T-19: property tests with several
/// fixed seeds; the randomness source is supplied from outside (D-11).
/// Properties are checked, not a concrete composition (AC-NF-006).
library;

import 'package:test/test.dart';

import '../support/flows.dart';
import '../support/json.dart';
import '../support/plan_properties.dart';
import '../support/seeded_random.dart';
import '../support/test_app.dart';

void main() {
  group('T-19 generatePlan: control catalog with one variant per stage (BDD-007)', () {
    test('BDD-007 AC-F-006 AC-F-008 generatePlan getOpenPlan: stages in order, '
        'each non-empty, rules satisfied, no repeats, total 3600 s, parameters '
        'within limits', () async {
      final path = fixtureCatalog('bdd-007-one-variant-per-stage.json');
      final catalog = CatalogData.load(path);
      final app = await TestApp.start(catalog: path);
      final params = generationParams(availableEquipment: const []);
      final plan = await app.api.generateOk(params);
      expectSelectionRules(plan, catalog, params);
      expect(stageItems(plan, 'warm-up').single['exerciseId'], 'fx7-warm');
      expect(stageItems(plan, 'main').single['exerciseId'], 'fx7-main');
      expect(stageItems(plan, 'cool-down').single['exerciseId'], 'fx7-cool');
      expect(plan['estimatedDurationSeconds'], 3600);
      expect(plan['targetDurationSeconds'], 3600);
      expect(plan['warnings'], isEmpty);
      expect(await app.api.getOpenPlanOk(plan['id'].asString), plan);
    });
  });

  group('T-19 generatePlan: selection rules with decoys (SRS §5.1, fixed seeds)', () {
    final path = fixtureCatalog('selection-rules.json');
    final catalog = CatalogData.load(path);
    const decoys = {
      'decoy-level',
      'decoy-intensity',
      'decoy-equipment',
      'decoy-equipment-partial',
      'decoy-emphasis',
      'decoy-deprecated',
    };
    for (final seed in fixedSeeds) {
      test('AC-F-006 D-06 D-11 generatePlan: seed $seed — every variant '
          'satisfies the rules; no decoy, no ineligible variant var-1 of '
          'sel-two-variants; emphasis is not required for warm-up and '
          'cool-down', () async {
        final app = await TestApp.start(catalog: path, seed: seed);
        final params = generationParams();
        final plan = await app.api.generateOk(params);
        expectSelectionRules(plan, catalog, params);
        final ids = allItems(plan).map((i) => i['exerciseId'].asString).toSet();
        expect(ids.intersection(decoys), isEmpty);
        expect(
          allItems(plan).where(
            (i) =>
                i['exerciseId'] == 'sel-two-variants' &&
                i['variant'].asJson['id'] == 'var-1',
          ),
          isEmpty,
        );
        expect(
          stageItems(plan, 'warm-up').map((i) => i['exerciseId']),
          everyElement('sel-warm'),
        );
        expect(
          stageItems(plan, 'cool-down').map((i) => i['exerciseId']),
          everyElement('sel-cool'),
        );
      });
    }
  });

  group('T-19 generatePlan: supplied catalog (properties, fixed seeds)', () {
    final catalog = CatalogData.load(baseCatalog);
    for (final seed in fixedSeeds) {
      for (final (hours, minutes) in [(1, 0), (1, 30)]) {
        test('AC-F-006 AC-F-008 D-11 generatePlan: seed $seed, $hours h $minutes min — '
            'rules, structure and parameter limits hold', () async {
          final app = await TestApp.start(seed: seed);
          final params = generationParams(hours: hours, minutes: minutes);
          final plan = await app.api.generateOk(params);
          expectSelectionRules(plan, catalog, params);
        });
      }
    }
  });

  group('T-19 generatePlan: reproducibility with a fixed seed (D-11, AC-NF-006)', () {
    for (final seed in fixedSeeds) {
      test('AC-NF-006 D-11 generatePlan: seed $seed gives the same composition '
          'in two fresh applications', () async {
        final first = await TestApp.start(seed: seed);
        final second = await TestApp.start(seed: seed);
        final a = await first.api.generateOk();
        final b = await second.api.generateOk();
        expect(composition(b), composition(a));
        expect(b['estimatedDurationSeconds'], a['estimatedDurationSeconds']);
      });
    }
  });
}
