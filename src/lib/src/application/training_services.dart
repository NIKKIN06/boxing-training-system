/// Current session, completed trainings and analytics (REQ-F-012…REQ-F-016).
/// T-10 skeleton: signatures only, every operation throws [UnimplementedError].
library;

import '../domain/plan.dart';
import '../domain/training.dart';
import '../ports/repositories.dart';
import '../ports/system_ports.dart';

/// Current session (REQ-F-012, REQ-F-013; D-19).
final class CurrentSessionService {
  CurrentSessionService({
    required this.openPlans,
    required this.session,
    required this.clock,
  });

  final OpenPlanStore openPlans;
  final CurrentSessionStore session;
  final Clock clock;

  /// operationId `startCurrentSession`.
  Future<CurrentSession> startCurrentSession(String openPlanId) =>
      throw UnimplementedError('startCurrentSession');

  /// operationId `getCurrentSession`.
  Future<CurrentSession> getCurrentSession() =>
      throw UnimplementedError('getCurrentSession');

  /// operationId `abortCurrentSession`.
  Future<void> abortCurrentSession() =>
      throw UnimplementedError('abortCurrentSession');

  /// operationId `updateExecutedPlanItem`.
  Future<CurrentSession> updateExecutedPlanItem(
    String itemId,
    ParametersInput parameters,
  ) => throw UnimplementedError('updateExecutedPlanItem');

  /// operationId `deleteExecutedPlanItem`.
  Future<CurrentSession> deleteExecutedPlanItem(String itemId) =>
      throw UnimplementedError('deleteExecutedPlanItem');
}

/// Completed trainings and history (REQ-F-013, REQ-F-014; REQ-NF-003).
final class CompletedTrainingService {
  CompletedTrainingService({
    required this.trainings,
    required this.session,
    required this.ids,
  });

  final CompletedTrainingRepository trainings;
  final CurrentSessionStore session;
  final IdGenerator ids;

  /// operationId `completeTraining`.
  Future<CompletedTraining> completeTraining(String? note) =>
      throw UnimplementedError('completeTraining');

  /// operationId `listCompletedTrainings`.
  Future<List<CompletedTrainingSummary>> listCompletedTrainings() =>
      throw UnimplementedError('listCompletedTrainings');

  /// operationId `getCompletedTraining`.
  Future<CompletedTraining> getCompletedTraining(String trainingId) =>
      throw UnimplementedError('getCompletedTraining');
}

/// Analytics (REQ-F-015, REQ-F-016; ADD-002 D-35).
final class AnalyticsService {
  AnalyticsService({required this.trainings, required this.clock});

  final CompletedTrainingRepository trainings;
  final Clock clock;

  /// operationId `getAnalytics`; [from] and [to] are both set or both absent.
  Future<Analytics> getAnalytics({LocalDate? from, LocalDate? to}) =>
      throw UnimplementedError('getAnalytics');
}
