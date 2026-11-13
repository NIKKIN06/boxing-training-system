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
