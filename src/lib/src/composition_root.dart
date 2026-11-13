/// Composition root: the only place where implementations are chosen and the
/// clock, random source and id generator are substituted (stage 1, decision 5).
library;

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

import 'application/catalog_service.dart';
import 'application/plan_services.dart';
import 'application/training_services.dart';
import 'config/app_config.dart';
import 'data/database.dart';
import 'data/drift_repositories.dart';
import 'data/json_catalog_source.dart';
import 'data/memory_stores.dart';
import 'data/system_ports.dart';
import 'http/middleware.dart';
import 'http/routes.dart';
import 'logging/app_logging.dart';
import 'ports/system_ports.dart';

/// Composed application: an HTTP handler and its resources.
final class App {
  App._(this.handler, this._database, this._initialized);

  final Handler handler;
  final AppDatabase _database;
  final Future<void> _initialized;

  /// Completes when the catalog initialization (T-32) has finished; fails
  /// with its error (already logged at ERROR with the stack trace). The
  /// server starts listening only after it completes (human decision
  /// 13.11.2026, group 1, item 4).
  Future<void> get initialized => _initialized;

  /// Closes the database after the catalog initialization has finished.
  Future<void> close() async {
    try {
      await _initialized;
    } on Object {
      // Already logged at ERROR by buildApp.
    }
    await _database.close();
  }
}

/// Holds every request of an in-process handler until the catalog
/// initialization (T-32) has finished. The server does not serve requests
/// when the initialization failed (bin/server.dart).
Middleware _afterInitialization(Future<void> initialized) {
  return (inner) => (request) async {
    await initialized;
    return inner(request);
  };
}

/// Builds the application. Tests pass their own [clock], [random] and [ids]
/// and their own `catalogPath` (T-57, human decision 4) through this function.
App buildApp(
  AppConfig config, {
  Clock? clock,
  RandomSource? random,
  IdGenerator? ids,
}) {
  final log = Logger(LogNames.app);
  final usedClock = clock ?? const SystemClock();
  final usedRandom = random ?? SystemRandomSource();
  final usedIds = ids ?? RandomIdGenerator();

  final QueryExecutor executor;
  if (config.isInMemoryDatabase) {
    executor = NativeDatabase.memory();
  } else {
    final file = File(config.databasePath);
    file.parent.createSync(recursive: true);
    executor = NativeDatabase.createInBackground(file);
  }
  final database = AppDatabase(executor);

  final exercises = DriftExerciseRepository(database);
  final trainingPlans = DriftTrainingPlanRepository(database);
  final completedTrainings = DriftCompletedTrainingRepository(database);
  final openPlans = InMemoryOpenPlanStore();
  final session = InMemoryCurrentSessionStore();

  final catalog = CatalogService(
    exercises: exercises,
    catalogSource: JsonFileCatalogSource(config.catalogPath),
    ids: usedIds,
  );
  final initialized = catalog.initialize();
  unawaited(
    initialized.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) =>
          log.severe(
            'catalog initialization failed',
            safeErrorDescription(error),
            stackTrace,
          ),
    ),
  );

  final services = Services(
    catalog: catalog,
    generation: PlanGenerationService(
      exercises: exercises,
      openPlans: openPlans,
      clock: usedClock,
      random: usedRandom,
      ids: usedIds,
    ),
    openPlans: OpenPlanService(
      exercises: exercises,
      trainingPlans: trainingPlans,
      openPlans: openPlans,
      ids: usedIds,
    ),
    trainingPlans: TrainingPlanService(
      trainingPlans: trainingPlans,
      openPlans: openPlans,
      clock: usedClock,
      ids: usedIds,
    ),
    currentSession: CurrentSessionService(
      openPlans: openPlans,
      session: session,
      clock: usedClock,
    ),
    completedTrainings: CompletedTrainingService(
      trainings: completedTrainings,
      session: session,
      ids: usedIds,
    ),
    analytics: AnalyticsService(
      trainings: completedTrainings,
      clock: usedClock,
    ),
  );

  final handler = const Pipeline()
      .addMiddleware(requestLogging())
      .addMiddleware(_afterInitialization(initialized))
      .addHandler(buildRouter(services).call);

  log.info(
    'app composed operations=${operationIds.length} '
    'database=${config.isInMemoryDatabase ? 'memory' : config.databasePath} '
    'catalog=${config.catalogPath}',
  );
  return App._(handler, database, initialized);
}
