/// Coverage of the contract by the tests (AC-NF-006, REQ-NF-006).
///
/// 1. Every operationId of spec/openapi.yaml is called (`send('<operationId>'`)
///    by at least one test file of this package.
/// 2. Every operation answers a request built from the contract (request body
///    example, path parameters) with a status declared for it — never 501 (the
///    stub status of the T-10 skeleton, not declared in the contract).
///
/// Names carry the first POS scenario of the operation from
/// docs/api/scenarios.md.
library;

import 'dart:io';

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/json.dart';
import '../support/test_app.dart';

const String scenariosPath = '../docs/api/scenarios.md';

/// operationId → first POS id in docs/api/scenarios.md, section 2.
Map<String, String> firstPositiveScenario() {
  final pattern = RegExp(r'^\| (POS-\d+) \| `(\w+)` \|', multiLine: true);
  final result = <String, String>{};
  for (final m in pattern.allMatches(File(scenariosPath).readAsStringSync())) {
    result.putIfAbsent(m[2]!, () => m[1]!);
  }
  return result;
}

/// operationIds called through `send('<id>'` in the test files.
Set<String> calledOperationIds() {
  final pattern = RegExp(r"send\(\s*'(\w+)'");
  final called = <String>{};
  final files = Directory('test')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('_test.dart') && !f.path.contains('operation_coverage'));
  for (final file in files) {
    for (final m in pattern.allMatches(file.readAsStringSync())) {
      called.add(m[1]!);
    }
  }
  return called;
}

void main() {
  final contract = Contract.load();
  final scenarios = firstPositiveScenario();

  test('AC-NF-006 REQ-NF-006 all operationIds: every operation of '
      'spec/openapi.yaml is called by at least one test', () {
    expect(contract.operations, hasLength(27));
    final missing = contract.operations.keys.toSet().difference(calledOperationIds());
    expect(missing, isEmpty, reason: 'operations without a test: $missing');
  });

  test('AC-NF-006 docs/api/scenarios.md: every operationId has a POS scenario', () {
    expect(scenarios.keys.toSet(), contract.operations.keys.toSet());
  });

  group('AC-NF-006 every operation answers with a declared status, never 501', () {
    late TestApp app;

    setUp(() async => app = await TestApp.start());

    for (final op in contract.operations.values) {
      test('${scenarios[op.operationId] ?? 'POS-?'} ${op.operationId}: '
          '${op.method} ${op.pathTemplate} → declared status, not 501', () async {
        final path = <String, String>{
          for (final m in RegExp(r'\{(\w+)\}').allMatches(op.pathTemplate))
            m[1]!: m[1] == 'dictionaryName' ? 'training-levels' : 'coverage-${m[1]}',
        };
        final res = await app.api.send(
          op.operationId,
          path: path,
          body: _exampleBody(contract, op),
        );
        expect(res.status, isNot(501));
        expect(op.declaredStatuses, contains(res.status));
      });
    }
  });
}

/// First example of the request body of [op], or [noBody].
Object? _exampleBody(Contract contract, ContractOperation op) {
  final body = op.requestBody;
  if (body == null) return noBody;
  final media = body['content'].asJson['application/json'].asJson;
  final examples = media['examples'] as Map?;
  if (examples == null || examples.isEmpty) return <String, Object?>{};
  final first = (examples.values.first as Map).cast<String, Object?>();
  final ref = first[r'$ref'] as String?;
  return ref == null ? first['value'] : contract.example(ref.split('/').last);
}
