/// Open plans (REQ-F-010, REQ-F-011). Group 2: getOpenPlan (T-36…T-39);
/// group 3: open plan editing (T-41).
library;

import 'package:logging/logging.dart';

import '../domain/domain_error.dart';
import '../domain/enums.dart';
import '../domain/exercise.dart';
import '../domain/plan.dart';
import '../domain/plan_rules.dart';
import '../logging/app_logging.dart';
import '../ports/repositories.dart';
import '../ports/system_ports.dart';

final Logger _log = Logger(LogNames.plans);

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

  /// operationId `openSavedPlan`: a working copy of the saved plan with its
  /// name, stages, warnings and `sourcePlanId` (D-16, ADD-002 D-30); items
  /// with deprecated exercises stay (D-06).
  Future<OpenPlan> openSavedPlan(String sourcePlanId) async {
    final saved = await trainingPlans.findById(sourcePlanId);
    if (saved == null) throw const DomainError(ErrorCode.planNotFound);
    final plan = OpenPlan(
      id: ids.newId(EntityKind.openPlan),
      sourcePlanId: saved.id,
      content: saved.content,
    );
    openPlans.put(plan);
    _log.info('saved plan opened openPlanId=${plan.id} planId=${saved.id}');
    return plan;
  }

  /// operationId `getOpenPlan`; after a restart an unsaved open plan is gone
  /// → 404 (ADD-002 D-30; stage 1, decision 4).
  Future<OpenPlan> getOpenPlan(String openPlanId) async {
    final plan = openPlans.findById(openPlanId);
    if (plan == null) throw const DomainError(ErrorCode.notFound);
    return plan;
  }

  /// operationId `renameOpenPlan`: an empty name is allowed and replaced by
  /// the default name on saving (D-16); a generated plan may get a name
  /// before the first save (ADD-002 D-32). `modifiedAt` of a saved plan is
  /// not changed (REV-009).
  Future<OpenPlan> renameOpenPlan(String openPlanId, String name) async {
    final open = _open(openPlanId);
    final plan = OpenPlan(
      id: open.id,
      sourcePlanId: open.sourcePlanId,
      content: open.content.copyWith(name: name),
    );
    openPlans.put(plan);
    _log.info('open plan renamed openPlanId=${plan.id} empty=${name.isEmpty}');
    return plan;
  }

  /// operationId `addOpenPlanItem` (AC-F-010): any stage regardless of the
  /// exercise's stages; without a position — at the end of the stage; the
  /// same variant may be added again (D-15); not a deprecated exercise (D-06).
  /// Returns the plan and the id of the new item.
  Future<(OpenPlan, String)> addOpenPlanItem(
    String openPlanId,
    PlanItemCreate request,
  ) async {
    final open = _open(openPlanId);
    final (exercise, variant) = await _selectable(
      request.exerciseId,
      request.variantId,
    );
    final lists = stageWorkingLists(open.content.stages);
    final target = lists[request.stage.index];
    final (parameters, details) = resolveItemParameters(
      variant,
      request.parameters,
    );
    final position = request.position ?? target.length;
    if (position > target.length) details.add(_positionOutside);
    if (details.isNotEmpty) {
      throw DomainError(ErrorCode.validationFailed, details: details);
    }
    final item = _newItem(
      ids.newId(EntityKind.planItem),
      exercise.id,
      exercise.name,
      variant,
      parameters!,
    );
    target.insert(position, item);
    final plan = await _store(open, lists);
    _log.info(
      'open plan item added openPlanId=${plan.id} itemId=${item.id} '
      'stage=${request.stage.wire} position=$position',
    );
    return (plan, item.id);
  }

  /// operationId `replaceOpenPlanItem` (AC-F-010): the item keeps its id,
  /// stage and position; any non-deprecated exercise may be chosen.
  Future<OpenPlan> replaceOpenPlanItem(
    String openPlanId,
    String itemId,
    PlanItemReplace request,
  ) async {
    final open = _open(openPlanId);
    final lists = stageWorkingLists(open.content.stages);
    final (s, i) = locateItem(lists, itemId);
    final (exercise, variant) = await _selectable(
      request.exerciseId,
      request.variantId,
    );
    final (parameters, details) = resolveItemParameters(
      variant,
      request.parameters,
    );
    if (details.isNotEmpty) {
      throw DomainError(ErrorCode.validationFailed, details: details);
    }
    lists[s][i] = _newItem(
      itemId,
      exercise.id,
      exercise.name,
      variant,
      parameters!,
    );
    final plan = await _store(open, lists);
    _log.info('open plan item replaced openPlanId=${plan.id} itemId=$itemId');
    return plan;
  }

  /// operationId `updateOpenPlanItem` (AC-F-010, BDD-013, BDD-023, BDD-032):
  /// parameters within `[min; max]` of the item's variant copy, `e` is not
  /// editable (D-08); order within a stage and moving to any stage; the order
  /// of the stages and other items' parameters do not change. Moving to
  /// another stage without a position puts the item at its end.
  Future<OpenPlan> updateOpenPlanItem(
    String openPlanId,
    String itemId,
    PlanItemPatch patch,
  ) async {
    final open = _open(openPlanId);
    final lists = stageWorkingLists(open.content.stages);
    final (s, i) = locateItem(lists, itemId);
    final current = lists[s][i];
    final details = <ErrorDetail>[];
    var parameters = current.parameters;
    final input = patch.parameters;
    if (input != null) {
      final (resolved, errors) = resolveItemParameters(
        current.variant,
        input,
        current: current.parameters,
      );
      details.addAll(errors);
      if (resolved != null) parameters = resolved;
    }
    final targetStage = patch.stage ?? current.stage;
    lists[s].removeAt(i);
    final target = lists[targetStage.index];
    final position =
        patch.position ?? (targetStage == current.stage ? i : target.length);
    if (position > target.length) details.add(_positionOutside);
    if (details.isNotEmpty) {
      throw DomainError(ErrorCode.validationFailed, details: details);
    }
    target.insert(
      position,
      current.copyWith(
        parameters: parameters,
        estimatedDurationSeconds: itemDurationSeconds(parameters),
      ),
    );
    final plan = await _store(open, lists);
    _log.info(
      'open plan item updated openPlanId=${plan.id} itemId=$itemId '
      'parameters=${input != null} stage=${targetStage.wire} position=$position',
    );
    return plan;
  }

  /// operationId `deleteOpenPlanItem`: emptying a stage gives STAGE_EMPTY;
  /// an entirely empty open plan is allowed but cannot be saved (BDD-033).
  Future<OpenPlan> deleteOpenPlanItem(String openPlanId, String itemId) async {
    final open = _open(openPlanId);
    final lists = stageWorkingLists(open.content.stages);
    final (s, i) = locateItem(lists, itemId);
    lists[s].removeAt(i);
    final plan = await _store(open, lists);
    _log.info('open plan item deleted openPlanId=${plan.id} itemId=$itemId');
    return plan;
  }

  static const ErrorDetail _positionOutside = ErrorDetail(
    field: 'position',
    constraint: Constraint.maximum,
  );

  OpenPlan _open(String openPlanId) {
    final open = openPlans.findById(openPlanId);
    if (open == null) throw const DomainError(ErrorCode.notFound);
    return open;
  }

  /// NEG-14, NEG-15, NEG-16: the exercise exists and is not deprecated
  /// (D-06); the variant belongs to it (D-33).
  Future<(Exercise, Variant)> _selectable(
    String exerciseId,
    String variantId,
  ) async {
    final exercise = await exercises.findById(exerciseId);
    if (exercise == null) throw const DomainError(ErrorCode.exerciseNotFound);
    if (exercise.deprecated) {
      throw const DomainError(ErrorCode.exerciseDeprecated);
    }
    for (final v in exercise.variants) {
      if (v.id == variantId) return (exercise, v);
    }
    throw const DomainError(ErrorCode.variantNotFound);
  }

  /// A copy of the exercise name and of the variant (SRS §4.5).
  static PlanItem _newItem(
    String id,
    String exerciseId,
    String exerciseName,
    Variant variant,
    PlanItemParameters parameters,
  ) => PlanItem(
    id: id,
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    variant: variant,
    stage: Stage.warmUp,
    position: 0,
    parameters: parameters,
    estimatedDurationSeconds: itemDurationSeconds(parameters),
  );

  Future<OpenPlan> _store(OpenPlan open, List<List<PlanItem>> lists) async {
    final plan = OpenPlan(
      id: open.id,
      sourcePlanId: open.sourcePlanId,
      content: await recomputePlan(open.content, lists, exercises),
    );
    openPlans.put(plan);
    return plan;
  }
}

/// T-41, AC-F-010: after a change — stages in the fixed order, positions
/// 0…n−1, the total by §5.4 and the warnings of [planWarnings] against the
/// current catalog.
Future<PlanContent> recomputePlan(
  PlanContent base,
  List<List<PlanItem>> lists,
  ExerciseRepository exercises,
) async {
  final stages = renumberStages(lists);
  final catalog = {for (final e in await exercises.findAll()) e.id: e};
  final total = planDurationSeconds(stages);
  return base.copyWith(
    stages: stages,
    estimatedDurationSeconds: total,
    warnings: planWarnings(
      stages: stages,
      catalog: catalog,
      parameters: base.generationParameters,
      tolerance: base.durationTolerance,
      totalSeconds: total,
    ),
  );
}
