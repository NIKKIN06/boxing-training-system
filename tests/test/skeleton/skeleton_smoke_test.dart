/// T-10 readiness check of the API skeleton (not a TEST-GATE test).
///
/// Source: spec/openapi.yaml — all 27 operationIds, their methods, paths and
/// request bodies are read from the contract, not from the code.
/// Expected skeleton state: every operation answers 501 (stub), the log file
/// has a start record and one request record per operation (stage 1, decision 3).
///
/// This check describes the skeleton only; it is replaced when operations are
/// implemented after TEST-GATE (T-29).
library;

import 'dart:io';

import 'package:boxing_api/boxing_api.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

const String contractPath = '../spec/openapi.yaml';
const String catalogPath = '../src/assets/catalog/test-catalog.json';
const Set<String> httpMethods = {'get', 'post', 'put', 'patch', 'delete'};

final class ContractOperation {
  const ContractOperation(
    this.method,
    this.path,
    this.operationId,
    this.hasBody,
  );

  final String method;
  final String path;
  final String operationId;
  final bool hasBody;
}

List<ContractOperation> loadContractOperations() {
  final document = loadYaml(File(contractPath).readAsStringSync()) as YamlMap;
  final paths = document['paths'] as YamlMap;
  final operations = <ContractOperation>[];
  for (final entry in paths.entries) {
    final path = entry.key as String;
    final item = entry.value as YamlMap;
    for (final methodEntry in item.entries) {
      final method = methodEntry.key as String;
      if (!httpMethods.contains(method)) continue;
      final operation = methodEntry.value as YamlMap;
      operations.add(
        ContractOperation(
          method.toUpperCase(),
          path,
          operation['operationId'] as String,
          operation.containsKey('requestBody'),
        ),
      );
    }
  }
  return operations;
}

/// Substitutes path parameters: `dictionaryName` takes a value of the contract
/// enum `DictionaryName`, the others an arbitrary id.
String concretePath(String template) => template.replaceAllMapped(
  RegExp(r'\{(\w+)\}'),
  (match) =>
      match[1] == 'dictionaryName' ? 'training-levels' : 'smoke-${match[1]}',
);

void main() {
  final operations = loadContractOperations();
  late Directory logDirectory;
  late LogSink logSink;
  late App app;

  setUpAll(() {
    logDirectory = Directory.systemTemp.createTempSync('boxing_api_smoke_');
    logSink = LogSink.file(directory: logDirectory.path, fileName: 'smoke.log');
    app = buildApp(
      AppConfig(
        databasePath: AppConfig.inMemoryDatabase,
        catalogPath: catalogPath,
        logDirectory: logDirectory.path,
        logFileName: 'smoke.log',
      ),
    );
  });

  tearDownAll(() async {
    await app.close();
    await logSink.close();
    logDirectory.deleteSync(recursive: true);
  });

  test('contract has 27 operations and the skeleton routes all of them', () {
    expect(operations, hasLength(27));
    expect(
      operations.map((o) => o.operationId).toSet(),
      equals(operationIds.toSet()),
    );
  });

  group('every operation answers 501 Not Implemented', () {
    for (final op in operations) {
      test('${op.operationId}: ${op.method} ${op.path}', () async {
        final response = await app.handler(
          Request(
            op.method,
            Uri.parse('http://127.0.0.1${concretePath(op.path)}'),
            body: op.hasBody ? '{}' : null,
            headers: op.hasBody ? {'content-type': 'application/json'} : null,
          ),
        );
        expect(response.statusCode, 501);
        expect(await response.readAsString(), isEmpty);
      });
    }
  });

  test(
    'log file has the start record and one request record per operation',
    () {
      final log = logSink.file!.readAsStringSync();
      expect(log, contains('INFO app: app composed operations=27'));
      for (final op in operations) {
        expect(
          log,
          contains(
            'INFO http: request method=${op.method} '
            'operationId=${op.operationId} status=501',
          ),
        );
        expect(
          log,
          contains(
            'WARNING http: not implemented operationId=${op.operationId} ',
          ),
        );
      }
    },
  );
}
