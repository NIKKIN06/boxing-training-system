/// Plan generation, open plans and saved plans (REQ-F-005…REQ-F-011).
/// Group 2: generatePlan, getOpenPlan (T-36…T-39). Other operations still
/// throw [UnimplementedError].
library;

import 'package:logging/logging.dart';

import '../domain/domain_error.dart';
import '../domain/enums.dart';
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
      _log.severe('plan generation failed targetSeconds=$target', error, stackTrace);
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

  /// operationId `openSavedPlan`.
  Future<OpenPlan> openSavedPlan(String sourcePlanId) =>
      throw UnimplementedError('openSavedPlan');

  /// operationId `getOpenPlan`; after a restart an unsaved open plan is gone
  /// → 404 (ADD-002 D-30; stage 1, decision 4).
  Future<OpenPlan> getOpenPlan(String openPlanId) async {
    final plan = openPlans.findById(openPlanId);
    if (plan == null) throw const DomainError(ErrorCode.notFound);
    return plan;
  }

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
