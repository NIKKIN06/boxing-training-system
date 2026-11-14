/// TG-012 (addition after TEST-GATE GO; found while implementing group 4):
/// D-06 — an initial exercise absent from the next catalog version is not
/// deleted but marked deprecated.
///
/// Sources: ADD-001 D-06 («Початкові вправи мають стабільний ID і між
/// версіями не видаляються, а позначаються застарілими»; «Застаріла вправа не
/// показується в каталозі»); AC-F-001 pp. 5–6; BDD-035; SRS §4.4;
/// spec/openapi.yaml getExercise («зокрема застарілу (deprecated: true)»),
/// listExercises («Застарілі вправи не повертаються ніколи (D-06)»).
///
/// The catalog update is a restart with the next catalog version on the same
/// database (as in catalog_version_test.dart): fixtures/catalogs/
/// catalog-v2-ex1-missing.json is test-2 without ex-1, all other data as test-1.
library;

import 'package:test/test.dart';

import '../support/contract.dart';
import '../support/flows.dart';
import '../support/json.dart';
import '../support/test_app.dart';

void main() {
  test('BDD-035 D-06 AC-F-001 getExercise listExercises: ex-1 absent from the '
      'new catalog version is kept with deprecated true and is not shown in '
      'the catalog', () async {
    final app = await TestApp.start();
    expect((await app.api.getExerciseOk('ex-1'))['deprecated'], isFalse);

    await app.restart(catalog: fixtureCatalog('catalog-v2-ex1-missing.json'));

    final card = await app.api.getExerciseOk('ex-1');
    expect(card['deprecated'], isTrue);
    final list = await app.api.send('listExercises');
    expectStatus(list, 200);
    expect(list.body['items'].asJsonList.map((e) => e['id']), isNot(contains('ex-1')));
  });
}
