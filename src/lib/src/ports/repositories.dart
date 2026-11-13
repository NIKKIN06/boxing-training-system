/// Storage ports. Persistent data — Drift / SQLite (CON-001, REQ-NF-002, REQ-NF-003);
/// open plans and the current session — memory only (ADD-002 D-29; stage 1, decision 4).
library;

import '../domain/catalog.dart';
import '../domain/exercise.dart';
import '../domain/plan.dart';
import '../domain/training.dart';

/// Source of the supplied versioned catalog (SRS §4.4; T-57).
abstract interface class CatalogSource {
  Future<CatalogData> load();
}

/// Catalog exercises: initial and custom (SRS §4.3.1).
abstract interface class ExerciseRepository {
  Future<List<Exercise>> findAll();
  Future<Exercise?> findById(String id);
  Future<void> insert(Exercise exercise);
  Future<void> update(Exercise exercise);
}

/// Saved training plans (REQ-F-011).
abstract interface class TrainingPlanRepository {
  Future<List<SavedPlanSummary>> findAllSummaries();
  Future<SavedPlan?> findById(String id);
  Future<void> insert(SavedPlan plan);
  Future<void> update(SavedPlan plan);
  Future<void> delete(String id);
}

/// Completed trainings (REQ-F-013, REQ-F-014).
abstract interface class CompletedTrainingRepository {
  Future<List<CompletedTrainingSummary>> findAllSummaries();
  Future<CompletedTraining?> findById(String id);
  Future<List<CompletedTraining>> findByLocalStartDate(
    LocalDate from,
    LocalDate to,
  );
  Future<void> insert(CompletedTraining training);
}

/// Open plans in memory (ADD-002 D-30).
abstract interface class OpenPlanStore {
  OpenPlan? findById(String id);
  void put(OpenPlan plan);
}

/// The only current session, in memory (REQ-F-012).
abstract interface class CurrentSessionStore {
  CurrentSession? get();
  void set(CurrentSession? session);
}
