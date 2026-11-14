/// Saved plans (REQ-F-011; D-16). Group 3: saved plans (T-42).
library;

import 'package:logging/logging.dart';

import '../domain/domain_error.dart';
import '../domain/enums.dart';
import '../domain/plan.dart';
import '../domain/plan_rules.dart';
import '../logging/app_logging.dart';
import '../ports/repositories.dart';
import '../ports/system_ports.dart';
import 'storage_write.dart';

final Logger _log = Logger(LogNames.plans);

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

  /// operationId `listTrainingPlans`: newer `modifiedAt` first (D-16, REV-009).
  Future<List<SavedPlanSummary>> listTrainingPlans() async {
    final items = await trainingPlans.findAllSummaries();
    _log.info('training plans listed count=${items.length}');
    return items;
  }

  /// operationId `saveNewTrainingPlan` (AC-F-011, D-14, D-16, D-32, AC-NF-003):
  /// the composition comes from the open plan; warnings do not block saving
  /// (BDD-014); an empty plan is not saved (BDD-033). Success is reported
  /// only after the write; then the open plan is linked to the new plan.
  Future<SavedPlan> saveNewTrainingPlan(String openPlanId) async {
    final open = _openForSave(openPlanId);
    if (open.sourcePlanId != null) {
      throw const DomainError(ErrorCode.openPlanAlreadySaved);
    }
    _requireNotEmpty(open);
    final saved = _saved(ids.newId(EntityKind.trainingPlan), open);
    await guardStorageWrite(() => trainingPlans.insert(saved));
    openPlans.put(
      OpenPlan(id: open.id, sourcePlanId: saved.id, content: saved.content),
    );
    _log.info(
      'training plan saved planId=${saved.id} openPlanId=${open.id} '
      'items=${itemCount(saved.content.stages)}',
    );
    return saved;
  }

  /// operationId `getTrainingPlan`: the stored copy, not rewritten by catalog
  /// changes (AC-F-011, SRS §4.5).
  Future<SavedPlan> getTrainingPlan(String planId) async {
    final plan = await trainingPlans.findById(planId);
    if (plan == null) throw const DomainError(ErrorCode.notFound);
    return plan;
  }

  /// operationId `overwriteTrainingPlan` (D-16, REV-009): the open plan must
  /// come from [planId]; an empty name gets the default name of this save.
  Future<SavedPlan> overwriteTrainingPlan(String planId, String openPlanId) async {
    final open = _openForSave(openPlanId);
    final existing = await trainingPlans.findById(planId);
    if (existing == null) throw const DomainError(ErrorCode.notFound);
    if (open.sourcePlanId != planId) {
      throw const DomainError(ErrorCode.openPlanSourceMismatch);
    }
    _requireNotEmpty(open);
    final saved = _saved(planId, open);
    await guardStorageWrite(() => trainingPlans.update(saved));
    openPlans.put(
      OpenPlan(id: open.id, sourcePlanId: planId, content: saved.content),
    );
    _log.info(
      'training plan overwritten planId=$planId openPlanId=${open.id} '
      'items=${itemCount(saved.content.stages)}',
    );
    return saved;
  }

  /// operationId `deleteTrainingPlan`: the history and the current session
  /// keep their own copies (SRS §4.5).
  Future<void> deleteTrainingPlan(String planId) async {
    final plan = await trainingPlans.findById(planId);
    if (plan == null) throw const DomainError(ErrorCode.notFound);
    await guardStorageWrite(() => trainingPlans.delete(planId));
    _log.info('training plan deleted planId=$planId');
  }

  OpenPlan _openForSave(String openPlanId) {
    final open = openPlans.findById(openPlanId);
    if (open == null) throw const DomainError(ErrorCode.openPlanNotFound);
    return open;
  }

  static void _requireNotEmpty(OpenPlan open) {
    if (itemCount(open.content.stages) == 0) {
      throw const DomainError(ErrorCode.planEmpty);
    }
  }

  /// `modifiedAt` and the default name use the moment of this save (REV-009,
  /// D-16, D-32).
  SavedPlan _saved(String id, OpenPlan open) {
    final now = clock.now();
    final name = open.content.name;
    return SavedPlan(
      id: id,
      modifiedAt: now,
      content: open.content.copyWith(
        name: name == null || name.isEmpty ? defaultPlanName(now) : name,
      ),
    );
  }
}
