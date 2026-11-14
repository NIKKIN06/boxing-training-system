/// Exercise and execution variant (SRS §4.3.1, §4.3.2; ADD-002 D-33).
library;

import 'enums.dart';

/// Min / max / recommended value of one variable parameter (SRS §5.3, D-08;
/// schemas `CountRange`, `IntervalRange`, `RestRange`).
final class ParameterRange {
  const ParameterRange({
    required this.min,
    required this.max,
    required this.recommended,
  });

  final int min;
  final int max;
  final int recommended;
}

/// SRS §5.3, D-08: the smallest value of rounds, intervals, sets,
/// repetitions and `e`.
const int minCountValue = 1;

/// SRS §5.3: the smallest rest between rounds or sets.
const int minRestSeconds = 0;

/// Mode-specific fields of an execution variant.
sealed class VariantFields {
  const VariantFields({required this.executionMeans, required this.equipment});

  /// Id from the `execution-means` dictionary.
  final String executionMeans;

  /// Ids from the `equipment` dictionary; empty means no equipment.
  final List<String> equipment;

  ExecutionMode get mode;
}

/// Variant fields in the time mode (schema `TimeVariantFields`).
final class TimeVariantFields extends VariantFields {
  const TimeVariantFields({
    required super.executionMeans,
    required super.equipment,
    required this.rounds,
    required this.intervalSeconds,
    required this.restSeconds,
  });

  final ParameterRange rounds;
  final ParameterRange intervalSeconds;
  final ParameterRange restSeconds;

  @override
  ExecutionMode get mode => ExecutionMode.time;
}

/// Variant fields in the repetitions mode (schema `RepetitionsVariantFields`).
final class RepetitionsVariantFields extends VariantFields {
  const RepetitionsVariantFields({
    required super.executionMeans,
    required super.equipment,
    required this.sets,
    required this.repetitions,
    required this.restSeconds,
    required this.repetitionTimeSeconds,
  });

  final ParameterRange sets;
  final ParameterRange repetitions;
  final ParameterRange restSeconds;

  /// Fixed estimated time of one repetition `e`, seconds (D-08).
  final int repetitionTimeSeconds;

  @override
  ExecutionMode get mode => ExecutionMode.repetitions;
}

/// Stored execution variant with an id stable within its exercise (schema `Variant`).
final class Variant {
  const Variant({required this.id, required this.fields});

  final String id;
  final VariantFields fields;
}

/// Variant in a create / update request; without [id] it is a new variant (schema `VariantInput`).
final class VariantInput {
  const VariantInput({required this.fields, this.id});

  final String? id;
  final VariantFields fields;
}

/// Catalog exercise (schema `Exercise`).
final class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.origin,
    required this.type,
    required this.allowedStages,
    required this.allowedLevels,
    required this.allowedIntensities,
    required this.emphases,
    required this.loadCharacter,
    required this.variants,
    required this.videoUrl,
    required this.videoAuthorName,
    required this.authorPageUrl,
    required this.deprecated,
  });

  final String id;
  final String name;
  final String description;
  final Origin origin;
  final ExerciseType type;
  final List<Stage> allowedStages;
  final List<String> allowedLevels;
  final List<String> allowedIntensities;
  final List<String> emphases;
  final LoadCharacter loadCharacter;
  final List<Variant> variants;
  final String? videoUrl;
  final String? videoAuthorName;
  final String? authorPageUrl;

  /// Deprecated initial exercise (D-06).
  final bool deprecated;
}

/// Body of creating or fully replacing a custom exercise (schema `ExerciseInput`).
final class ExerciseInput {
  const ExerciseInput({
    required this.name,
    required this.description,
    required this.type,
    required this.allowedStages,
    required this.allowedLevels,
    required this.allowedIntensities,
    required this.emphases,
    required this.loadCharacter,
    required this.variants,
    this.videoUrl,
    this.videoAuthorName,
    this.authorPageUrl,
  });

  final String name;
  final String description;
  final ExerciseType type;
  final List<Stage> allowedStages;
  final List<String> allowedLevels;
  final List<String> allowedIntensities;
  final List<String> emphases;
  final LoadCharacter loadCharacter;
  final List<VariantInput> variants;
  final String? videoUrl;
  final String? videoAuthorName;
  final String? authorPageUrl;
}

/// Catalog list entry (schema `ExerciseListItem`).
final class ExerciseSummary {
  const ExerciseSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.origin,
  });

  final String id;
  final String name;
  final ExerciseType type;
  final Origin origin;
}

/// Query filters of `listExercises` (REQ-F-003, D-09). An empty list means
/// that the filter is not set.
final class ExerciseFilter {
  const ExerciseFilter({
    this.stages = const [],
    this.types = const [],
    this.levels = const [],
    this.intensities = const [],
    this.emphases = const [],
    this.loadCharacters = const [],
    this.executionMeans = const [],
    this.equipment = const [],
    this.nameContains,
  });

  /// Search by a part of the name (ADD-003 D-36…D-39): the value without
  /// leading and trailing white space; `null` — the search is not applied
  /// (no parameter or an empty value, D-38).
  final String? nameContains;

  final List<Stage> stages;
  final List<ExerciseType> types;
  final List<String> levels;
  final List<String> intensities;
  final List<String> emphases;
  final List<LoadCharacter> loadCharacters;
  final List<String> executionMeans;
  final List<String> equipment;
}
