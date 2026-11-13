/// Wire form of plans (schemas `GenerationParameters`, `PlanItem`,
/// `PlanStage`, `PlanWarning`, `Plan`, `OpenPlan` of spec/openapi.yaml).
library;

import 'exercise_json.dart';
import 'plan.dart';

JsonMap generationParametersToJson(GenerationParameters p) => {
  'targetDuration': {
    'hours': p.targetDuration.hours,
    'minutes': p.targetDuration.minutes,
  },
  'level': p.level,
  'emphasis': p.emphasis,
  'availableEquipment': p.availableEquipment,
  'intensity': p.intensity,
};

JsonMap itemParametersToJson(PlanItemParameters p) => switch (p) {
  TimeParameters() => {
    'rounds': p.rounds,
    'intervalSeconds': p.intervalSeconds,
    'restSeconds': p.restSeconds,
  },
  RepetitionsParameters() => {
    'sets': p.sets,
    'repetitions': p.repetitions,
    'restSeconds': p.restSeconds,
    'repetitionTimeSeconds': p.repetitionTimeSeconds,
  },
};

JsonMap planItemToJson(PlanItem i) => {
  'id': i.id,
  'exerciseId': i.exerciseId,
  'exerciseName': i.exerciseName,
  'variant': variantToJson(i.variant),
  'stage': i.stage.wire,
  'position': i.position,
  'parameters': itemParametersToJson(i.parameters),
  'estimatedDurationSeconds': i.estimatedDurationSeconds,
};

JsonMap planWarningToJson(PlanWarning w) => {
  'code': w.code.wire,
  'stage': ?w.stage?.wire,
  'itemId': ?w.itemId,
  'attribute': ?w.attribute?.wire,
};

JsonMap planContentToJson(PlanContent c) => {
  'name': c.name,
  'generationParameters': generationParametersToJson(c.generationParameters),
  'targetDurationSeconds': c.targetDurationSeconds,
  'durationTolerance': {
    'minSeconds': c.durationTolerance.minSeconds,
    'maxSeconds': c.durationTolerance.maxSeconds,
  },
  'stages': [
    for (final s in c.stages)
      {
        'stage': s.stage.wire,
        'items': [for (final i in s.items) planItemToJson(i)],
      },
  ],
  'estimatedDurationSeconds': c.estimatedDurationSeconds,
  'warnings': [for (final w in c.warnings) planWarningToJson(w)],
};

JsonMap openPlanToJson(OpenPlan p) => {
  'id': p.id,
  'sourcePlanId': p.sourcePlanId,
  ...planContentToJson(p.content),
};
