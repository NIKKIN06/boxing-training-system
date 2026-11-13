/// Wire form of exercises, variants and dictionaries (schemas `Exercise`,
/// `Variant`, `Dictionary` of spec/openapi.yaml).
///
/// Used for trusted data only: the supplied catalog resource (T-57) and
/// stored copies. Requests are decoded with validation by the HTTP layer.
/// A malformed value throws [FormatException].
library;

import 'catalog.dart';
import 'enums.dart';
import 'exercise.dart';

typedef JsonMap = Map<String, Object?>;

JsonMap rangeToJson(ParameterRange range) => {
  'min': range.min,
  'max': range.max,
  'recommended': range.recommended,
};

JsonMap variantFieldsToJson(VariantFields fields) => {
  'executionMeans': fields.executionMeans,
  'equipment': fields.equipment,
  'mode': fields.mode.wire,
  ...switch (fields) {
    TimeVariantFields() => {
      'rounds': rangeToJson(fields.rounds),
      'intervalSeconds': rangeToJson(fields.intervalSeconds),
      'restSeconds': rangeToJson(fields.restSeconds),
    },
    RepetitionsVariantFields() => {
      'sets': rangeToJson(fields.sets),
      'repetitions': rangeToJson(fields.repetitions),
      'restSeconds': rangeToJson(fields.restSeconds),
      'repetitionTimeSeconds': fields.repetitionTimeSeconds,
    },
  },
};

JsonMap variantToJson(Variant variant) => {
  'id': variant.id,
  ...variantFieldsToJson(variant.fields),
};

JsonMap exerciseToJson(Exercise e) => {
  'id': e.id,
  'name': e.name,
  'description': e.description,
  'origin': e.origin.wire,
  'type': e.type.wire,
  'allowedStages': [for (final s in e.allowedStages) s.wire],
  'allowedLevels': e.allowedLevels,
  'allowedIntensities': e.allowedIntensities,
  'emphases': e.emphases,
  'loadCharacter': e.loadCharacter.wire,
  'variants': [for (final v in e.variants) variantToJson(v)],
  'videoUrl': e.videoUrl,
  'videoAuthorName': e.videoAuthorName,
  'authorPageUrl': e.authorPageUrl,
  'deprecated': e.deprecated,
};

JsonMap dictionaryToJson(Dictionary d) => {
  'dictionary': d.name.wire,
  'values': [
    for (final v in d.values) {'id': v.id, 'name': v.name},
  ],
};

T _enum<T extends WireEnum>(List<T> values, Object? raw) {
  final value = raw is String ? fromWire(values, raw) : null;
  if (value == null) throw FormatException('Unknown value', raw);
  return value;
}

JsonMap _map(Object? raw) {
  if (raw is Map<String, Object?>) return raw;
  throw FormatException('Expected an object', raw);
}

List<String> _strings(Object? raw) {
  if (raw is List<Object?>) return [for (final s in raw) s! as String];
  throw FormatException('Expected an array', raw);
}

ParameterRange _range(Object? raw) {
  final m = _map(raw);
  return ParameterRange(
    min: m['min']! as int,
    max: m['max']! as int,
    recommended: m['recommended']! as int,
  );
}

VariantFields variantFieldsFromJson(JsonMap m) {
  final mode = _enum(ExecutionMode.values, m['mode']);
  final means = m['executionMeans']! as String;
  final equipment = _strings(m['equipment']);
  return switch (mode) {
    ExecutionMode.time => TimeVariantFields(
      executionMeans: means,
      equipment: equipment,
      rounds: _range(m['rounds']),
      intervalSeconds: _range(m['intervalSeconds']),
      restSeconds: _range(m['restSeconds']),
    ),
    ExecutionMode.repetitions => RepetitionsVariantFields(
      executionMeans: means,
      equipment: equipment,
      sets: _range(m['sets']),
      repetitions: _range(m['repetitions']),
      restSeconds: _range(m['restSeconds']),
      repetitionTimeSeconds: m['repetitionTimeSeconds']! as int,
    ),
  };
}

Variant variantFromJson(Object? raw) {
  final m = _map(raw);
  return Variant(id: m['id']! as String, fields: variantFieldsFromJson(m));
}

Exercise exerciseFromJson(Object? raw) {
  final m = _map(raw);
  return Exercise(
    id: m['id']! as String,
    name: m['name']! as String,
    description: m['description']! as String,
    origin: _enum(Origin.values, m['origin']),
    type: _enum(ExerciseType.values, m['type']),
    allowedStages: [
      for (final s in _strings(m['allowedStages'])) _enum(Stage.values, s),
    ],
    allowedLevels: _strings(m['allowedLevels']),
    allowedIntensities: _strings(m['allowedIntensities']),
    emphases: _strings(m['emphases']),
    loadCharacter: _enum(LoadCharacter.values, m['loadCharacter']),
    variants: [for (final v in m['variants']! as List<Object?>) variantFromJson(v)],
    videoUrl: m['videoUrl'] as String?,
    videoAuthorName: m['videoAuthorName'] as String?,
    authorPageUrl: m['authorPageUrl'] as String?,
    deprecated: m['deprecated']! as bool,
  );
}

Dictionary dictionaryFromJson(Object? raw) {
  final m = _map(raw);
  return Dictionary(
    name: _enum(DictionaryName.values, m['dictionary']),
    values: [
      for (final v in m['values']! as List<Object?>)
        DictionaryValue(
          id: _map(v)['id']! as String,
          name: _map(v)['name']! as String,
        ),
    ],
  );
}
