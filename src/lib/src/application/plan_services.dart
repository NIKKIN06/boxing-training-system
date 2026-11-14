/// Plan generation, open plans and saved plans (REQ-F-005…REQ-F-011).
/// Group 2: generatePlan, getOpenPlan (T-36…T-39); group 3: open plan
/// editing (T-41) and saved plans (T-42).
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
import 'plan_generator.dart';

final Logger _log = Logger(LogNames.plans);

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

  /// operationId `generatePlan`: on success an open plan with `name: null`
  /// and `sourcePlanId: null` in memory (ADD-002 D-30, D-32); not saved
  /// automatically (D-17). On any failure no open plan is created.
  Future<OpenPlan> generatePlan(GenerationParameters parameters) async {
    // T-36, AC-F-005: parameters are checked before the search (BDD-006).
    final details = validateGenerationParameters(parameters);
    if (details.isNotEmpty) {
      throw DomainError(ErrorCode.validationFailed, details: details);
    }
    final target = targetDurationSeconds(parameters.targetDuration);
    final catalog = await exercises.findAll();

    final GenerationResult result;
    try {
      result = PlanGenerator(
        clock: clock,
        random: random,
      ).generate(catalog, parameters, target);
    } on DomainError catch (error) {
      _log.info(
        'plan not generated targetSeconds=$target code=${error.code.wire} '
        'reasons=[${error.reasons.map((r) => '${r.code.wire}${r.stage == null ? '' : ':${r.stage!.wire}'}').join(',')}]',
      );
      rethrow;
    } on Object catch (error, stackTrace) {
      // A technical failure differs from impossibility (AC-F-009 p. 5).
      _log.severe(
        'plan generation failed targetSeconds=$target',
        safeErrorDescription(error),
        stackTrace,
      );
      throw const DomainError(ErrorCode.generationFailed);
    }

    final stages = [
      for (final s in Stage.values)
        PlanStage(
          stage: s,
          items: [
            for (final (i, g) in result.stages[s]!.indexed)
              PlanItem(
                id: ids.newId(EntityKind.planItem),
                exerciseId: g.candidate.exercise.id,
                exerciseName: g.candidate.exercise.name,
                variant: g.candidate.variant,
                stage: s,
                position: i,
                parameters: g.parameters,
                estimatedDurationSeconds: itemDurationSeconds(g.parameters),
              ),
          ],
        ),
    ];
    final plan = OpenPlan(
      id: ids.newId(EntityKind.openPlan),
      sourcePlanId: null,
      content: PlanContent(
        name: null,
        generationParameters: parameters,
        targetDurationSeconds: target,
        durationTolerance: durationTolerance(target),
        stages: stages,
        estimatedDurationSeconds: planDurationSeconds(stages),
        // A generated plan satisfies the tolerance and the filters by
        // construction, so it has no warnings (AC-F-010).
        warnings: const [],
      ),
    );
    openPlans.put(plan);
    _log.info(
      'plan generated openPlanId=${plan.id} targetSeconds=$target '
      'totalSeconds=${plan.content.estimatedDurationSeconds} '
      'items=${stages.map((s) => s.items.length).join('/')} '
      'checkedSelections=${result.checkedSelections}',
    );
    return plan;
  }
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
      content: withName(open.content, name),
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
      _newItem(
        itemId,
        current.exerciseId,
        current.exerciseName,
        current.variant,
        parameters,
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

PlanContent withName(PlanContent c, String? name) => PlanContent(
  name: name,
  generationParameters: c.generationParameters,
  targetDurationSeconds: c.targetDurationSeconds,
  durationTolerance: c.durationTolerance,
  stages: c.stages,
  estimatedDurationSeconds: c.estimatedDurationSeconds,
  warnings: c.warnings,
);

/// T-41, AC-F-010: after a change — stages in the fixed order, positions
/// 0…n−1, the total by §5.4 and the warnings: FILTER_MISMATCH per item and
/// attribute against the source parameters (D-14), STAGE_EMPTY per empty
/// stage, DURATION_OUT_OF_TOLERANCE when the exact total is outside ±10 %.
/// STAGE_NOT_IN_EXERCISE is optional («якщо воно відображається») and is not
/// produced (stage 7, decision on question 3).
Future<PlanContent> recomputePlan(
  PlanContent base,
  List<List<PlanItem>> lists,
  ExerciseRepository exercises,
) async {
  final stages = renumberStages(lists);
  final catalog = {for (final e in await exercises.findAll()) e.id: e};
  final params = base.generationParameters;
  final total = planDurationSeconds(stages);
  final tolerance = base.durationTolerance;
  final warnings = <PlanWarning>[
    for (final s in stages)
      for (final i in s.items)
        if (catalog[i.exerciseId] case final e?)
          for (final a in filterMismatches(e, i.variant, s.stage, params))
            PlanWarning(
              code: PlanWarningCode.filterMismatch,
              itemId: i.id,
              attribute: a,
            ),
    for (final s in stages)
      if (s.items.isEmpty)
        PlanWarning(code: PlanWarningCode.stageEmpty, stage: s.stage),
    if (total < tolerance.minSeconds || total > tolerance.maxSeconds)
      const PlanWarning(code: PlanWarningCode.durationOutOfTolerance),
  ];
  return PlanContent(
    name: base.name,
    generationParameters: params,
    targetDurationSeconds: base.targetDurationSeconds,
    durationTolerance: tolerance,
    stages: stages,
    estimatedDurationSeconds: total,
    warnings: warnings,
  );
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
    await _write(() => trainingPlans.insert(saved));
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
    await _write(() => trainingPlans.update(saved));
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
    await _write(() => trainingPlans.delete(planId));
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
      content: withName(
        open.content,
        name == null || name.isEmpty ? defaultPlanName(now) : name,
      ),
    );
  }

  /// REQ-NF-003: a failed write → 500 STORAGE_WRITE_FAILED, previous state kept.
  static Future<void> _write(Future<void> Function() write) async {
    try {
      await write();
    } on StorageWriteException {
      throw const DomainError(ErrorCode.storageWriteFailed);
    }
  }
}
