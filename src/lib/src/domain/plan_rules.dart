/// Rules of plans and time (SRS §5.1, §5.4–§5.6; T-36, T-37, T-38).
library;

import 'domain_error.dart';
import 'enums.dart';
import 'exercise.dart';
import 'plan.dart';

/// SRS §5.4: `T = n × t + (n − 1) × r` (time) or `T = n × p × e + (n − 1) × r`
/// (repetitions); rest is added only between rounds or sets.
int itemDurationSeconds(PlanItemParameters p) => switch (p) {
  TimeParameters() =>
    p.rounds * p.intervalSeconds + (p.rounds - 1) * p.restSeconds,
  RepetitionsParameters() =>
    p.sets * p.repetitions * p.repetitionTimeSeconds +
        (p.sets - 1) * p.restSeconds,
};

/// SRS §5.4: the plan total is the sum of item durations.
int planDurationSeconds(Iterable<PlanStage> stages) => stages.fold(
  0,
  (sum, s) =>
      s.items.fold(sum, (acc, i) => acc + i.estimatedDurationSeconds),
);

/// SRS §5.5: `D = h × 3600 + m × 60`.
int targetDurationSeconds(TargetDuration t) => t.hours * 3600 + t.minutes * 60;

/// SRS §5.6: `0,9 × D ≤ T ≤ 1,1 × D`, bounds included, in whole seconds.
DurationTolerance durationTolerance(int d) =>
    DurationTolerance(minSeconds: (9 * d + 9) ~/ 10, maxSeconds: 11 * d ~/ 10);

/// T-36, AC-F-005, SRS §5.5: hours ≥ 0, minutes 0…59, total > 0 — checked
/// before the search (BDD-006). Structural rules are checked while decoding.
List<ErrorDetail> validateGenerationParameters(GenerationParameters p) {
  final details = <ErrorDetail>[];
  final t = p.targetDuration;
  if (t.hours < 0) {
    details.add(
      const ErrorDetail(
        field: 'targetDuration.hours',
        constraint: Constraint.minimum,
      ),
    );
  }
  if (t.minutes < 0) {
    details.add(
      const ErrorDetail(
        field: 'targetDuration.minutes',
        constraint: Constraint.minimum,
      ),
    );
  } else if (t.minutes > 59) {
    details.add(
      const ErrorDetail(
        field: 'targetDuration.minutes',
        constraint: Constraint.maximum,
      ),
    );
  }
  if (details.isEmpty && targetDurationSeconds(t) <= 0) {
    details.add(
      const ErrorDetail(
        field: 'targetDuration',
        constraint: Constraint.totalGreaterThanZero,
      ),
    );
  }
  return details;
}

/// T-38, SRS §5.1 rules 1–6: the variant [v] of [e] may be selected
/// automatically for [stage]. An empty list of available equipment allows
/// only variants without equipment.
bool isEligible(
  Exercise e,
  Variant v,
  Stage stage,
  GenerationParameters p,
) =>
    e.allowedStages.contains(stage) &&
    e.allowedLevels.contains(p.level) &&
    e.allowedIntensities.contains(p.intensity) &&
    v.fields.equipment.every(p.availableEquipment.contains) &&
    // Rule 5: the emphasis is required only for the main part.
    (stage != Stage.main || e.emphases.contains(p.emphasis)) &&
    // Rule 6, D-06.
    !e.deprecated;

/// T-41, AC-F-010: attributes of the source generation parameters (D-14)
/// that an item does not match — the same rules 2–5 as §5.1; the emphasis is
/// compared only in the main part (stage 7, decision on question 4).
List<WarningAttribute> filterMismatches(
  Exercise e,
  Variant v,
  Stage stage,
  GenerationParameters p,
) => [
  if (!e.allowedLevels.contains(p.level)) WarningAttribute.level,
  if (!e.allowedIntensities.contains(p.intensity)) WarningAttribute.intensity,
  if (!v.fields.equipment.every(p.availableEquipment.contains))
    WarningAttribute.availableEquipment,
  if (stage == Stage.main && !e.emphases.contains(p.emphasis))
    WarningAttribute.emphasis,
];

/// T-41, AC-F-010, SRS §5.3, D-08, BDD-032: parameters of a plan item of
/// variant [v]. Only the fields of the variant mode apply; a missing field
/// keeps its value from [current] (updateOpenPlanItem) or is required
/// (addOpenPlanItem, replaceOpenPlanItem); every value lies within
/// `[min; max]` of the variant; `e` is the variant's fixed value.
/// Returns the parameters, or the violations under `parameters.<field>`.
///
/// With `withinVariant: false` — actual values of an executed plan (T-45,
/// D-19, SRS §5.3): integers ≥ 1 (rest ≥ 0), the variant limits do not apply.
(PlanItemParameters?, List<ErrorDetail>) resolveItemParameters(
  Variant v,
  ParametersInput input, {
  PlanItemParameters? current,
  bool withinVariant = true,
}) {
  final details = <ErrorDetail>[];
  void foreign(String field, int? value) {
    if (value != null) {
      details.add(
        ErrorDetail(
          field: 'parameters.$field',
          constraint: Constraint.additionalProperties,
        ),
      );
    }
  }

  int? value(String field, int? given, int? old, int minimum, ParameterRange r) {
    final x = given ?? old;
    final path = 'parameters.$field';
    if (x == null) {
      details.add(ErrorDetail(field: path, constraint: Constraint.required));
    } else if (x < minimum) {
      details.add(ErrorDetail(field: path, constraint: Constraint.minimum));
    } else if (withinVariant && (x < r.min || x > r.max)) {
      details.add(
        ErrorDetail(field: path, constraint: Constraint.withinVariantRange),
      );
    }
    return x;
  }

  switch (v.fields) {
    case final TimeVariantFields f:
      foreign('sets', input.sets);
      foreign('repetitions', input.repetitions);
      final old = current is TimeParameters ? current : null;
      final n = value('rounds', input.rounds, old?.rounds, 1, f.rounds);
      final t = value(
        'intervalSeconds',
        input.intervalSeconds,
        old?.intervalSeconds,
        1,
        f.intervalSeconds,
      );
      final r = value(
        'restSeconds',
        input.restSeconds,
        old?.restSeconds,
        0,
        f.restSeconds,
      );
      if (details.isNotEmpty) return (null, details);
      return (
        TimeParameters(rounds: n!, intervalSeconds: t!, restSeconds: r!),
        details,
      );
    case final RepetitionsVariantFields f:
      foreign('rounds', input.rounds);
      foreign('intervalSeconds', input.intervalSeconds);
      final old = current is RepetitionsParameters ? current : null;
      final n = value('sets', input.sets, old?.sets, 1, f.sets);
      final p = value(
        'repetitions',
        input.repetitions,
        old?.repetitions,
        1,
        f.repetitions,
      );
      final r = value(
        'restSeconds',
        input.restSeconds,
        old?.restSeconds,
        0,
        f.restSeconds,
      );
      if (details.isNotEmpty) return (null, details);
      return (
        RepetitionsParameters(
          sets: n!,
          repetitions: p!,
          restSeconds: r!,
          repetitionTimeSeconds: f.repetitionTimeSeconds,
        ),
        details,
      );
  }
}

/// Number of items in [stages].
int itemCount(Iterable<PlanStage> stages) =>
    stages.fold(0, (n, s) => n + s.items.length);

/// Working copy of the items of the three stages, in the order of [Stage]
/// (open plan editing, executed plan editing).
List<List<PlanItem>> stageWorkingLists(List<PlanStage> stages) => [
  for (final s in Stage.values)
    List.of(stages.firstWhere((st) => st.stage == s).items),
];

/// `(stage index, item index)` of [itemId] in [lists]; an absent item →
/// NOT_FOUND.
(int, int) locateItem(List<List<PlanItem>> lists, String itemId) {
  for (var s = 0; s < lists.length; s++) {
    final i = lists[s].indexWhere((item) => item.id == itemId);
    if (i >= 0) return (s, i);
  }
  throw const DomainError(ErrorCode.notFound);
}

/// AC-F-010, D-19: the stages of [lists] in the fixed order, each item with
/// its stage and the position 0…n−1.
List<PlanStage> renumberStages(List<List<PlanItem>> lists) => [
  for (final (s, stage) in Stage.values.indexed)
    PlanStage(
      stage: stage,
      items: [
        for (final (p, i) in lists[s].indexed)
          i.copyWith(stage: stage, position: p),
      ],
    ),
];

/// D-16, D-32: «План від ДД.ММ.РРРР ГГ:ХХ» with the local date and time of
/// the save.
String defaultPlanName(DateTime localTime) {
  String two(int v) => v.toString().padLeft(2, '0');
  return 'План від ${two(localTime.day)}.${two(localTime.month)}.'
      '${localTime.year} ${two(localTime.hour)}:${two(localTime.minute)}';
}
