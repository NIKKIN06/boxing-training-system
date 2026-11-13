/// Test harness: the application is composed only through `buildApp`
/// (composition root) with a [FakeClock], a [SeededRandom] and a catalog path
/// (T-57, stage 5, decision 4). No test endpoints or headers (stage 1, decision 5).
///
/// - every test gets its own temporary SQLite file;
/// - [TestApp.restart] closes the application and composes it again on the
///   same file — a restart of the server process (stage 1, decision 4);
/// - [TestApp.restartWithReadOnlyStorage] simulates a storage write failure
///   (AC-NF-003, BDD-021): the database file becomes read-only for the OS, so
///   reads succeed and every write fails.
///
/// Application logs go to `$BOXING_API_TEST_LOG_DIR/$BOXING_API_TEST_LOG_FILE`
/// (defaults: a temporary directory, `tests-<pid>.log`).
library;

import 'dart:convert';
import 'dart:io';

import 'package:boxing_api/boxing_api.dart';
import 'package:test/test.dart';

import 'contract.dart';
import 'fake_clock.dart';
import 'json.dart';
import 'seeded_random.dart';

/// Supplied [TEST] catalog (T-57) — the resource of the API.
const String baseCatalog = '../src/assets/catalog/test-catalog.json';

/// Catalog fixtures of the tests (stage 5, decision 4).
String fixtureCatalog(String fileName) => 'fixtures/catalogs/$fileName';

/// Default local time of the fake clock.
final DateTime defaultNow = DateTime(2026, 6, 30, 18);

final class TestApp {
  TestApp._(this._dir, this.clock, this.random, this.catalogPath);

  final Directory _dir;
  final FakeClock clock;
  SeededRandom random;
  String catalogPath;
  late App _app;
  late ApiClient api;
  bool _closed = false;

  String get databasePath => '${_dir.path}${Platform.pathSeparator}api.sqlite';

  /// Composes a fresh application and registers its disposal.
  static Future<TestApp> start({
    String catalog = baseCatalog,
    int seed = 1,
    DateTime? now,
  }) async {
    _ensureLogSink();
    final dir = await Directory.systemTemp.createTemp('boxing_api_test_');
    final app = TestApp._(
      dir,
      FakeClock(now ?? defaultNow),
      SeededRandom(seed),
      catalog,
    );
    app._compose();
    addTearDown(app.close);
    return app;
  }

  void _compose() {
    _app = buildApp(
      AppConfig(
        databasePath: databasePath,
        catalogPath: catalogPath,
        logDirectory: _logDirectory,
        logFileName: _logFileName,
      ),
      clock: clock,
      random: random,
    );
    api = ApiClient(_app.handler);
  }

  /// Restart of the server process on the same database (optionally with a
  /// new catalog version or a new seed). In-memory state is lost.
  Future<void> restart({String? catalog, int? seed}) async {
    await _app.close();
    if (catalog != null) catalogPath = catalog;
    if (seed != null) random = SeededRandom(seed);
    _compose();
  }

  /// Restart with the database file read-only for the operating system.
  Future<void> restartWithReadOnlyStorage() async {
    await _app.close();
    await _chmod('444');
    _compose();
  }

  /// Restart with a writable database file again.
  Future<void> restartWithWritableStorage() async {
    await _app.close();
    await _chmod('644');
    _compose();
  }

  Future<void> _chmod(String mode) async {
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final file = File('$databasePath$suffix');
      if (!file.existsSync()) continue;
      final result = await Process.run('chmod', [mode, file.path]);
      if (result.exitCode != 0) {
        fail('chmod $mode ${file.path} failed: ${result.stderr}');
      }
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _app.close();
    await _chmod('644');
    await _dir.delete(recursive: true);
  }
}

String get _logDirectory =>
    Platform.environment['BOXING_API_TEST_LOG_DIR'] ??
    '${Directory.systemTemp.path}${Platform.pathSeparator}boxing_api_tests';

String get _logFileName =>
    Platform.environment['BOXING_API_TEST_LOG_FILE'] ?? 'tests-$pid.log';

LogSink? _logSink;

void _ensureLogSink() {
  _logSink ??= LogSink.file(directory: _logDirectory, fileName: _logFileName);
}

/// Catalog data file read by the test itself (expected values come from the
/// approved data, not from the code).
final class CatalogData {
  CatalogData._(this.json);

  factory CatalogData.load(String path) =>
      CatalogData._((jsonDecode(File(path).readAsStringSync()) as Object?).asJson);

  final Json json;

  List<Json> get exercises => json['exercises'].asJsonList;

  List<Json> get activeExercises =>
      exercises.where((e) => e['deprecated'] != true).toList();

  Json exercise(String id) => exercises.firstWhere((e) => e['id'] == id);

  Json variant(String exerciseId, String variantId) => exercise(
    exerciseId,
  )['variants'].asJsonList.firstWhere((v) => v['id'] == variantId);

  Json dictionary(String name) => json['dictionaries'].asJsonList.firstWhere(
    (d) => d['dictionary'] == name,
  );
}
