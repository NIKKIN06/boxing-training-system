/// Drift implementations of the storage ports.
/// T-10 skeleton: signatures only, every method throws [UnimplementedError].
library;

import '../domain/exercise.dart';
import '../domain/plan.dart';
import '../domain/training.dart';
import '../ports/repositories.dart';
import 'database.dart';

final class DriftExerciseRepository implements ExerciseRepository {
  DriftExerciseRepository(this.db);

  final AppDatabase db;

  @override
  Future<List<Exercise>> findAll() =>
      throw UnimplementedError('ExerciseRepository.findAll');

  @override
  Future<Exercise?> findById(String id) =>
      throw UnimplementedError('ExerciseRepository.findById');

  @override
  Future<void> insert(Exercise exercise) =>
      throw UnimplementedError('ExerciseRepository.insert');

  @override
  Future<void> update(Exercise exercise) =>
      throw UnimplementedError('ExerciseRepository.update');
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
