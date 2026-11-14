/// Decoding of HTTP requests into domain types (spec/openapi.yaml).
///
/// Decoding includes the structural rules of the contract (`info.description`):
/// - 400 BAD_REQUEST — malformed JSON or a wrong JSON type of a field;
/// - 422 VALIDATION_FAILED — a missing required field, a non-integer number
///   where an integer is expected, a value outside an enumeration;
/// - 422 UNKNOWN_DICTIONARY_VALUE — a filter value outside an enumeration.
/// Domain rules (ranges, links, non-empty names) are checked by the services.
library;

import '../domain/domain_error.dart';
import '../domain/enums.dart';
import '../domain/exercise.dart';
import '../domain/exercise_json.dart';
import '../domain/plan.dart';
import '../domain/training.dart';
import 'body_reader.dart';

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
      nameContains: _nameContains(query['nameContains']),
    );
    if (details.isNotEmpty) {
      throw DomainError(ErrorCode.unknownDictionaryValue, details: details);
    }
    return filter;
  }

  /// `nameContains` (ADD-003 D-38): leading and trailing Unicode White_Space
  /// is dropped; an empty result means no search. The length is not limited.
  /// A repeated parameter is not defined by the contract (Q-ADD3-01,
  /// deferred); the first value is used.
  static String? _nameContains(List<String>? values) {
    if (values == null || values.isEmpty) return null;
    final value = values.first;
    var start = 0;
    var end = value.length;
    while (start < end && _isWhiteSpace(value.codeUnitAt(start))) {
      start++;
    }
    while (end > start && _isWhiteSpace(value.codeUnitAt(end - 1))) {
      end--;
    }
    return start == end ? null : value.substring(start, end);
  }

  /// Unicode property White_Space (all its code points are in the BMP).
  /// Unlike `String.trim`, U+FEFF is not white space.
  static bool _isWhiteSpace(int c) =>
      (c >= 0x0009 && c <= 0x000D) ||
      c == 0x0020 ||
      c == 0x0085 ||
      c == 0x00A0 ||
      c == 0x1680 ||
      (c >= 0x2000 && c <= 0x200A) ||
      c == 0x2028 ||
      c == 0x2029 ||
      c == 0x202F ||
      c == 0x205F ||
      c == 0x3000;

  /// Body `ExerciseInput` of `createExercise` / `updateExercise`. `id`,
  /// `origin` and `deprecated` in the body are ignored (D-05).
  ExerciseInput exerciseInput(String body) {
    final r = BodyReader(body);
    final input = r.object(r.root, '', (o) {
      final variants = r.list(
        o,
        'variants',
        (item, path) => _variant(r, item, path),
      );
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

  /// One item of `ExerciseInput.variants` (schema `VariantInput`).
  static VariantInput? _variant(BodyReader r, Object? item, String path) {
    return r.object(item, path, (v) {
      final mode = r.enumValue(v, 'mode', ExecutionMode.values, parent: path);
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
  }

  static TimeVariantFields? _timeFields(
    BodyReader r,
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
    BodyReader r,
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

  /// Body `PlanGenerationRequest` (REQ-F-005, ADD-002 D-31). Values of the
  /// dictionaries are not checked here (stage 7, question 6: deferred).
  GenerationParameters generationParameters(String body) {
    final r = BodyReader(body);
    final params = r.object(r.root, '', (o) {
      final duration = r.field(o, 'targetDuration', (value, path) {
        return r.object(value, path, (t) {
          final hours = r.integer(t, 'hours', parent: path);
          final minutes = r.integer(t, 'minutes', parent: path);
          if (hours == null || minutes == null) return null;
          return TargetDuration(hours: hours, minutes: minutes);
        });
      });
      final level = r.string(o, 'level');
      final emphasis = r.string(o, 'emphasis');
      final equipment = r.list(o, 'availableEquipment', r.stringItem);
      final intensity = r.string(o, 'intensity');
      if (duration == null ||
          level == null ||
          emphasis == null ||
          equipment == null ||
          intensity == null) {
        return null;
      }
      return GenerationParameters(
        targetDuration: duration,
        level: level,
        emphasis: emphasis,
        availableEquipment: equipment.nonNulls.toList(),
        intensity: intensity,
      );
    });
    r.throwIfInvalid();
    return params!;
  }

  /// `OpenSavedPlanRequest.sourcePlanId`.
  String sourcePlanId(String body) => _requiredString(body, 'sourcePlanId');

  /// `OpenPlanPatchRequest.name`; an empty string is allowed (D-16).
  String planName(String body) => _requiredString(body, 'name');

  /// `SavePlanRequest.openPlanId` / `StartSessionRequest.openPlanId`.
  String openPlanId(String body) => _requiredString(body, 'openPlanId');

  /// A body with one required string field. Its absence is answered with
  /// 400 BAD_REQUEST: the 422 responses of these operations are reserved
  /// for other codes (OPEN_PLAN_NOT_FOUND, PLAN_EMPTY, PLAN_NOT_FOUND), and
  /// renameOpenPlan declares no 422 (stage 7, decision on question 7: only
  /// statuses and codes declared for the operation).
  static String _requiredString(String body, String key) {
    final r = BodyReader(body);
    return r.object(r.root, '', (o) {
      if (!o.containsKey(key)) throw const DomainError(ErrorCode.badRequest);
      return r.string(o, key);
    })!;
  }

  /// Body `PlanItemCreateRequest` (AC-F-010, D-08, D-33).
  PlanItemCreate planItemCreate(String body) {
    final r = BodyReader(body);
    final item = r.object(r.root, '', (o) {
      final exerciseId = r.string(o, 'exerciseId');
      final variantId = r.string(o, 'variantId');
      final stage = r.enumValue(o, 'stage', Stage.values);
      final (_, position) = r.optionalInteger(o, 'position');
      r.atLeast(position, _minPosition, 'position');
      final parameters = r.field(o, 'parameters', (v, p) => _itemParameters(r, v, p));
      if (exerciseId == null ||
          variantId == null ||
          stage == null ||
          parameters == null) {
        return null;
      }
      return PlanItemCreate(
        exerciseId: exerciseId,
        variantId: variantId,
        stage: stage,
        position: position,
        parameters: parameters,
      );
    });
    r.throwIfInvalid();
    return item!;
  }

  /// Body `PlanItemReplaceRequest` (AC-F-010, D-08, D-33).
  PlanItemReplace planItemReplace(String body) {
    final r = BodyReader(body);
    final item = r.object(r.root, '', (o) {
      final exerciseId = r.string(o, 'exerciseId');
      final variantId = r.string(o, 'variantId');
      final parameters = r.field(o, 'parameters', (v, p) => _itemParameters(r, v, p));
      if (exerciseId == null || variantId == null || parameters == null) {
        return null;
      }
      return PlanItemReplace(
        exerciseId: exerciseId,
        variantId: variantId,
        parameters: parameters,
      );
    });
    r.throwIfInvalid();
    return item!;
  }

  /// Body `PlanItemPatchRequest`: at least one of `parameters`, `stage`,
  /// `position` (`minProperties: 1`; an empty body → 422).
  PlanItemPatch planItemPatch(String body) {
    final r = BodyReader(body);
    final patch = r.object(r.root, '', (o) {
      if (!o.containsKey('parameters') &&
          !o.containsKey('stage') &&
          !o.containsKey('position')) {
        r.issue('body', Constraint.minProperties);
        return null;
      }
      final parameters = o.containsKey('parameters')
          ? r.field(o, 'parameters', (v, p) => _itemParameters(r, v, p))
          : null;
      final stage = o.containsKey('stage')
          ? r.enumValue(o, 'stage', Stage.values)
          : null;
      final (_, position) = r.optionalInteger(o, 'position');
      r.atLeast(position, _minPosition, 'position');
      return PlanItemPatch(
        parameters: parameters,
        stage: stage,
        position: position,
      );
    });
    r.throwIfInvalid();
    return patch!;
  }

  /// `PlanItemParametersInput`: integers of the known fields;
  /// `repetitionTimeSeconds` is not accepted (D-08, NOT_EDITABLE). The mode
  /// and the variant limits are checked by the service.
  static ParametersInput? _itemParameters(
    BodyReader r,
    Object? value,
    String path,
  ) {
    return r.object(value, path, (m) {
      if (m.containsKey('repetitionTimeSeconds')) {
        r.issue('$path.repetitionTimeSeconds', Constraint.notEditable);
      }
      int? read(String key) => r.optionalInteger(m, key, parent: path).$2;
      return ParametersInput(
        rounds: read('rounds'),
        intervalSeconds: read('intervalSeconds'),
        sets: read('sets'),
        repetitions: read('repetitions'),
        restSeconds: read('restSeconds'),
      );
    });
  }

  /// `ExecutedPlanItemPatchRequest.parameters` (D-19): fields outside the
  /// list (`stage`, `position`, …) → 422 ADDITIONAL_PROPERTIES;
  /// `repetitionTimeSeconds` → 422 NOT_EDITABLE (D-08).
  ParametersInput executedItemParameters(String body) {
    final r = BodyReader(body);
    final parameters = r.object(r.root, '', (o) {
      for (final key in o.keys) {
        if (key != 'parameters') r.issue(key, Constraint.additionalProperties);
      }
      return r.field(o, 'parameters', (v, p) => _itemParameters(r, v, p));
    });
    r.throwIfInvalid();
    return parameters!;
  }

  /// `CompleteTrainingRequest.note`; the body is optional, an absent body,
  /// an absent note or `null` mean no note (AC-F-013, POS-31).
  String? trainingNote(String body) {
    if (body.isEmpty) return null;
    final r = BodyReader(body);
    return r.object(r.root, '', (o) => r.string(o, 'note', required: false));
  }

  /// Query parameters `from` / `to` of `getAnalytics` (ADD-002 D-35),
  /// `format: date`. A value that is not a valid `YYYY-MM-DD` date → 400
  /// BAD_REQUEST (stage 7, decision on question 7: a status declared for the
  /// operation). The rules of the period are checked by the service.
  ({LocalDate? from, LocalDate? to}) analyticsPeriod(
    Map<String, List<String>> query,
  ) {
    LocalDate? date(String name) {
      final values = query[name];
      if (values == null || values.isEmpty) return null;
      final raw = values.first;
      final m = _datePattern.firstMatch(raw);
      if (m == null) throw const DomainError(ErrorCode.badRequest);
      final d = LocalDate(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
      final check = DateTime.utc(d.year, d.month, d.day);
      if (check.month != d.month || check.day != d.day) {
        throw const DomainError(ErrorCode.badRequest);
      }
      return d;
    }

    return (from: date('from'), to: date('to'));
  }

  /// `format: date` — `YYYY-MM-DD`.
  static final RegExp _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  /// Schema `minimum: 0` of `position`.
  static const int _minPosition = 0;
}
