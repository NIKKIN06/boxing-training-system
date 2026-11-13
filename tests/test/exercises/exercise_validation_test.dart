/// T-11 (#12): validation of an exercise and its variants.
///
/// Sources: AC-F-002, AC-F-004 pp. 2–4; SRS §4.3.1, §4.3.2, §5.3; BDD-002,
/// BDD-003, BDD-024, BDD-034 (D-05), BDD-036 (D-07), D-08, BDD-052 (D-33);
/// spec/openapi.yaml createExercise, updateExercise, getExercise
/// (`info.description`: 400 — wrong JSON or JSON type, 422 — domain rules);
/// docs/api/scenarios.md POS-03, POS-05, POS-07, NEG-02, NEG-03, NEG-06.
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

/// Exercise body for createExercise / updateExercise built from a response.
Json inputFrom(Json exercise) => Map.of(exercise)
  ..remove('id')
  ..remove('origin')
  ..remove('deprecated');

Json withVariant(Json input, int index, Json Function(Json) change) {
  final variants = input['variants'].asJsonList.map(Map<String, Object?>.of).toList();
  variants[index] = change(variants[index]);
  return {...input, 'variants': variants};
}

void main() {
  late TestApp app;

  setUp(() async => app = await TestApp.start());

  group('T-11 createExercise / getExercise: correct custom exercise', () {
    test(
      'POS-03 POS-05 BDD-024 AC-F-002 AC-F-004 createExercise getExercise: '
      'custom exercise without video data is saved with the entered values',
      () async {
        final input = ropeExerciseInput();
        final res = await app.api.send('createExercise', body: input);
        expectStatus(res, 201);
        final created = res.body;
        expect(created['origin'], 'custom');
        expect(created['deprecated'], isFalse);
        expect(created['videoUrl'], isNull);
        expect(created['videoAuthorName'], isNull);
        expect(created['authorPageUrl'], isNull);
        for (final key in input.keys.where((k) => k != 'variants')) {
          expect(created[key], input[key], reason: key);
        }
        final variant = created['variants'].asJsonList.single;
        expect(variant['id'], isA<String>());
        expect(Map.of(variant)..remove('id'), input['variants'].asJsonList.single);

        final id = created['id'].asString;
        expect(Uri.parse(res.location!).path, '/exercises/$id');
        expect(await app.api.getExerciseOk(id), created);
      },
    );

    test('BDD-002 POS-07 AC-F-002 createExercise updateExercise getExercise: '
        'changed description is saved and returned when the card is reopened', () async {
      final created = await app.api.createExerciseOk(ropeExerciseInput());
      final id = created['id'].asString;
      final input = {
        ...inputFrom(created),
        'description': '[TEST] Оновлений опис стрибків на скакалці.',
      };
      final res = await app.api.send(
        'updateExercise',
        path: {'exerciseId': id},
        body: input,
      );
      expectStatus(res, 200);
      expect(res.body['description'], input['description']);
      final reopened = await app.api.getExerciseOk(id);
      expect(reopened, res.body);
      expect(reopened['variants'], created['variants']);
    });

    test(
      'D-05 AC-F-002 createExercise: id, origin and deprecated in the body are '
      'set by the system (origin custom, deprecated false)',
      () async {
        final created = await app.api.createExerciseOk({
          ...ropeExerciseInput(),
          'id': 'ex-1',
          'origin': 'initial',
          'deprecated': true,
        });
        expect(created['id'], isNot('ex-1'));
        expect(created['origin'], 'custom');
        expect(created['deprecated'], isFalse);
        final initial = await app.api.getExerciseOk('ex-1');
        expect(initial['origin'], 'initial');
      },
    );
  });

  group('T-11 updateExercise: stable variant ids (D-33)', () {
    test('BDD-052 D-33 AC-F-002 updateExercise: after changing variant V1 the '
        'variants V1 and V2 keep their ids', () async {
      final created = await app.api.createExerciseOk(twoVariantExerciseInput());
      final id = created['id'].asString;
      final before = created['variants'].asJsonList;
      final input = withVariant(
        inputFrom(created),
        0,
        (v) => {
          ...v,
          'sets': {'min': 2, 'max': 5, 'recommended': 4},
        },
      );
      final res = await app.api.send(
        'updateExercise',
        path: {'exerciseId': id},
        body: input,
      );
      expectStatus(res, 200);
      final after = (await app.api.getExerciseOk(id))['variants'].asJsonList;
      expect(after.map((v) => v['id']), before.map((v) => v['id']));
      expect(after[0]['sets'], {'min': 2, 'max': 5, 'recommended': 4});
      expect(after[1], before[1]);
    });

    test('AC-F-002 D-33 updateExercise: a variant without id is added with a new id, '
        'a variant missing from the body is removed', () async {
      final created = await app.api.createExerciseOk(twoVariantExerciseInput());
      final id = created['id'].asString;
      final variants = created['variants'].asJsonList;
      final kept = variants[0];
      final added = Map.of(variants[1])..remove('id');
      final res = await app.api.send(
        'updateExercise',
        path: {'exerciseId': id},
        body: {
          ...inputFrom(created),
          'variants': [kept, added],
        },
      );
      expectStatus(res, 200);
      final after = (await app.api.getExerciseOk(id))['variants'].asJsonList;
      expect(after, hasLength(2));
      expect(after[0], kept);
      expect(after[1]['id'], isA<String>());
      expect(after[1]['id'], isNot(kept['id']));
      expect(after[1]['id'], isNot(variants[1]['id']));
      expect(Map.of(after[1])..remove('id'), added);
    });
  });

  group('T-11 updateExercise: rejected changes are not saved (AC-F-002)', () {
    test('BDD-003 AC-F-002 updateExercise: minimum 5 sets above maximum 3 → '
        '422 VALIDATION_FAILED, saved data unchanged', () async {
      final created = await app.api.createExerciseOk(twoVariantExerciseInput());
      final id = created['id'].asString;
      final res = await app.api.send(
        'updateExercise',
        path: {'exerciseId': id},
        body: withVariant(
          inputFrom(created),
          0,
          (v) => {
            ...v,
            'sets': {'min': 5, 'max': 3, 'recommended': 3},
          },
        ),
      );
      expectError(res, 422, 'VALIDATION_FAILED');
      expectDetail(res, 'variants[0].sets.min', constraint: 'MIN_LE_MAX');
      expect(await app.api.getExerciseOk(id), created);
    });

    test('AC-F-002 updateExercise: empty name of a custom exercise → 422 '
        'VALIDATION_FAILED, no partial save of other changed fields', () async {
      final created = await app.api.createExerciseOk(ropeExerciseInput());
      final id = created['id'].asString;
      final res = await app.api.send(
        'updateExercise',
        path: {'exerciseId': id},
        body: {
          ...inputFrom(created),
          'name': '',
          'description': '[TEST] Не має зберегтися.',
        },
      );
      expectError(res, 422, 'VALIDATION_FAILED');
      expectDetail(res, 'name');
      expect(await app.api.getExerciseOk(id), created);
    });

    test('BDD-034 D-05 NEG-06 AC-F-002 updateExercise: initial exercise ex-1 → '
        '403 INITIAL_EXERCISE_READ_ONLY, data unchanged', () async {
      final before = await app.api.getExerciseOk('ex-1');
      final res = await app.api.send(
        'updateExercise',
        path: {'exerciseId': 'ex-1'},
        body: {...inputFrom(before), 'description': '[TEST] Змінений опис.'},
      );
      expectError(res, 403, 'INITIAL_EXERCISE_READ_ONLY');
      expect(await app.api.getExerciseOk('ex-1'), before);
    });

    test('BDD-034 D-05 D-06 updateExercise: deprecated initial exercise ex-9 → '
        '403 INITIAL_EXERCISE_READ_ONLY', () async {
      final before = await app.api.getExerciseOk('ex-9');
      final res = await app.api.send(
        'updateExercise',
        path: {'exerciseId': 'ex-9'},
        body: {...inputFrom(before), 'description': '[TEST] Змінений опис.'},
      );
      expectError(res, 403, 'INITIAL_EXERCISE_READ_ONLY');
      expect(await app.api.getExerciseOk('ex-9'), before);
    });

    test('AC-F-002 updateExercise: unknown exercise → 404 NOT_FOUND', () async {
      final res = await app.api.send(
        'updateExercise',
        path: {'exerciseId': 'ex-404'},
        body: ropeExerciseInput(),
      );
      expectError(res, 404, 'NOT_FOUND');
    });

    test('NEG-02 getExercise: unknown exercise → 404 NOT_FOUND', () async {
      final res = await app.api.send(
        'getExercise',
        path: {'exerciseId': 'ex-404'},
      );
      expectError(res, 404, 'NOT_FOUND');
    });
  });

  group('T-11 createExercise: incorrect exercise → 422 VALIDATION_FAILED, '
      'nothing saved (AC-F-002, SRS §5.3, D-08)', () {
    final timeVariant = ropeExerciseInput()['variants'].asJsonList.single;
    final repsVariant = twoVariantExerciseInput()['variants'].asJsonList.first;

    final cases = <({String name, Json body, String field, String? constraint})>[
      (
        name: 'AC-F-002 empty name',
        body: {...ropeExerciseInput(), 'name': ''},
        field: 'name',
        constraint: null,
      ),
      (
        name: 'AC-F-002 empty description',
        body: {...ropeExerciseInput(), 'description': ''},
        field: 'description',
        constraint: null,
      ),
      (
        name: 'AC-F-002 missing name',
        body: Map.of(ropeExerciseInput())..remove('name'),
        field: 'name',
        constraint: null,
      ),
      (
        name: 'AC-F-002 no variants',
        body: {...ropeExerciseInput(), 'variants': <Object?>[]},
        field: 'variants',
        constraint: null,
      ),
      (
        name: 'NEG-03 BDD-003 AC-F-002 rounds minimum 5 above maximum 3',
        body: {
          ...ropeExerciseInput(),
          'variants': [
            {
              ...timeVariant,
              'rounds': {'min': 5, 'max': 3, 'recommended': 3},
            },
          ],
        },
        field: 'variants[0].rounds.min',
        constraint: 'MIN_LE_MAX',
      ),
      (
        name: 'D-08 AC-F-002 recommended rounds above maximum',
        body: {
          ...ropeExerciseInput(),
          'variants': [
            {
              ...timeVariant,
              'rounds': {'min': 1, 'max': 5, 'recommended': 6},
            },
          ],
        },
        field: 'variants[0].rounds.recommended',
        constraint: null,
      ),
      (
        name: 'D-08 AC-F-002 recommended interval below minimum',
        body: {
          ...ropeExerciseInput(),
          'variants': [
            {
              ...timeVariant,
              'intervalSeconds': {'min': 60, 'max': 180, 'recommended': 30},
            },
          ],
        },
        field: 'variants[0].intervalSeconds.recommended',
        constraint: null,
      ),
      (
        name: 'AC-F-002 SRS §5.3 zero rounds',
        body: {
          ...ropeExerciseInput(),
          'variants': [
            {
              ...timeVariant,
              'rounds': {'min': 0, 'max': 5, 'recommended': 3},
            },
          ],
        },
        field: 'variants[0].rounds.min',
        constraint: 'MINIMUM',
      ),
      (
        name: 'AC-F-002 SRS §5.3 negative rest',
        body: {
          ...ropeExerciseInput(),
          'variants': [
            {
              ...timeVariant,
              'restSeconds': {'min': -1, 'max': 90, 'recommended': 60},
            },
          ],
        },
        field: 'variants[0].restSeconds.min',
        constraint: 'MINIMUM',
      ),
      (
        name: 'AC-F-002 SRS §5.3 non-integer interval',
        body: {
          ...ropeExerciseInput(),
          'variants': [
            {
              ...timeVariant,
              'intervalSeconds': {'min': 60, 'max': 180.5, 'recommended': 120},
            },
          ],
        },
        field: 'variants[0].intervalSeconds.max',
        constraint: null,
      ),
      (
        name: 'D-08 AC-F-002 zero repetition time',
        body: {
          ...twoVariantExerciseInput(),
          'variants': [
            {...repsVariant, 'repetitionTimeSeconds': 0},
          ],
        },
        field: 'variants[0].repetitionTimeSeconds',
        constraint: 'MINIMUM',
      ),
      (
        name: 'D-08 AC-F-002 missing repetition time',
        body: {
          ...twoVariantExerciseInput(),
          'variants': [Map.of(repsVariant)..remove('repetitionTimeSeconds')],
        },
        field: 'variants[0].repetitionTimeSeconds',
        constraint: null,
      ),
      (
        name: 'AC-F-004 video link is not HTTPS',
        body: {
          ...ropeExerciseInput(),
          'videoUrl': 'http://example.com/test/rope',
        },
        field: 'videoUrl',
        constraint: null,
      ),
      (
        name: 'AC-F-004 author page link is not HTTPS',
        body: {
          ...ropeExerciseInput(),
          'videoAuthorName': '[TEST] Автор відео',
          'authorPageUrl': 'ftp://example.com/test/author',
        },
        field: 'authorPageUrl',
        constraint: null,
      ),
    ];

    for (final c in cases) {
      test('${c.name}: createExercise → 422 VALIDATION_FAILED', () async {
        final res = await app.api.send('createExercise', body: c.body);
        expectError(res, 422, 'VALIDATION_FAILED');
        expectDetail(res, c.field, constraint: c.constraint);
        final list = await app.api.send('listExercises');
        expectStatus(list, 200);
        expect(
          list.body['items'].asJsonList.where((e) => e['origin'] == 'custom'),
          isEmpty,
          reason: 'a rejected exercise must not be saved',
        );
      });
    }

    test('AC-F-002 createExercise: wrong JSON type of a field → 400 '
        'BAD_REQUEST', () async {
      final res = await app.api.send(
        'createExercise',
        body: {...ropeExerciseInput(), 'name': 5},
      );
      expectError(res, 400, 'BAD_REQUEST');
    });

    test('AC-F-002 createExercise: malformed JSON → 400 BAD_REQUEST', () async {
      final res = await app.api.send('createExercise', rawBody: '{"name": ');
      expectError(res, 400, 'BAD_REQUEST');
    });
  });

  group('T-11 createExercise: video data in any combination (D-07)', () {
    final rows = <({bool video, bool author})>[
      (video: true, author: false),
      (video: false, author: true),
      (video: true, author: true),
      (video: false, author: false),
    ];
    for (final row in rows) {
      test('BDD-036 D-07 AC-F-004 createExercise getExercise: video=${row.video ? 'yes' : 'no'} '
          'author=${row.author ? 'yes' : 'no'} is saved; absent links are null', () async {
        final input = {
          ...ropeExerciseInput(),
          'videoUrl': row.video ? 'https://example.com/test/rope-video' : null,
          'videoAuthorName': row.author ? '[TEST] Автор відео' : null,
          'authorPageUrl': row.author ? 'https://example.com/test/author' : null,
        };
        final created = await app.api.createExerciseOk(input);
        final card = await app.api.getExerciseOk(created['id'].asString);
        expect(card['videoUrl'], input['videoUrl']);
        expect(card['videoAuthorName'], input['videoAuthorName']);
        expect(card['authorPageUrl'], input['authorPageUrl']);
      });
    }
  });
}
