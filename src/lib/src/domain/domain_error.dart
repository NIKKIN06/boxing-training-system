/// Domain error carrying a contract error code (schema `Error`).
library;

import 'enums.dart';

/// Values of `ErrorDetail.constraint`.
///
/// From the examples of spec/openapi.yaml: [minLeMax], [minimum],
/// [totalGreaterThanZero], [dictionaryValue], [invalidJson]. For violations
/// without an identifier in the contract — the name of the violated schema
/// keyword (human decision 13.11.2026, lab 5 stage 10): [required],
/// [minLength], [minItems], [integer], [https], [maximum]. A recommended value outside `[min; max]` is reported as
/// [minLeMax] (chain `min ≤ recommended ≤ max` of `CountRange`).
abstract final class Constraint {
  static const String minLeMax = 'MIN_LE_MAX';
  static const String minimum = 'MINIMUM';
  static const String totalGreaterThanZero = 'TOTAL_GREATER_THAN_ZERO';

  /// Schema keyword `maximum` (group 2: minutes of the target duration > 59;
  /// group 3: a position outside the stage).
  static const String maximum = 'MAXIMUM';

  /// From the contract examples (BDD-032, D-08).
  static const String withinVariantRange = 'WITHIN_VARIANT_RANGE';
  static const String notEditable = 'NOT_EDITABLE';

  /// Schema keywords (group 3): a field of the other mode of the variant
  /// (`additionalProperties: false` of `TimeParameters` /
  /// `RepetitionsParameters`); an empty `PlanItemPatchRequest` (`minProperties: 1`).
  static const String additionalProperties = 'ADDITIONAL_PROPERTIES';
  static const String minProperties = 'MIN_PROPERTIES';
  static const String dictionaryValue = 'DICTIONARY_VALUE';
  static const String invalidJson = 'INVALID_JSON';
  static const String required = 'REQUIRED';
  static const String minLength = 'MIN_LENGTH';
  static const String minItems = 'MIN_ITEMS';
  static const String integer = 'INTEGER';
  static const String https = 'HTTPS';
}

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
