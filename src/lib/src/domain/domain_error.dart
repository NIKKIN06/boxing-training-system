/// Domain error carrying a contract error code (schema `Error`).
library;

import 'enums.dart';

/// Violated rule of one field (schema `ErrorDetail`).
final class ErrorDetail {
  const ErrorDetail({required this.field, required this.constraint});

  final String field;
  final String constraint;
}

/// Reason of a proven impossibility (schema `ImpossibilityReason`).
final class ImpossibilityReason {
  const ImpossibilityReason({required this.code, this.stage});

  final ImpossibilityReasonCode code;
  final Stage? stage;
}

/// Error raised by services and mapped by the HTTP layer to a contract response.
final class DomainError implements Exception {
  const DomainError(
    this.code, {
    this.details = const [],
    this.reasons = const [],
    this.limitSeconds,
  });

  final ErrorCode code;
  final List<ErrorDetail> details;
  final List<ImpossibilityReason> reasons;
  final int? limitSeconds;

  @override
  String toString() => 'DomainError(${code.wire})';
}
