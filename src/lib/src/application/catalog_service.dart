/// Catalog and shared dictionaries (REQ-F-001…REQ-F-004).
/// T-10 skeleton: signatures only, every operation throws [UnimplementedError].
library;

import '../domain/catalog.dart';
import '../domain/enums.dart';
import '../domain/exercise.dart';
import '../ports/repositories.dart';
import '../ports/system_ports.dart';

final class CatalogService {
  CatalogService({
    required this.exercises,
    required this.catalogSource,
    required this.ids,
  });

  final ExerciseRepository exercises;
  final CatalogSource catalogSource;
  final IdGenerator ids;

  /// operationId `listExercises` (REQ-F-001, REQ-F-003).
  Future<List<ExerciseSummary>> listExercises(ExerciseFilter filter) =>
      throw UnimplementedError('listExercises');

  /// operationId `createExercise` (REQ-F-002, REQ-F-004).
  Future<Exercise> createExercise(ExerciseInput input) =>
      throw UnimplementedError('createExercise');

  /// operationId `getExercise` (REQ-F-001, REQ-F-004).
  Future<Exercise> getExercise(String exerciseId) =>
      throw UnimplementedError('getExercise');

  /// operationId `updateExercise` (REQ-F-002, D-05, D-33).
  Future<Exercise> updateExercise(String exerciseId, ExerciseInput input) =>
      throw UnimplementedError('updateExercise');

  /// operationId `getDictionary` (REQ-F-003, REQ-F-005).
  Future<Dictionary> getDictionary(DictionaryName name) =>
      throw UnimplementedError('getDictionary');
}
