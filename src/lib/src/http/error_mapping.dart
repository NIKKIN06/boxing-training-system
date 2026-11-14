/// Mapping of domain errors to contract responses (spec/openapi.yaml,
/// schema `Error`; stage 1, decision 7: only codes of the contract).
library;

import '../domain/domain_error.dart';
import '../domain/enums.dart';
import '../domain/exercise_json.dart';

/// The only operation that answers NO_CURRENT_SESSION with 409.
const String _noCurrentSessionConflictOperation = 'completeTraining';

/// HTTP status of an error code of [operationId] as declared in
/// spec/openapi.yaml for every code of `Error.code`. NO_CURRENT_SESSION is
/// 409 for completeTraining (`NoCurrentSessionConflict`) and 404 elsewhere.
int errorStatus(ErrorCode code, String operationId) => switch (code) {
  ErrorCode.noCurrentSession =>
    operationId == _noCurrentSessionConflictOperation ? 409 : 404,
  ErrorCode.sessionAlreadyActive => 409,
  ErrorCode.executedPlanEmpty ||
  ErrorCode.invalidPeriod ||
  ErrorCode.endDateInFuture => 422,
  ErrorCode.badRequest => 400,
  ErrorCode.initialExerciseReadOnly => 403,
  ErrorCode.notFound => 404,
  ErrorCode.validationFailed ||
  ErrorCode.unknownDictionaryValue ||
  ErrorCode.planGenerationImpossible ||
  ErrorCode.exerciseNotFound ||
  ErrorCode.variantNotFound ||
  ErrorCode.exerciseDeprecated ||
  ErrorCode.planNotFound ||
  ErrorCode.openPlanNotFound ||
  ErrorCode.planEmpty => 422,
  ErrorCode.openPlanAlreadySaved || ErrorCode.openPlanSourceMismatch => 409,
  ErrorCode.storageWriteFailed || ErrorCode.generationFailed => 500,
  ErrorCode.generationSearchLimitReached => 503,
};

/// Body of the `Error` schema.
JsonMap errorBody(DomainError error) => {
  'code': error.code.wire,
  if (error.details.isNotEmpty)
    'details': [
      for (final d in error.details)
        {'field': d.field, 'constraint': d.constraint},
    ],
  if (error.reasons.isNotEmpty)
    'reasons': [
      for (final r in error.reasons)
        {'code': r.code.wire, 'stage': ?r.stage?.wire},
    ],
  'limitSeconds': ?error.limitSeconds,
};
