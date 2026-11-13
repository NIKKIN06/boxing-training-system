/// Domain rules of a custom exercise (AC-F-002, AC-F-004; SRS §4.3.1, §4.3.2,
/// §5.3; D-07, D-08). Structural rules of the body (required fields, JSON
/// types, integers, enumerations) are checked while decoding the request.
library;

import 'domain_error.dart';
import 'exercise.dart';

/// Violations of [input]; empty when the exercise may be saved.
List<ErrorDetail> validateExerciseInput(ExerciseInput input) {
  final details = <ErrorDetail>[];
  void add(String field, String constraint) =>
      details.add(ErrorDetail(field: field, constraint: constraint));

  // Schema `ExerciseInput`: name and description `minLength: 1`.
  if (input.name.isEmpty) add('name', Constraint.minLength);
  if (input.description.isEmpty) add('description', Constraint.minLength);

  // Schema `ExerciseInput.variants`: `minItems: 1`.
  if (input.variants.isEmpty) add('variants', Constraint.minItems);

  for (var i = 0; i < input.variants.length; i++) {
    final path = 'variants[$i]';
    switch (input.variants[i].fields) {
      case final TimeVariantFields f:
        // SRS §5.3: rounds and interval are positive, rest is non-negative.
        _range(details, '$path.rounds', f.rounds, 1);
        _range(details, '$path.intervalSeconds', f.intervalSeconds, 1);
        _range(details, '$path.restSeconds', f.restSeconds, 0);
      case final RepetitionsVariantFields f:
        // SRS §5.3, D-08: sets, repetitions and `e` are positive.
        _range(details, '$path.sets', f.sets, 1);
        _range(details, '$path.repetitions', f.repetitions, 1);
        _range(details, '$path.restSeconds', f.restSeconds, 0);
        if (f.repetitionTimeSeconds < 1) {
          add('$path.repetitionTimeSeconds', Constraint.minimum);
        }
    }
  }

  // AC-F-004: links are HTTPS; any combination of video fields is allowed (D-07).
  if (!_isHttpsUrl(input.videoUrl)) add('videoUrl', Constraint.https);
  if (!_isHttpsUrl(input.authorPageUrl)) add('authorPageUrl', Constraint.https);
  return details;
}

/// SRS §5.3, D-08: every value is at least [minimum]; `min ≤ max`;
/// `min ≤ recommended ≤ max`.
void _range(
  List<ErrorDetail> details,
  String path,
  ParameterRange range,
  int minimum,
) {
  final values = {
    'min': range.min,
    'max': range.max,
    'recommended': range.recommended,
  };
  var belowMinimum = false;
  values.forEach((key, value) {
    if (value < minimum) {
      belowMinimum = true;
      details.add(ErrorDetail(field: '$path.$key', constraint: Constraint.minimum));
    }
  });
  if (belowMinimum) return;
  if (range.min > range.max) {
    details.add(ErrorDetail(field: '$path.min', constraint: Constraint.minLeMax));
  } else if (range.recommended < range.min || range.recommended > range.max) {
    details.add(
      ErrorDetail(field: '$path.recommended', constraint: Constraint.minLeMax),
    );
  }
}

/// `null` (absent link) or an absolute `https://` URI with a host
/// (schema: `format: uri`, `pattern: '^https://'`).
bool _isHttpsUrl(String? value) {
  if (value == null) return true;
  if (!value.startsWith('https://')) return false;
  final uri = Uri.tryParse(value);
  return uri != null && uri.host.isNotEmpty;
}
