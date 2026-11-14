/// Property checks of a generated plan (AC-NF-006: properties, not a concrete
/// composition). Derived from SRS §5.1 (selection rules 1–6), §5.2 (three
/// non-empty stages in fixed order, a variant at most once — by its id, D-33),
/// §5.7 / AC-F-008 p. 3 (parameters within [min; max]), D-08 (`e` fixed).
library;

import 'package:test/test.dart';

import 'json.dart';
import 'test_app.dart';

/// Asserts SRS §5.1 rules 1–6 and §5.2 for a generated plan against the
/// catalog data.
void expectSelectionRules(Json plan, CatalogData catalog, Json params) {
  expect(stagesOf(plan), stageOrder, reason: 'stage order §5.2');
  for (final stage in stageOrder) {
    expect(stageItems(plan, stage), isNotEmpty, reason: '$stage is empty (D-12)');
  }
  final seen = <String>{};
  for (final stage in stageOrder) {
    final items = stageItems(plan, stage);
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final exerciseId = item['exerciseId'].asString;
      final variant = item['variant'].asJson;
      final source = catalog.exercise(exerciseId);
      final sourceVariant = catalog.variant(exerciseId, variant['id'].asString);
      final why = '$stage $exerciseId/${variant['id']}';
      expect(item['stage'], stage, reason: why);
      expect(item['position'], i, reason: '$why position');
      expect(item['exerciseName'], source['name'], reason: why);
      expect(variant, sourceVariant, reason: '$why variant copy');
      expect(source['allowedStages'], contains(stage), reason: '$why rule 1');
      expect(source['allowedLevels'], contains(params['level']), reason: '$why rule 2');
      expect(
        source['allowedIntensities'],
        contains(params['intensity']),
        reason: '$why rule 3',
      );
      expect(
        params['availableEquipment'].asList,
        containsAll(variant['equipment'].asList),
        reason: '$why rule 4',
      );
      if (stage == 'main') {
        expect(source['emphases'], contains(params['emphasis']), reason: '$why rule 5');
      }
      expect(source['deprecated'], isFalse, reason: '$why rule 6 (D-06)');
      expect(seen.add('$exerciseId/${variant['id']}'), isTrue, reason: '$why repeated');
      expectParametersWithinVariant(item, why);
    }
  }
}

/// AC-F-008 p. 3, SRS §5.7: each parameter is within [min; max] of the
/// variant; `e` is the fixed value of the variant (D-08).
void expectParametersWithinVariant(Json item, String why) {
  final p = item['parameters'].asJson;
  final v = item['variant'].asJson;
  final fields = v['mode'] == 'time'
      ? ['rounds', 'intervalSeconds', 'restSeconds']
      : ['sets', 'repetitions', 'restSeconds'];
  for (final f in fields) {
    final range = v[f].asJson;
    expect(
      p[f].asInt,
      inInclusiveRange(range['min'].asInt, range['max'].asInt),
      reason: '$why $f',
    );
  }
  if (v['mode'] == 'repetitions') {
    expect(p['repetitionTimeSeconds'], v['repetitionTimeSeconds'], reason: '$why e');
  }
}
