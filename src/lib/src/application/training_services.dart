/// Current session, completed trainings and analytics (REQ-F-012…REQ-F-016).
/// Group 4: current session, completion, history (T-44, T-45, T-46);
/// group 5: analytics (T-47).
library;

import 'package:logging/logging.dart';

import '../domain/analytics_rules.dart';
import '../domain/domain_error.dart';
import '../domain/enums.dart';
import '../domain/plan.dart';
import '../domain/plan_rules.dart';
import '../domain/training.dart';
import '../domain/training_json.dart';
import '../logging/app_logging.dart';
import '../ports/repositories.dart';
import '../ports/system_ports.dart';
import 'storage_write.dart';

final Logger _log = Logger(LogNames.trainings);

/// Current session (REQ-F-012, REQ-F-013; D-17, D-18, D-19).
final class CurrentSessionService {
  CurrentSessionService({
    required this.openPlans,
    required this.session,
    required this.clock,
  });

  final OpenPlanStore openPlans;
  final CurrentSessionStore session;
  final Clock clock;

  /// operationId `startCurrentSession` (T-44, AC-F-012): from any open plan,
  /// saved or not, without saving it (D-17); `startedAt` and the local start
  /// date are fixed now; the executed plan is a working copy. Only one
  /// current session (AC-F-012 p. 4): its data are never overwritten.
  Future<CurrentSession> startCurrentSession(String openPlanId) async {
    if (session.get() != null) {
      throw const DomainError(ErrorCode.sessionAlreadyActive);
    }
    final open = openPlans.findById(openPlanId);
    if (open == null) throw const DomainError(ErrorCode.openPlanNotFound);
    if (itemCount(open.content.stages) == 0) {
      throw const DomainError(ErrorCode.planEmpty);
    }
    final now = clock.now();
    final started = CurrentSession(
      startedAt: now,
      localStartDate: localDateOf(now),
      executedPlan: ExecutedPlan(stages: open.content.stages),
    );
    session.set(started);
    _log.info(
      'session started openPlanId=${open.id} '
      'sourcePlanId=${open.sourcePlanId ?? '-'} '
      'items=${_count(started.executedPlan)}',
    );
    return started;
  }

  /// operationId `getCurrentSession`; none after a restart (D-18).
  Future<CurrentSession> getCurrentSession() async => _current();

  /// operationId `abortCurrentSession` (AC-F-013): the session is closed
  /// without a record; history, analytics and the saved plan do not change.
  Future<void> abortCurrentSession() async {
    final current = _current();
    session.set(null);
    _log.info('session aborted items=${_count(current.executedPlan)}');
  }

  /// operationId `updateExecutedPlanItem` (T-45, D-19): actual values —
  /// integers ≥ 1 (rest ≥ 0), the variant limits do not apply; only fields of
  /// the variant mode.
  Future<CurrentSession> updateExecutedPlanItem(
    String itemId,
    ParametersInput parameters,
  ) async {
    final current = _current();
    final lists = stageWorkingLists(current.executedPlan.stages);
    final (s, i) = locateItem(lists, itemId);
    final item = lists[s][i];
    final (resolved, details) = resolveItemParameters(
      item.variant,
      parameters,
      current: item.parameters,
      withinVariant: false,
    );
    if (details.isNotEmpty) {
      throw DomainError(ErrorCode.validationFailed, details: details);
    }
    lists[s][i] = item.copyWith(
      parameters: resolved!,
      estimatedDurationSeconds: itemDurationSeconds(resolved),
    );
    final updated = _with(current, lists);
    _log.info('executed item updated itemId=$itemId');
    return updated;
  }

  /// operationId `deleteExecutedPlanItem` (D-19): a full emptying is allowed
  /// (BDD-028); the open plan does not change.
  Future<CurrentSession> deleteExecutedPlanItem(String itemId) async {
    final current = _current();
    final lists = stageWorkingLists(current.executedPlan.stages);
    final (s, i) = locateItem(lists, itemId);
    lists[s].removeAt(i);
    final updated = _with(current, lists);
    _log.info(
      'executed item deleted itemId=$itemId '
      'left=${_count(updated.executedPlan)}',
    );
    return updated;
  }

  CurrentSession _current() {
    final current = session.get();
    if (current == null) throw const DomainError(ErrorCode.noCurrentSession);
    return current;
  }

  /// Stores the changed executed plan with positions 0…n−1.
  CurrentSession _with(CurrentSession current, List<List<PlanItem>> lists) {
    final updated = CurrentSession(
      startedAt: current.startedAt,
      localStartDate: current.localStartDate,
      executedPlan: ExecutedPlan(stages: renumberStages(lists)),
    );
    session.set(updated);
    return updated;
  }
}

int _count(ExecutedPlan p) => itemCount(p.stages);

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

  /// operationId `completeTraining` (T-45, AC-F-013): one record with the
  /// start time, the executed plan and the note; afterwards there is no
  /// current session, so a repeated request gives 409 NO_CURRENT_SESSION and
  /// no duplicate. An empty executed plan or a failed write keeps the session.
  Future<CompletedTraining> completeTraining(String? note) async {
    final current = session.get();
    if (current == null) throw const DomainError(ErrorCode.noCurrentSession);
    if (_count(current.executedPlan) == 0) {
      throw const DomainError(ErrorCode.executedPlanEmpty);
    }
    final record = CompletedTraining(
      id: ids.newId(EntityKind.completedTraining),
      startedAt: current.startedAt,
      localStartDate: current.localStartDate,
      executedPlan: current.executedPlan,
      note: note,
    );
    await guardStorageWrite(() => trainings.insert(record));
    session.set(null);
    _log.info(
      'training completed trainingId=${record.id} '
      'localStartDate=${localDateToJson(record.localStartDate)} '
      'items=${_count(record.executedPlan)} note=${note != null}',
    );
    return record;
  }

  /// operationId `listCompletedTrainings` (T-46, AC-F-014): newer start first.
  Future<List<CompletedTrainingSummary>> listCompletedTrainings() async {
    final items = await trainings.findAllSummaries();
    _log.info('completed trainings listed count=${items.length}');
    return items;
  }

  /// operationId `getCompletedTraining` (T-46, D-20): the stored read-only
  /// copy; catalog changes do not alter it (BDD-017).
  Future<CompletedTraining> getCompletedTraining(String trainingId) async {
    final record = await trainings.findById(trainingId);
    if (record == null) throw const DomainError(ErrorCode.notFound);
    return record;
  }
}

/// Analytics (REQ-F-015, REQ-F-016; ADD-002 D-35).
final class AnalyticsService {
  AnalyticsService({required this.trainings, required this.clock});

  final CompletedTrainingRepository trainings;
  final Clock clock;

  /// operationId `getAnalytics` (T-47): only completed trainings are counted
  /// (the current session is not, BDD-019); the day is the local start date.
  Future<Analytics> getAnalytics({LocalDate? from, LocalDate? to}) async {
    final period = resolvePeriod(from, to, localDateOf(clock.now()));
    final records = await trainings.findByLocalStartDate(
      period.from,
      period.to,
    );
    final analytics = computeAnalytics(period, records);
    _log.info(
      'analytics computed from=${localDateToJson(period.from)} '
      'to=${localDateToJson(period.to)} '
      'trainings=${analytics.completedTrainingCount} '
      'exercises=${analytics.exerciseFrequencies.length}',
    );
    return analytics;
  }
}
