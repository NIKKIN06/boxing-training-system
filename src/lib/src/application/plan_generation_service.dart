/// Plan generation (REQ-F-005…REQ-F-009). Group 2: generatePlan (T-36…T-39).
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
        'reasons=[${_reasonsForLog(error)}]',
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

    final plan = _toOpenPlan(result, parameters, target);
    openPlans.put(plan);
    _log.info(
      'plan generated openPlanId=${plan.id} targetSeconds=$target '
      'totalSeconds=${plan.content.estimatedDurationSeconds} '
      'items=${plan.content.stages.map((s) => s.items.length).join('/')} '
      'checkedSelections=${result.checkedSelections}',
    );
    return plan;
  }

  /// The open plan of a successful generation: item ids, positions 0…n−1
  /// and durations by §5.4.
  OpenPlan _toOpenPlan(
    GenerationResult result,
    GenerationParameters parameters,
    int target,
  ) {
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
    return OpenPlan(
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
  }

  /// `CODE` or `CODE:stage` per reason, comma-separated.
  static String _reasonsForLog(DomainError error) => error.reasons
      .map((r) => r.stage == null ? r.code.wire : '${r.code.wire}:${r.stage!.wire}')
      .join(',');
}
