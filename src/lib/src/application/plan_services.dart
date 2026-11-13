/// Plan generation, open plans and saved plans (REQ-F-005…REQ-F-011).
/// T-10 skeleton: signatures only, every operation throws [UnimplementedError].
library;

import '../domain/plan.dart';
import '../ports/repositories.dart';
import '../ports/system_ports.dart';

/// Plan generation (REQ-F-005…REQ-F-009).
final class PlanGenerationService {
  PlanGenerationService({
    required this.exercises,
    required this.openPlans,
    required this.clock,
    required this.random,
    required this.ids,
  });

  final ExerciseRepository exercises;
  final OpenPlanStore openPlans;
  final Clock clock;
  final RandomSource random;
  final IdGenerator ids;

  /// operationId `generatePlan`.
  Future<OpenPlan> generatePlan(GenerationParameters parameters) =>
      throw UnimplementedError('generatePlan');
}

/// Open plan editing (REQ-F-010, REQ-F-011; ADD-002 D-30, D-32).
final class OpenPlanService {
  OpenPlanService({
    required this.exercises,
    required this.trainingPlans,
    required this.openPlans,
    required this.ids,
  });

  final ExerciseRepository exercises;
  final TrainingPlanRepository trainingPlans;
  final OpenPlanStore openPlans;
  final IdGenerator ids;

  /// operationId `openSavedPlan`.
  Future<OpenPlan> openSavedPlan(String sourcePlanId) =>
      throw UnimplementedError('openSavedPlan');

  /// operationId `getOpenPlan`.
  Future<OpenPlan> getOpenPlan(String openPlanId) =>
      throw UnimplementedError('getOpenPlan');

  /// operationId `renameOpenPlan`.
  Future<OpenPlan> renameOpenPlan(String openPlanId, String name) =>
      throw UnimplementedError('renameOpenPlan');

  /// operationId `addOpenPlanItem`.
  Future<OpenPlan> addOpenPlanItem(String openPlanId, PlanItemCreate item) =>
      throw UnimplementedError('addOpenPlanItem');

  /// operationId `replaceOpenPlanItem`.
  Future<OpenPlan> replaceOpenPlanItem(
    String openPlanId,
    String itemId,
    PlanItemReplace item,
  ) => throw UnimplementedError('replaceOpenPlanItem');

  /// operationId `updateOpenPlanItem`.
  Future<OpenPlan> updateOpenPlanItem(
    String openPlanId,
    String itemId,
    PlanItemPatch patch,
  ) => throw UnimplementedError('updateOpenPlanItem');

  /// operationId `deleteOpenPlanItem`.
  Future<OpenPlan> deleteOpenPlanItem(String openPlanId, String itemId) =>
      throw UnimplementedError('deleteOpenPlanItem');
}

/// Saved plans (REQ-F-011; D-16).
final class TrainingPlanService {
  TrainingPlanService({
    required this.trainingPlans,
    required this.openPlans,
    required this.clock,
    required this.ids,
  });

  final TrainingPlanRepository trainingPlans;
  final OpenPlanStore openPlans;
  final Clock clock;
  final IdGenerator ids;

  /// operationId `listTrainingPlans`.
  Future<List<SavedPlanSummary>> listTrainingPlans() =>
      throw UnimplementedError('listTrainingPlans');

  /// operationId `saveNewTrainingPlan`.
  Future<SavedPlan> saveNewTrainingPlan(String openPlanId) =>
      throw UnimplementedError('saveNewTrainingPlan');

  /// operationId `getTrainingPlan`.
  Future<SavedPlan> getTrainingPlan(String planId) =>
      throw UnimplementedError('getTrainingPlan');

  /// operationId `overwriteTrainingPlan`.
  Future<SavedPlan> overwriteTrainingPlan(String planId, String openPlanId) =>
      throw UnimplementedError('overwriteTrainingPlan');

  /// operationId `deleteTrainingPlan`.
  Future<void> deleteTrainingPlan(String planId) =>
      throw UnimplementedError('deleteTrainingPlan');
}
