/// Mapping between HTTP messages and domain types (spec/openapi.yaml).
///
/// Decoding includes the contract's 400 / 422 rules (BAD_REQUEST, VALIDATION_FAILED,
/// UNKNOWN_DICTIONARY_VALUE), which are verified by tests.
/// T-10 skeleton: signatures only, every method throws [UnimplementedError].
library;

import 'package:shelf/shelf.dart';

import '../domain/catalog.dart';
import '../domain/enums.dart';
import '../domain/exercise.dart';
import '../domain/plan.dart';
import '../domain/training.dart';

/// Request query and body decoding.
final class RequestDecoder {
  const RequestDecoder();

  ExerciseFilter exerciseFilter(Map<String, List<String>> query) =>
      throw UnimplementedError('decode ExerciseFilter');

  ExerciseInput exerciseInput(String body) =>
      throw UnimplementedError('decode ExerciseInput');

  DictionaryName dictionaryName(String raw) =>
      throw UnimplementedError('decode DictionaryName');

  GenerationParameters generationParameters(String body) =>
      throw UnimplementedError('decode PlanGenerationRequest');

  /// `OpenSavedPlanRequest.sourcePlanId`.
  String sourcePlanId(String body) =>
      throw UnimplementedError('decode OpenSavedPlanRequest');

  /// `OpenPlanPatchRequest.name`.
  String planName(String body) =>
      throw UnimplementedError('decode OpenPlanPatchRequest');

  PlanItemCreate planItemCreate(String body) =>
      throw UnimplementedError('decode PlanItemCreateRequest');

  PlanItemReplace planItemReplace(String body) =>
      throw UnimplementedError('decode PlanItemReplaceRequest');

  PlanItemPatch planItemPatch(String body) =>
      throw UnimplementedError('decode PlanItemPatchRequest');

  /// `SavePlanRequest.openPlanId` / `StartSessionRequest.openPlanId`.
  String openPlanId(String body) =>
      throw UnimplementedError('decode openPlanId request');

  /// `ExecutedPlanItemPatchRequest.parameters`.
  ParametersInput executedItemParameters(String body) =>
      throw UnimplementedError('decode ExecutedPlanItemPatchRequest');

  /// `CompleteTrainingRequest.note`.
  String? trainingNote(String body) =>
      throw UnimplementedError('decode CompleteTrainingRequest');

  /// Query parameters `from` / `to` of `getAnalytics` (ADD-002 D-35).
  ({LocalDate? from, LocalDate? to}) analyticsPeriod(
    Map<String, List<String>> query,
  ) => throw UnimplementedError('decode analytics period');
}

/// Success responses with status codes and `Location` headers of the contract.
final class ResponseEncoder {
  const ResponseEncoder();

  Response exerciseList(List<ExerciseSummary> items) =>
      throw UnimplementedError('encode ExerciseList');

  Response exerciseCreated(Exercise exercise) =>
      throw UnimplementedError('encode Exercise (201)');

  Response exercise(Exercise exercise) =>
      throw UnimplementedError('encode Exercise');

  Response dictionary(Dictionary dictionary) =>
      throw UnimplementedError('encode Dictionary');

  Response openPlanCreated(OpenPlan plan) =>
      throw UnimplementedError('encode OpenPlan (201)');

  Response openPlanItemCreated(OpenPlan plan) =>
      throw UnimplementedError('encode OpenPlan after addOpenPlanItem (201)');

  Response openPlan(OpenPlan plan) =>
      throw UnimplementedError('encode OpenPlan');

  Response trainingPlanList(List<SavedPlanSummary> items) =>
      throw UnimplementedError('encode TrainingPlanList');

  Response savedPlanCreated(SavedPlan plan) =>
      throw UnimplementedError('encode SavedPlan (201)');

  Response savedPlan(SavedPlan plan) =>
      throw UnimplementedError('encode SavedPlan');

  Response currentSessionCreated(CurrentSession session) =>
      throw UnimplementedError('encode CurrentSession (201)');

  Response currentSession(CurrentSession session) =>
      throw UnimplementedError('encode CurrentSession');

  Response completedTrainingCreated(CompletedTraining training) =>
      throw UnimplementedError('encode CompletedTraining (201)');

  Response completedTraining(CompletedTraining training) =>
      throw UnimplementedError('encode CompletedTraining');

  Response completedTrainingList(List<CompletedTrainingSummary> items) =>
      throw UnimplementedError('encode CompletedTrainingList');

  Response analytics(Analytics analytics) =>
      throw UnimplementedError('encode Analytics');

  /// 204 No Content.
  Response noContent() => throw UnimplementedError('encode 204');
}
