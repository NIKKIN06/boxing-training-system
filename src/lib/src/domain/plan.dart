/// Training plan, open plan and plan items (SRS §4.3.3, §4.3.4, §4.3.6; ADD-002 D-29…D-33).
library;

import 'enums.dart';
import 'exercise.dart';

/// Target duration in hours and minutes (SRS §5.5; schema `TargetDuration`).
final class TargetDuration {
  const TargetDuration({required this.hours, required this.minutes});

  final int hours;
  final int minutes;
}

/// Five generation parameters of REQ-F-005 (ADD-002 D-31; schema `GenerationParameters`).
final class GenerationParameters {
  const GenerationParameters({
    required this.targetDuration,
    required this.level,
    required this.emphasis,
    required this.availableEquipment,
    required this.intensity,
  });

  final TargetDuration targetDuration;
  final String level;
  final String emphasis;
  final List<String> availableEquipment;
  final String intensity;
}

/// Parameters of a plan item (schema `PlanItemParameters`).
sealed class PlanItemParameters {
  const PlanItemParameters({required this.restSeconds});

  final int restSeconds;
}

/// Time-mode parameters (schema `TimeParameters`).
final class TimeParameters extends PlanItemParameters {
  const TimeParameters({
    required this.rounds,
    required this.intervalSeconds,
    required super.restSeconds,
  });

  final int rounds;
  final int intervalSeconds;
}

/// Repetitions-mode parameters (schema `RepetitionsParameters`).
final class RepetitionsParameters extends PlanItemParameters {
  const RepetitionsParameters({
    required this.sets,
    required this.repetitions,
    required super.restSeconds,
    required this.repetitionTimeSeconds,
  });

  final int sets;
  final int repetitions;

  /// Read-only copy of the variant's `e` (D-08).
  final int repetitionTimeSeconds;
}

/// Parameters in a request body (schemas `PlanItemParametersInput`,
/// `ExecutedPlanItemParametersInput`); only fields of the variant mode apply.
final class ParametersInput {
  const ParametersInput({
    this.rounds,
    this.intervalSeconds,
    this.sets,
    this.repetitions,
    this.restSeconds,
  });

  final int? rounds;
  final int? intervalSeconds;
  final int? sets;
  final int? repetitions;
  final int? restSeconds;
}

/// Plan item with copies of the exercise name and variant (SRS §4.5; schema `PlanItem`).
final class PlanItem {
  const PlanItem({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.variant,
    required this.stage,
    required this.position,
    required this.parameters,
    required this.estimatedDurationSeconds,
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final Variant variant;
  final Stage stage;
  final int position;
  final PlanItemParameters parameters;
  final int estimatedDurationSeconds;
}

/// One stage with ordered items (schema `PlanStage`).
final class PlanStage {
  const PlanStage({required this.stage, required this.items});

  final Stage stage;
  final List<PlanItem> items;
}

/// Non-blocking warning (AC-F-010; schema `PlanWarning`).
final class PlanWarning {
  const PlanWarning({
    required this.code,
    this.stage,
    this.itemId,
    this.attribute,
  });

  final PlanWarningCode code;
  final Stage? stage;
  final String? itemId;
  final WarningAttribute? attribute;
}

/// ±10 % bounds of D in seconds, inclusive (SRS §5.6; schema `DurationTolerance`).
final class DurationTolerance {
  const DurationTolerance({required this.minSeconds, required this.maxSeconds});

  final int minSeconds;
  final int maxSeconds;
}

/// Common plan content (schema `Plan`).
final class PlanContent {
  const PlanContent({
    required this.name,
    required this.generationParameters,
    required this.targetDurationSeconds,
    required this.durationTolerance,
    required this.stages,
    required this.estimatedDurationSeconds,
    required this.warnings,
  });

  /// `null` for a generated unsaved plan (ADD-002 D-32).
  final String? name;
  final GenerationParameters generationParameters;
  final int targetDurationSeconds;
  final DurationTolerance durationTolerance;
  final List<PlanStage> stages;
  final int estimatedDurationSeconds;
  final List<PlanWarning> warnings;
}

/// Open plan — working copy kept in memory only (ADD-002 D-29, D-30; schema `OpenPlan`).
final class OpenPlan {
  const OpenPlan({
    required this.id,
    required this.sourcePlanId,
    required this.content,
  });

  final String id;

  /// `null` for a not yet saved generation result.
  final String? sourcePlanId;
  final PlanContent content;
}

/// Saved plan (D-16; schema `SavedPlan`).
final class SavedPlan {
  const SavedPlan({
    required this.id,
    required this.modifiedAt,
    required this.content,
  });

  final String id;

  /// Set on successful save or overwrite (SPEC-GATE v1.1, REV-009).
  final DateTime modifiedAt;
  final PlanContent content;
}

/// Saved plans list entry (schema `TrainingPlanListItem`).
final class SavedPlanSummary {
  const SavedPlanSummary({
    required this.id,
    required this.name,
    required this.modifiedAt,
  });

  final String id;
  final String name;
  final DateTime modifiedAt;
}

/// Body of `addOpenPlanItem` (schema `PlanItemCreateRequest`).
final class PlanItemCreate {
  const PlanItemCreate({
    required this.exerciseId,
    required this.variantId,
    required this.stage,
    required this.parameters,
    this.position,
  });

  final String exerciseId;
  final String variantId;
  final Stage stage;
  final int? position;
  final ParametersInput parameters;
}

/// Body of `replaceOpenPlanItem` (schema `PlanItemReplaceRequest`).
final class PlanItemReplace {
  const PlanItemReplace({
    required this.exerciseId,
    required this.variantId,
    required this.parameters,
  });

  final String exerciseId;
  final String variantId;
  final ParametersInput parameters;
}

/// Body of `updateOpenPlanItem` (schema `PlanItemPatchRequest`).
final class PlanItemPatch {
  const PlanItemPatch({this.parameters, this.stage, this.position});

  final ParametersInput? parameters;
  final Stage? stage;
  final int? position;
}
