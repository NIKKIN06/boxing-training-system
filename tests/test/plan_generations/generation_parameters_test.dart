/// T-17 (#18): parameters of a training (API part; T-21 widgets are out of
/// scope of lab 5).
///
/// Sources: AC-F-005; REQ-F-005; BDD-006; SRS §4.3.3, §5.5; D-14, ADD-002
/// D-30, D-31, D-32; spec/openapi.yaml generatePlan, getOpenPlan
/// (`info.description`: 400 / 422); docs/api/scenarios.md POS-09, NEG-01,
/// NEG-04, NEG-32, NEG-33.
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

void main() {
  late TestApp app;

  setUp(() async => app = await TestApp.start());

  group('T-17 generatePlan: incorrect target duration is rejected before '
      'generation (BDD-006)', () {
    final rows = <({int hours, int minutes, String field, String? constraint})>[
      (hours: 0, minutes: 0, field: 'targetDuration', constraint: 'TOTAL_GREATER_THAN_ZERO'),
      (hours: -1, minutes: 30, field: 'targetDuration.hours', constraint: 'MINIMUM'),
      (hours: 1, minutes: -10, field: 'targetDuration.minutes', constraint: 'MINIMUM'),
      (hours: 0, minutes: 60, field: 'targetDuration.minutes', constraint: null),
    ];
    for (final row in rows) {
      final neg = switch ((row.hours, row.minutes)) {
        (0, 0) => 'NEG-04 ',
        (-1, 30) => 'NEG-32 ',
        _ => '',
      };
      test('BDD-006 ${neg}AC-F-005 generatePlan: ${row.hours} h ${row.minutes} min '
          '→ 422 VALIDATION_FAILED, no open plan', () async {
        final res = await app.api.send(
          'generatePlan',
          body: generationParams(hours: row.hours, minutes: row.minutes),
        );
        expectError(res, 422, 'VALIDATION_FAILED');
        expectDetail(res, row.field, constraint: row.constraint);
        expect(res.location, isNull);
      });
    }
  });

  group('T-17 generatePlan: missing or malformed parameters (AC-F-005 p. 5)', () {
    for (final field in [
      'targetDuration',
      'level',
      'emphasis',
      'availableEquipment',
      'intensity',
    ]) {
      final neg = field == 'level' ? 'NEG-33 ' : '';
      test('${neg}AC-F-005 generatePlan: missing $field → 422 VALIDATION_FAILED', () async {
        final res = await app.api.send(
          'generatePlan',
          body: Map.of(generationParams())..remove(field),
        );
        expectError(res, 422, 'VALIDATION_FAILED');
        expectDetail(res, field);
      });
    }

    test('AC-F-005 generatePlan: non-integer hours → 422 VALIDATION_FAILED', () async {
      final res = await app.api.send(
        'generatePlan',
        body: {
          ...generationParams(),
          'targetDuration': {'hours': 1.5, 'minutes': 0},
        },
      );
      expectError(res, 422, 'VALIDATION_FAILED');
      expectDetail(res, 'targetDuration.hours');
    });

    test('NEG-01 AC-F-005 generatePlan: hours as a JSON string → 400 BAD_REQUEST', () async {
      final res = await app.api.send(
        'generatePlan',
        body: {
          ...generationParams(),
          'targetDuration': {'hours': '1', 'minutes': 0},
        },
      );
      expectError(res, 400, 'BAD_REQUEST');
    });

    test('NEG-01 AC-F-005 generatePlan: malformed JSON → 400 BAD_REQUEST', () async {
      final res = await app.api.send('generatePlan', rawBody: '{"targetDuration": {');
      expectError(res, 400, 'BAD_REQUEST');
    });
  });

  group('T-17 generatePlan: accepted parameters', () {
    test('POS-09 AC-F-005 generatePlan getOpenPlan: 1 h 30 min is converted to '
        '5400 s with tolerance 4860–5940 s; the open plan keeps the five '
        'parameters, has no name and no source plan', () async {
      final params = generationParams(hours: 1, minutes: 30);
      final res = await app.api.send('generatePlan', body: params);
      expectStatus(res, 201);
      final plan = res.body;
      expect(plan['targetDurationSeconds'], 5400);
      expect(plan['durationTolerance'], {'minSeconds': 4860, 'maxSeconds': 5940});
      expect(plan['generationParameters'], params);
      expect(plan['name'], isNull);
      expect(plan['sourcePlanId'], isNull);
      final id = plan['id'].asString;
      expect(Uri.parse(res.location!).path, '/open-plans/$id');
      expect(await app.api.getOpenPlanOk(id), plan);
    });

    test('AC-F-005 generatePlan: 0 h 45 min is converted to 2700 s '
        '(tolerance 2430–2970 s)', () async {
      final plan = await app.api.generateOk(generationParams(hours: 0, minutes: 45));
      expect(plan['targetDurationSeconds'], targetSeconds(0, 45));
      expect(plan['durationTolerance'], {'minSeconds': 2430, 'maxSeconds': 2970});
    });

    test('AC-F-005 generatePlan: empty list of equipment is accepted and only '
        'variants without equipment are selected', () async {
      final plan = await app.api.generateOk(
        generationParams(availableEquipment: const []),
      );
      for (final item in allItems(plan)) {
        expect(item['variant'].asJson['equipment'], isEmpty, reason: item['exerciseId'].asString);
      }
    });
  });
}
