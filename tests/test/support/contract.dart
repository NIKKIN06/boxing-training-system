/// Contract validator and API client of the tests (spec/openapi.yaml).
///
/// Every response obtained through [ApiClient.send] is checked against the
/// contract before the test sees it:
/// - the status code is declared for the operation;
/// - a body with content is `application/json` and valid against the response
///   schema (OpenAPI 3.0 schemas converted to JSON Schema draft-07);
/// - `201` has a `Location` header that is a URI reference;
/// - `204` (and every response without content in the contract) has an empty body;
/// - `4xx` / `5xx` bodies have `Error.code` from the contract enum.
///
/// Method and path of an operation are taken from the contract by operationId,
/// so the tests do not hard-code routes.
library;

import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'json.dart';

/// Path of the contract relative to the tests package.
const String contractPath = '../spec/openapi.yaml';

const Set<String> _httpMethods = {'get', 'post', 'put', 'patch', 'delete'};

/// One operation of the contract.
final class ContractOperation {
  ContractOperation({
    required this.operationId,
    required this.method,
    required this.pathTemplate,
    required this.tags,
    required this.responseSchemas,
    required this.requestBody,
  });

  final String operationId;
  final String method;
  final String pathTemplate;
  final List<String> tags;

  /// Declared status → schema of the JSON body, `null` for no content.
  final Map<int, JsonSchema?> responseSchemas;

  /// Raw `requestBody` of the operation, `null` when absent.
  final Json? requestBody;

  Iterable<int> get declaredStatuses => responseSchemas.keys;
}

/// The parsed contract.
final class Contract {
  Contract._(this.document, this.operations, this.errorCodes);

  static Contract? _instance;

  /// Loads spec/openapi.yaml once per test isolate.
  static Contract load() => _instance ??= _parse();

  final Json document;
  final Map<String, ContractOperation> operations;

  /// Enum of `Error.code`.
  final Set<String> errorCodes;

  ContractOperation operation(String operationId) {
    final op = operations[operationId];
    if (op == null) {
      fail('operationId $operationId is not in $contractPath');
    }
    return op;
  }

  /// Value of a named example in `components/examples`.
  Object? example(String name) =>
      document['components'].asJson['examples'].asJson[name].asJson['value'];

  static Contract _parse() {
    final yaml = loadYaml(File(contractPath).readAsStringSync());
    final document = (jsonDecode(jsonEncode(yaml)) as Map).cast<String, Object?>();
    final components = document['components'].asJson;
    final definitions = _toJsonSchema(components['schemas']).asJson;
    final responses = components['responses'].asJson;
    final errorCodes = definitions['Error']
        .asJson['properties']
        .asJson['code']
        .asJson['enum']
        .asList
        .map((e) => e.asString)
        .toSet();

    final operations = <String, ContractOperation>{};
    document['paths'].asJson.forEach((path, item) {
      item.asJson.forEach((method, value) {
        if (!_httpMethods.contains(method)) return;
        final op = value.asJson;
        final schemas = <int, JsonSchema?>{};
        op['responses'].asJson.forEach((status, response) {
          var resolved = response.asJson;
          final ref = resolved[r'$ref'] as String?;
          if (ref != null) {
            resolved = responses[ref.split('/').last].asJson;
          }
          final content = resolved['content'] as Map?;
          final schema = content == null
              ? null
              : (content['application/json'] as Map)['schema'];
          schemas[int.parse(status)] = schema == null
              ? null
              : JsonSchema.create(<String, Object?>{
                  r'$schema': 'http://json-schema.org/draft-07/schema#',
                  'definitions': definitions,
                  'allOf': [_toJsonSchema(schema)],
                }, schemaVersion: SchemaVersion.draft7);
        });
        final id = op['operationId'].asString;
        operations[id] = ContractOperation(
          operationId: id,
          method: method.toUpperCase(),
          pathTemplate: path,
          tags: op['tags'].asList.map((t) => t.asString).toList(),
          responseSchemas: schemas,
          requestBody: op['requestBody'] as Json?,
        );
      });
    });
    return Contract._(document, operations, errorCodes);
  }

  /// OpenAPI 3.0 schema → JSON Schema draft-07: `nullable` becomes a `null`
  /// type, references point to `definitions`, annotations of OpenAPI only
  /// (`example`, `discriminator`, `x-*`) are dropped.
  static Object? _toJsonSchema(Object? node) {
    if (node is Map) {
      final out = <String, Object?>{};
      node.forEach((key, value) {
        final k = key as String;
        if (k == 'properties') {
          out[k] = {
            for (final e in (value as Map).entries)
              e.key as String: _toJsonSchema(e.value),
          };
          return;
        }
        if (k.startsWith('x-') ||
            k == 'example' ||
            k == 'examples' ||
            k == 'discriminator' ||
            k == 'nullable') {
          return;
        }
        if (k == r'$ref') {
          out[k] = (value as String).replaceFirst(
            '#/components/schemas/',
            '#/definitions/',
          );
          return;
        }
        out[k] = _toJsonSchema(value);
      });
      if (node['nullable'] == true && out['type'] is String) {
        out['type'] = [out['type'], 'null'];
      }
      return out;
    }
    if (node is List) return node.map(_toJsonSchema).toList();
    return node;
  }
}

/// A response that passed the contract check.
final class ApiResponse {
  ApiResponse(this.operationId, this.status, this.headers, this.text, this.json);

  final String operationId;
  final int status;
  final Map<String, String> headers;
  final String text;

  /// Decoded JSON body; `null` for an empty body.
  final Object? json;

  Json get body => json.asJson;
  String? get location => headers['location'];
  String get errorCode => body['code'].asString;
  List<Json> get details => (body['details'] as List?)?.asJsonList ?? const [];
  List<Json> get reasons => (body['reasons'] as List?)?.asJsonList ?? const [];

  @override
  String toString() => '$operationId → $status $text';
}

/// Marker of an absent request body.
const Object noBody = _NoBody();

final class _NoBody {
  const _NoBody();
}

/// Calls the composed shelf handler by operationId and validates every response.
final class ApiClient {
  ApiClient(this._handler) : contract = Contract.load();

  final Handler _handler;
  final Contract contract;

  /// Sends a request of [operationId]. [query] values are `String` or
  /// `List<String>` (repeated parameter, `style: form, explode: true`).
  /// [rawBody] is sent as is (malformed JSON); otherwise [body] is JSON-encoded.
  Future<ApiResponse> send(
    String operationId, {
    Map<String, String> path = const {},
    Map<String, Object> query = const {},
    Object? body = noBody,
    String? rawBody,
  }) async {
    final op = contract.operation(operationId);
    final concretePath = op.pathTemplate.replaceAllMapped(RegExp(r'\{(\w+)\}'), (
      m,
    ) {
      final value = path[m[1]];
      if (value == null) fail('$operationId: path parameter ${m[1]} is missing');
      return Uri.encodeComponent(value);
    });
    final uri = Uri(
      scheme: 'http',
      host: '127.0.0.1',
      path: concretePath,
      queryParameters: query.isEmpty ? null : query,
    );
    final String? encoded = rawBody ?? (identical(body, noBody) ? null : jsonEncode(body));
    final response = await _handler(
      Request(
        op.method,
        uri,
        body: encoded,
        headers: encoded == null ? null : {'content-type': 'application/json'},
      ),
    );
    final text = await response.readAsString();
    return _validate(op, response.statusCode, response.headers, text);
  }

  ApiResponse _validate(
    ContractOperation op,
    int status,
    Map<String, String> headers,
    String text,
  ) {
    final id = op.operationId;
    final declared = op.responseSchemas;
    if (!declared.containsKey(status)) {
      fail(
        '$id: status $status is not declared in $contractPath '
        '(declared: ${declared.keys.join(', ')})',
      );
    }
    final schema = declared[status];
    if (schema == null) {
      if (text.isNotEmpty) {
        fail('$id: status $status has no content in the contract, body: $text');
      }
      return ApiResponse(id, status, headers, text, null);
    }
    final contentType = headers['content-type'] ?? '';
    if (!contentType.startsWith('application/json')) {
      fail('$id: status $status must be application/json, got "$contentType"');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException catch (e) {
      fail('$id: status $status body is not JSON (${e.message}): $text');
    }
    final result = schema.validate(decoded);
    if (!result.isValid) {
      fail(
        '$id: status $status body violates the contract schema: '
        '${result.errors.join('; ')}\nbody: $text',
      );
    }
    if (status == 201) {
      final location = headers['location'];
      if (location == null || location.isEmpty) {
        fail('$id: 201 without Location header');
      }
      if (Uri.tryParse(location) == null) {
        fail('$id: Location "$location" is not a URI reference');
      }
    }
    if (status >= 400) {
      final code = decoded.asJson['code'];
      if (!contract.errorCodes.contains(code)) {
        fail('$id: Error.code "$code" is not in the contract enum');
      }
    }
    return ApiResponse(id, status, headers, text, decoded);
  }
}

/// Asserts the status of a contract-valid response.
void expectStatus(ApiResponse response, int status) {
  expect(response.status, status, reason: response.toString());
}

/// Asserts status and `Error.code` of a contract-valid error response.
void expectError(ApiResponse response, int status, String code) {
  expectStatus(response, status);
  expect(response.errorCode, code, reason: response.toString());
}

/// Asserts that `details[]` names [field]; [constraint] is checked only when
/// the contract defines it for this violation (examples of spec/openapi.yaml).
void expectDetail(ApiResponse response, String field, {String? constraint}) {
  final matches = response.details.where((d) => d['field'] == field);
  expect(
    matches,
    isNotEmpty,
    reason: 'details[] must name field $field: ${response.text}',
  );
  if (constraint != null) {
    expect(
      matches.map((d) => d['constraint']),
      contains(constraint),
      reason: 'details[] for $field must have constraint $constraint',
    );
  }
}
