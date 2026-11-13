/// Drift implementations of the storage ports (CON-001; REQ-NF-002, REQ-NF-003).
///
/// A write is reported as successful only after SQLite has completed it; a
/// multi-row write runs in one transaction. A failed write is logged at ERROR
/// with the stack trace and surfaces as [StorageWriteException].
/// T-31 (group 1): exercises and catalog metadata. Saved plans and completed
/// trainings — later groups; their methods still throw [UnimplementedError].
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../domain/enums.dart';
import '../domain/exercise.dart';
import '../domain/exercise_json.dart';
import '../domain/plan.dart';
import '../domain/training.dart';
import '../logging/app_logging.dart';
import '../ports/repositories.dart';
import 'database.dart';

final Logger _log = Logger(LogNames.storage);

/// Runs a write of [operation]; any failure becomes [StorageWriteException].
Future<T> _write<T>(String operation, Future<T> Function() body) async {
  try {
    return await body();
  } on Exception catch (error, stackTrace) {
    _log.severe('write failed operation=$operation', error, stackTrace);
    throw StorageWriteException(operation, error);
  }
}

/// Key of the installed catalog version in `catalog_meta`.
const String catalogVersionKey = 'catalogVersion';

final class DriftExerciseRepository implements ExerciseRepository {
  DriftExerciseRepository(this.db);

  final AppDatabase db;

  @override
  Future<List<Exercise>> findAll() async {
    final rows = await db.select(db.exercises).get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Exercise?> findById(String id) async {
    final row = await (db.select(
      db.exercises,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> insert(Exercise exercise) => _write(
    'exercise.insert',
    () => db.into(db.exercises).insert(_toCompanion(exercise)),
  );

  @override
  Future<void> update(Exercise exercise) => _write('exercise.update', () async {
    final count = await (db.update(
      db.exercises,
    )..where((t) => t.id.equals(exercise.id))).write(_toCompanion(exercise));
    if (count != 1) {
      throw StateError('exercise ${exercise.id}: $count rows updated');
    }
  });

  @override
  Future<String?> installedCatalogVersion() async {
    final row = await (db.select(
      db.catalogMeta,
    )..where((t) => t.key.equals(catalogVersionKey))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<List<String>> installCatalog(
    String version,
    List<Exercise> initial,
  ) => _write('catalog.install', () {
    return db.transaction(() async {
      final supplied = {for (final e in initial) e.id};
      final stored = await db.select(db.exercises).get();
      final storedIds = {for (final row in stored) row.id};
      final customIds = {
        for (final row in stored)
          if (row.origin == Origin.custom.wire) row.id,
      };
      for (final exercise in initial) {
        // A supplied id never replaces a custom exercise (D-06).
        if (customIds.contains(exercise.id)) {
          throw StateError('supplied id ${exercise.id} is a custom exercise');
        }
        final companion = _toCompanion(exercise);
        if (storedIds.contains(exercise.id)) {
          await (db.update(
            db.exercises,
          )..where((t) => t.id.equals(exercise.id))).write(companion);
        } else {
          await db.into(db.exercises).insert(companion);
        }
      }
      // D-06: initial exercises are not deleted between versions.
      final deprecated = [
        for (final row in stored)
          if (row.origin == Origin.initial.wire &&
              !supplied.contains(row.id) &&
              !row.deprecated)
            row.id,
      ];
      for (final id in deprecated) {
        await (db.update(db.exercises)..where((t) => t.id.equals(id))).write(
          const ExercisesCompanion(deprecated: Value(true)),
        );
      }
      await db
          .into(db.catalogMeta)
          .insertOnConflictUpdate(
            CatalogMetaCompanion.insert(key: catalogVersionKey, value: version),
          );
      return deprecated;
    });
  });

  static ExercisesCompanion _toCompanion(Exercise e) =>
      ExercisesCompanion.insert(
        id: e.id,
        name: e.name,
        description: e.description,
        origin: e.origin.wire,
        type: e.type.wire,
        allowedStagesJson: jsonEncode([for (final s in e.allowedStages) s.wire]),
        allowedLevelsJson: jsonEncode(e.allowedLevels),
        allowedIntensitiesJson: jsonEncode(e.allowedIntensities),
        emphasesJson: jsonEncode(e.emphases),
        loadCharacter: e.loadCharacter.wire,
        variantsJson: jsonEncode([for (final v in e.variants) variantToJson(v)]),
        videoUrl: Value(e.videoUrl),
        videoAuthorName: Value(e.videoAuthorName),
        authorPageUrl: Value(e.authorPageUrl),
        deprecated: e.deprecated,
      );

  static Exercise _fromRow(ExerciseRow row) => exerciseFromJson({
    'id': row.id,
    'name': row.name,
    'description': row.description,
    'origin': row.origin,
    'type': row.type,
    'allowedStages': jsonDecode(row.allowedStagesJson),
    'allowedLevels': jsonDecode(row.allowedLevelsJson),
    'allowedIntensities': jsonDecode(row.allowedIntensitiesJson),
    'emphases': jsonDecode(row.emphasesJson),
    'loadCharacter': row.loadCharacter,
    'variants': jsonDecode(row.variantsJson),
    'videoUrl': row.videoUrl,
    'videoAuthorName': row.videoAuthorName,
    'authorPageUrl': row.authorPageUrl,
    'deprecated': row.deprecated,
  });
}

final class DriftTrainingPlanRepository implements TrainingPlanRepository {
  DriftTrainingPlanRepository(this.db);

  final AppDatabase db;

  @override
  Future<List<SavedPlanSummary>> findAllSummaries() =>
      throw UnimplementedError('TrainingPlanRepository.findAllSummaries');

  @override
  Future<SavedPlan?> findById(String id) =>
      throw UnimplementedError('TrainingPlanRepository.findById');

  @override
  Future<void> insert(SavedPlan plan) =>
      throw UnimplementedError('TrainingPlanRepository.insert');

  @override
  Future<void> update(SavedPlan plan) =>
      throw UnimplementedError('TrainingPlanRepository.update');

  @override
  Future<void> delete(String id) =>
      throw UnimplementedError('TrainingPlanRepository.delete');
}

final class DriftCompletedTrainingRepository
    implements CompletedTrainingRepository {
  DriftCompletedTrainingRepository(this.db);

  final AppDatabase db;

  @override
  Future<List<CompletedTrainingSummary>> findAllSummaries() =>
      throw UnimplementedError('CompletedTrainingRepository.findAllSummaries');

  @override
  Future<CompletedTraining?> findById(String id) =>
      throw UnimplementedError('CompletedTrainingRepository.findById');

  @override
  Future<List<CompletedTraining>> findByLocalStartDate(
    LocalDate from,
    LocalDate to,
  ) => throw UnimplementedError(
    'CompletedTrainingRepository.findByLocalStartDate',
  );

  @override
  Future<void> insert(CompletedTraining training) =>
      throw UnimplementedError('CompletedTrainingRepository.insert');
}
