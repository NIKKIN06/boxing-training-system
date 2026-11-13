/// Mapping between HTTP messages and domain types (spec/openapi.yaml).
///
/// Decoding includes the structural rules of the contract (`info.description`):
/// - 400 BAD_REQUEST — malformed JSON or a wrong JSON type of a field;
/// - 422 VALIDATION_FAILED — a missing required field, a non-integer number
///   where an integer is expected, a value outside an enumeration;
/// - 422 UNKNOWN_DICTIONARY_VALUE — a filter value outside an enumeration.
/// Domain rules (ranges, links, non-empty names) are checked by the services.
/// Operations of later groups still throw [UnimplementedError].
library;

import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../domain/catalog.dart';
import '../domain/domain_error.dart';
import '../domain/enums.dart';
import '../domain/exercise.dart';
import '../domain/exercise_json.dart';
import '../domain/plan.dart';
import '../domain/training.dart';

/// Request query and body decoding.
final class RequestDecoder {
  const RequestDecoder();

  /// Query of `listExercises` (REQ-F-003, D-09): repeated parameters,
  /// `style: form, explode: true`. Unknown parameter names are ignored.
  ExerciseFilter exerciseFilter(Map<String, List<String>> query) {
    final details = <ErrorDetail>[];
    List<T> enums<T extends WireEnum>(String name, List<T> values) {
      final result = <T>[];
      for (final raw in query[name] ?? const <String>[]) {
        final value = fromWire(values, raw);
        if (value == null) {
          details.add(
            ErrorDetail(field: name, constraint: Constraint.dictionaryValue),
          );
          return const [];
        }
        result.add(value);
      }
      return result;
    }

    final filter = ExerciseFilter(
      stages: enums('stage', Stage.values),
      types: enums('type', ExerciseType.values),
      loadCharacters: enums('loadCharacter', LoadCharacter.values),
      levels: query['level'] ?? const [],
      intensities: query['intensity'] ?? const [],
      emphases: query['emphasis'] ?? const [],
      executionMeans: query['executionMeans'] ?? const [],
      equipment: query['equipment'] ?? const [],
    );
    if (details.isNotEmpty) {
      throw DomainError(ErrorCode.unknownDictionaryValue, details: details);
    }
    return filter;
  }

  /// Body `ExerciseInput` of `createExercise` / `updateExercise`. `id`,
  /// `origin` and `deprecated` in the body are ignored (D-05).
  ExerciseInput exerciseInput(String body) {
    final r = _BodyReader(body);
    final input = r.object(r.root, '', (o) {
      final variants = r.list(o, 'variants', (item, path) {
        return r.object(item, path, (v) {
          final mode = r.enumValue(
            v,
            'mode',
            ExecutionMode.values,
            parent: path,
          );
          final means = r.string(v, 'executionMeans', parent: path);
          final equipment = r.list(v, 'equipment', r.stringItem, parent: path);
          final VariantFields? fields = switch (mode) {
            null => null,
            ExecutionMode.time => _timeFields(r, v, path, means, equipment),
            ExecutionMode.repetitions => _repetitionFields(
              r,
              v,
              path,
              means,
              equipment,
            ),
          };
          final id = r.string(v, 'id', parent: path, required: false);
          return fields == null ? null : VariantInput(id: id, fields: fields);
        });
      });
      final name = r.string(o, 'name');
      final description = r.string(o, 'description');
      final type = r.enumValue(o, 'type', ExerciseType.values);
      final stages = r.list(
        o,
        'allowedStages',
        (item, path) => r.enumItem(item, path, Stage.values),
      );
      final levels = r.list(o, 'allowedLevels', r.stringItem);
      final intensities = r.list(o, 'allowedIntensities', r.stringItem);
      final emphases = r.list(o, 'emphases', r.stringItem);
      final load = r.enumValue(o, 'loadCharacter', LoadCharacter.values);
      final videoUrl = r.string(o, 'videoUrl', required: false);
      final videoAuthorName = r.string(o, 'videoAuthorName', required: false);
      final authorPageUrl = r.string(o, 'authorPageUrl', required: false);
      if (name == null ||
          description == null ||
          type == null ||
          stages == null ||
          levels == null ||
          intensities == null ||
          emphases == null ||
          load == null ||
          variants == null) {
        return null;
      }
      return ExerciseInput(
        name: name,
        description: description,
        type: type,
        allowedStages: stages.nonNulls.toList(),
        allowedLevels: levels.nonNulls.toList(),
        allowedIntensities: intensities.nonNulls.toList(),
        emphases: emphases.nonNulls.toList(),
        loadCharacter: load,
        variants: variants.nonNulls.toList(),
        videoUrl: videoUrl,
        videoAuthorName: videoAuthorName,
        authorPageUrl: authorPageUrl,
      );
    });
    r.throwIfInvalid();
    return input!;
  }

  static TimeVariantFields? _timeFields(
    _BodyReader r,
    JsonMap v,
    String path,
    String? means,
    List<String?>? equipment,
  ) {
    final rounds = r.range(v, 'rounds', parent: path);
    final interval = r.range(v, 'intervalSeconds', parent: path);
    final rest = r.range(v, 'restSeconds', parent: path);
    if (means == null ||
        equipment == null ||
        rounds == null ||
        interval == null ||
        rest == null) {
      return null;
    }
    return TimeVariantFields(
      executionMeans: means,
      equipment: equipment.nonNulls.toList(),
      rounds: rounds,
      intervalSeconds: interval,
      restSeconds: rest,
    );
  }

  static RepetitionsVariantFields? _repetitionFields(
    _BodyReader r,
    JsonMap v,
    String path,
    String? means,
    List<String?>? equipment,
  ) {
    final sets = r.range(v, 'sets', parent: path);
    final repetitions = r.range(v, 'repetitions', parent: path);
    final rest = r.range(v, 'restSeconds', parent: path);
    final e = r.integer(v, 'repetitionTimeSeconds', parent: path);
    if (means == null ||
        equipment == null ||
        sets == null ||
        repetitions == null ||
        rest == null ||
        e == null) {
      return null;
    }
    return RepetitionsVariantFields(
      executionMeans: means,
      equipment: equipment.nonNulls.toList(),
      sets: sets,
      repetitions: repetitions,
      restSeconds: rest,
      repetitionTimeSeconds: e,
    );
  }

  /// Path parameter `dictionaryName`; a name outside the enumeration is a
  /// dictionary that does not exist → 404 NOT_FOUND (the only error declared
  /// for `getDictionary`; stage 7, decision on question 7).
  DictionaryName dictionaryName(String raw) {
    final name = fromWire(DictionaryName.values, raw);
    if (name == null) throw const DomainError(ErrorCode.notFound);
    return name;
  }

  GenerationParameters generationParameters(String body) =>
      throw UnimplementedError('decode PlanGenerationRequest');

  /// `OpenSavedPlanRequest.sourcePlanId`.
  String sourcePlanId(String body) =>
      throw UnimplementedError('decode OpenSavedPlanRequest');

  /// `OpenPlanPatchRequest.name`.
  String planName(String body) =>
      throw UnimplementedError('decode OpenPlanPatchRequest');

  PlanItemCreate planItemCreate(String body) =>
      throw UnimplementedError('decode PlanItemCreateRequest');

  PlanItemReplace planItemReplace(String body) =>
      throw UnimplementedError('decode PlanItemReplaceRequest');

  PlanItemPatch planItemPatch(String body) =>
      throw UnimplementedError('decode PlanItemPatchRequest');

  /// `SavePlanRequest.openPlanId` / `StartSessionRequest.openPlanId`.
  String openPlanId(String body) =>
      throw UnimplementedError('decode openPlanId request');

  /// `ExecutedPlanItemPatchRequest.parameters`.
  ParametersInput executedItemParameters(String body) =>
      throw UnimplementedError('decode ExecutedPlanItemPatchRequest');

  /// `CompleteTrainingRequest.note`.
  String? trainingNote(String body) =>
      throw UnimplementedError('decode CompleteTrainingRequest');

  /// Query parameters `from` / `to` of `getAnalytics` (ADD-002 D-35).
  ({LocalDate? from, LocalDate? to}) analyticsPeriod(
    Map<String, List<String>> query,
  ) => throw UnimplementedError('decode analytics period');
}

/// Success responses with status codes and `Location` headers of the contract.
final class ResponseEncoder {
  const ResponseEncoder();

  Response exerciseList(List<ExerciseSummary> items) => jsonResponse(200, {
    'items': [
      for (final e in items)
        {
          'id': e.id,
          'name': e.name,
          'type': e.type.wire,
          'origin': e.origin.wire,
        },
    ],
  });

  Response exerciseCreated(Exercise exercise) => jsonResponse(
    201,
    exerciseToJson(exercise),
    location: '/exercises/${Uri.encodeComponent(exercise.id)}',
  );

  Response exercise(Exercise exercise) =>
      jsonResponse(200, exerciseToJson(exercise));

  Response dictionary(Dictionary dictionary) =>
      jsonResponse(200, dictionaryToJson(dictionary));

  Response openPlanCreated(OpenPlan plan) =>
      throw UnimplementedError('encode OpenPlan (201)');

  Response openPlanItemCreated(OpenPlan plan) =>
      throw UnimplementedError('encode OpenPlan after addOpenPlanItem (201)');

  Response openPlan(OpenPlan plan) =>
      throw UnimplementedError('encode OpenPlan');

  Response trainingPlanList(List<SavedPlanSummary> items) =>
      throw UnimplementedError('encode TrainingPlanList');

  Response savedPlanCreated(SavedPlan plan) =>
      throw UnimplementedError('encode SavedPlan (201)');

  Response savedPlan(SavedPlan plan) =>
      throw UnimplementedError('encode SavedPlan');

  Response currentSessionCreated(CurrentSession session) =>
      throw UnimplementedError('encode CurrentSession (201)');

  Response currentSession(CurrentSession session) =>
      throw UnimplementedError('encode CurrentSession');

  Response completedTrainingCreated(CompletedTraining training) =>
      throw UnimplementedError('encode CompletedTraining (201)');

  Response completedTraining(CompletedTraining training) =>
      throw UnimplementedError('encode CompletedTraining');

  Response completedTrainingList(List<CompletedTrainingSummary> items) =>
      throw UnimplementedError('encode CompletedTrainingList');

  Response analytics(Analytics analytics) =>
      throw UnimplementedError('encode Analytics');

  /// 204 No Content.
  Response noContent() => throw UnimplementedError('encode 204');
}

/// A JSON response; [location] is the URI of a created resource (201).
Response jsonResponse(int status, Object? body, {String? location}) => Response(
  status,
  body: jsonEncode(body),
  headers: {
    'content-type': 'application/json; charset=utf-8',
    'location': ?location,
  },
);

/// HTTP status of an error code as declared in spec/openapi.yaml for the
/// operations implemented so far; `null` for codes of later groups.
int? errorStatus(ErrorCode code) => switch (code) {
  ErrorCode.badRequest => 400,
  ErrorCode.initialExerciseReadOnly => 403,
  ErrorCode.notFound => 404,
  ErrorCode.validationFailed || ErrorCode.unknownDictionaryValue => 422,
  ErrorCode.storageWriteFailed => 500,
  _ => null,
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

/// Reads a JSON request body by field paths (`variants[0].rounds.min`, the
/// convention of the contract examples).
///
/// A wrong JSON type stops reading with 400 BAD_REQUEST; missing required
/// fields, non-integer numbers and values outside enumerations are collected
/// and reported together by [throwIfInvalid] as 422 VALIDATION_FAILED.
final class _BodyReader {
  _BodyReader(String body) : root = _parse(body);

  final Object? root;
  final List<ErrorDetail> _details = [];

  static Object? _parse(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const DomainError(
        ErrorCode.badRequest,
        details: [
          ErrorDetail(field: 'body', constraint: Constraint.invalidJson),
        ],
      );
    }
  }

  static String _path(String parent, String key) =>
      parent.isEmpty ? key : '$parent.$key';

  static Never _wrongType() => throw const DomainError(ErrorCode.badRequest);

  void _issue(String field, String constraint) =>
      _details.add(ErrorDetail(field: field, constraint: constraint));

  /// `(present, value)` of [key]; an absent required key is reported.
  (bool, Object?) _field(JsonMap o, String key, String parent, bool required) {
    if (o.containsKey(key)) return (true, o[key]);
    if (required) _issue(_path(parent, key), Constraint.required);
    return (false, null);
  }

  void throwIfInvalid() {
    if (_details.isNotEmpty) {
      throw DomainError(ErrorCode.validationFailed, details: List.of(_details));
    }
  }

  T? object<T>(Object? value, String path, T? Function(JsonMap) read) {
    if (value is! Map<String, Object?>) _wrongType();
    return read(value);
  }

  /// A required string, or with `required: false` an optional nullable one.
  String? string(
    JsonMap o,
    String key, {
    String parent = '',
    bool required = true,
  }) {
    final (present, value) = _field(o, key, parent, required);
    if (!present || (value == null && !required)) return null;
    if (value is! String) _wrongType();
    return value;
  }

  int? integer(JsonMap o, String key, {String parent = ''}) {
    final (present, value) = _field(o, key, parent, true);
    if (!present) return null;
    return _integer(value, _path(parent, key));
  }

  int? _integer(Object? value, String path) {
    if (value is int) return value;
    if (value is! num) _wrongType();
    // `info.description`: a non-integer where an integer is expected → 422.
    if (value != value.truncateToDouble()) {
      _issue(path, Constraint.integer);
      return null;
    }
    return value.toInt();
  }

  /// `CountRange` / `IntervalRange` / `RestRange`.
  ParameterRange? range(JsonMap o, String key, {String parent = ''}) {
    final (present, value) = _field(o, key, parent, true);
    if (!present) return null;
    final path = _path(parent, key);
    return object(value, path, (m) {
      final min = integer(m, 'min', parent: path);
      final max = integer(m, 'max', parent: path);
      final recommended = integer(m, 'recommended', parent: path);
      if (min == null || max == null || recommended == null) return null;
      return ParameterRange(min: min, max: max, recommended: recommended);
    });
  }

  T? enumValue<T extends WireEnum>(
    JsonMap o,
    String key,
    List<T> values, {
    String parent = '',
  }) {
    final (present, value) = _field(o, key, parent, true);
    if (!present) return null;
    return enumItem(value, _path(parent, key), values);
  }

  T? enumItem<T extends WireEnum>(Object? item, String path, List<T> values) {
    if (item is! String) _wrongType();
    final value = fromWire(values, item);
    if (value == null) _issue(path, Constraint.dictionaryValue);
    return value;
  }

  String stringItem(Object? item, String path) {
    if (item is! String) _wrongType();
    return item;
  }

  List<T?>? list<T>(
    JsonMap o,
    String key,
    T? Function(Object? item, String path) readItem, {
    String parent = '',
  }) {
    final (present, value) = _field(o, key, parent, true);
    if (!present) return null;
    if (value is! List<Object?>) _wrongType();
    final path = _path(parent, key);
    return [
      for (var i = 0; i < value.length; i++) readItem(value[i], '$path[$i]'),
    ];
  }
}
