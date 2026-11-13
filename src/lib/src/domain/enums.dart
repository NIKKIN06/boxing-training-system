/// Closed value sets of spec/openapi.yaml (components/schemas). Each value keeps
/// its wire representation from the contract.
library;

/// Training stage; fixed order warm-up, main, cool-down (SRS §3, §5.2; schema `Stage`).
enum Stage {
  warmUp('warm-up'),
  main('main'),
  coolDown('cool-down');

  const Stage(this.wire);
  final String wire;
}

/// Exercise type (SRS §3; schema `ExerciseType`).
enum ExerciseType {
  simple('simple'),
  singlePunch('single-punch'),
  combination('combination');

  const ExerciseType(this.wire);
  final String wire;
}

/// Exercise origin (SRS §4.3.1; schema `Origin`).
enum Origin {
  initial('initial'),
  custom('custom');

  const Origin(this.wire);
  final String wire;
}

/// Load character, one value per exercise (SRS §3, ADD-002 D-34; schema `LoadCharacter`).
enum LoadCharacter {
  generalPhysical('general-physical'),
  specialPhysical('special-physical'),
  notApplicable('not-applicable');

  const LoadCharacter(this.wire);
  final String wire;
}

/// Execution mode of a variant (SRS §4.3.2; schema `Mode`).
enum ExecutionMode {
  time('time'),
  repetitions('repetitions');

  const ExecutionMode(this.wire);
  final String wire;
}

/// Shared dictionary name (SRS §4.4; schema `DictionaryName`).
enum DictionaryName {
  trainingLevels('training-levels'),
  intensities('intensities'),
  emphases('emphases'),
  equipment('equipment'),
  executionMeans('execution-means');

  const DictionaryName(this.wire);
  final String wire;
}

/// Machine error code (schema `Error.code`). Only codes from the contract
/// (lab 5, human decision 7 of stage 1).
enum ErrorCode {
  badRequest('BAD_REQUEST'),
  notFound('NOT_FOUND'),
  validationFailed('VALIDATION_FAILED'),
  unknownDictionaryValue('UNKNOWN_DICTIONARY_VALUE'),
  initialExerciseReadOnly('INITIAL_EXERCISE_READ_ONLY'),
  storageWriteFailed('STORAGE_WRITE_FAILED'),
  planGenerationImpossible('PLAN_GENERATION_IMPOSSIBLE'),
  generationFailed('GENERATION_FAILED'),
  generationSearchLimitReached('GENERATION_SEARCH_LIMIT_REACHED'),
  planNotFound('PLAN_NOT_FOUND'),
  exerciseNotFound('EXERCISE_NOT_FOUND'),
  variantNotFound('VARIANT_NOT_FOUND'),
  exerciseDeprecated('EXERCISE_DEPRECATED'),
  openPlanAlreadySaved('OPEN_PLAN_ALREADY_SAVED'),
  openPlanNotFound('OPEN_PLAN_NOT_FOUND'),
  planEmpty('PLAN_EMPTY'),
  openPlanSourceMismatch('OPEN_PLAN_SOURCE_MISMATCH'),
  sessionAlreadyActive('SESSION_ALREADY_ACTIVE'),
  noCurrentSession('NO_CURRENT_SESSION'),
  executedPlanEmpty('EXECUTED_PLAN_EMPTY'),
  invalidPeriod('INVALID_PERIOD'),
  endDateInFuture('END_DATE_IN_FUTURE');

  const ErrorCode(this.wire);
  final String wire;
}

/// Non-blocking plan warning code (AC-F-010; schema `PlanWarning.code`).
enum PlanWarningCode {
  durationOutOfTolerance('DURATION_OUT_OF_TOLERANCE'),
  stageEmpty('STAGE_EMPTY'),
  filterMismatch('FILTER_MISMATCH'),
  stageNotInExercise('STAGE_NOT_IN_EXERCISE');

  const PlanWarningCode(this.wire);
  final String wire;
}

/// Generation parameter that a plan item does not match (schema `PlanWarning.attribute`).
enum WarningAttribute {
  level('level'),
  intensity('intensity'),
  availableEquipment('availableEquipment'),
  emphasis('emphasis');

  const WarningAttribute(this.wire);
  final String wire;
}

/// Reason of a proven generation impossibility (schema `ImpossibilityReason.code`).
enum ImpossibilityReasonCode {
  noCandidatesForStage('NO_CANDIDATES_FOR_STAGE'),
  maxVolumeBelowLowerBound('MAX_VOLUME_BELOW_LOWER_BOUND'),
  minVolumeAboveUpperBound('MIN_VOLUME_ABOVE_UPPER_BOUND');

  const ImpossibilityReasonCode(this.wire);
  final String wire;
}
