/// Reader of JSON request bodies with the structural rules of the contract
/// (spec/openapi.yaml, `info.description`).
library;

import 'dart:convert';

import '../domain/domain_error.dart';
import '../domain/enums.dart';
import '../domain/exercise.dart';
import '../domain/exercise_json.dart';

/// Reads a JSON request body by field paths (`variants[0].rounds.min`, the
/// convention of the contract examples).
///
/// A wrong JSON type stops reading with 400 BAD_REQUEST; missing required
/// fields, non-integer numbers and values outside enumerations are collected
/// and reported together by [throwIfInvalid] as 422 VALIDATION_FAILED.
final class BodyReader {
  BodyReader(String body) : root = _parse(body);

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

  /// A required field of any shape, read by [read] with its path.
  T? field<T>(
    JsonMap o,
    String key,
    T? Function(Object? value, String path) read, {
    String parent = '',
  }) {
    final (present, value) = _field(o, key, parent, true);
    if (!present) return null;
    return read(value, _path(parent, key));
  }

  /// An optional integer; `present` tells whether the key was given.
  (bool, int?) optionalInteger(JsonMap o, String key, {String parent = ''}) {
    final (present, value) = _field(o, key, parent, false);
    if (!present) return (false, null);
    return (true, _integer(value, _path(parent, key)));
  }

  /// Schema `minimum`: reports [value] below [minimum] under [path].
  void atLeast(int? value, int minimum, String path) {
    if (value != null && value < minimum) _issue(path, Constraint.minimum);
  }

  void issue(String field, String constraint) => _issue(field, constraint);

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
