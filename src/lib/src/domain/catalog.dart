/// Shared dictionaries and the supplied initial catalog (SRS §4.4; D-01, D-06, D-27).
library;

import 'enums.dart';
import 'exercise.dart';

/// Dictionary value (schema `DictionaryValue`).
final class DictionaryValue {
  const DictionaryValue({required this.id, required this.name});

  final String id;
  final String name;
}

/// Shared local dictionary (schema `Dictionary`).
final class Dictionary {
  const Dictionary({required this.name, required this.values});

  final DictionaryName name;
  final List<DictionaryValue> values;
}

/// Versioned supplied data: dictionaries and initial exercises (SRS §4.4).
final class CatalogData {
  const CatalogData({
    required this.catalogVersion,
    required this.placeholder,
    required this.dictionaries,
    required this.exercises,
  });

  final String catalogVersion;

  /// `true` for `[TEST]` placeholder data (D-01).
  final bool placeholder;
  final List<Dictionary> dictionaries;
  final List<Exercise> exercises;
}
