/// Wire form of plans (schemas `GenerationParameters`, `PlanItem`,
/// `PlanStage`, `PlanWarning`, `Plan`, `OpenPlan`, `SavedPlan` of
/// spec/openapi.yaml). Decoding is for trusted stored copies only; a
/// malformed value throws.
library;

import 'enums.dart';
import 'exercise_json.dart';
import 'plan.dart';

/// `date-time` with an explicit offset: the moment in UTC.
String dateTimeToJson(DateTime t) => t.toUtc().toIso8601String();

JsonMap savedPlanToJson(SavedPlan p) => {
  'id': p.id,
  'modifiedAt': dateTimeToJson(p.modifiedAt),
  ...planContentToJson(p.content),
};

GenerationParameters generationParametersFromJson(Object? raw) {
  final m = raw! as JsonMap;
  final t = m['targetDuration']! as JsonMap;
  return GenerationParameters(
    targetDuration: TargetDuration(
      hours: t['hours']! as int,
      minutes: t['minutes']! as int,
    ),
    level: m['level']! as String,
    emphasis: m['emphasis']! as String,
    availableEquipment: [
      for (final e in m['availableEquipment']! as List<Object?>) e! as String,
    ],
    intensity: m['intensity']! as String,
  );
}

PlanItemParameters itemParametersFromJson(Object? raw) {
  final m = raw! as JsonMap;
  if (m.containsKey('rounds')) {
    return TimeParameters(
      rounds: m['rounds']! as int,
      intervalSeconds: m['intervalSeconds']! as int,
      restSeconds: m['restSeconds']! as int,
    );
  }
  return RepetitionsParameters(
    sets: m['sets']! as int,
    repetitions: m['repetitions']! as int,
    restSeconds: m['restSeconds']! as int,
    repetitionTimeSeconds: m['repetitionTimeSeconds']! as int,
  );
}

PlanItem planItemFromJson(Object? raw) {
  final m = raw! as JsonMap;
  return PlanItem(
    id: m['id']! as String,
    exerciseId: m['exerciseId']! as String,
    exerciseName: m['exerciseName']! as String,
    variant: variantFromJson(m['variant']),
    stage: enumFromJson(Stage.values, m['stage']),
    position: m['position']! as int,
    parameters: itemParametersFromJson(m['parameters']),
    estimatedDurationSeconds: m['estimatedDurationSeconds']! as int,
  );
}

List<PlanStage> stagesFromJson(Object? raw) => [
  for (final s in (raw! as List<Object?>).cast<JsonMap>())
    PlanStage(
      stage: enumFromJson(Stage.values, s['stage']),
      items: [for (final i in s['items']! as List<Object?>) planItemFromJson(i)],
    ),
];

List<PlanWarning> warningsFromJson(Object? raw) => [
  for (final w in (raw! as List<Object?>).cast<JsonMap>())
    PlanWarning(
      code: enumFromJson(PlanWarningCode.values, w['code']),
      stage: w['stage'] == null ? null : enumFromJson(Stage.values, w['stage']),
      itemId: w['itemId'] as String?,
      attribute: w['attribute'] == null
          ? null
          : enumFromJson(WarningAttribute.values, w['attribute']),
    ),
];

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
  'stages': stagesToJson(c.stages),
  'estimatedDurationSeconds': c.estimatedDurationSeconds,
  'warnings': warningsToJson(c.warnings),
};

/// Stages with their items (schema `PlanStage`), shared by plans and
/// executed plans.
List<JsonMap> stagesToJson(List<PlanStage> stages) => [
  for (final s in stages)
    {
      'stage': s.stage.wire,
      'items': [for (final i in s.items) planItemToJson(i)],
    },
];

List<JsonMap> warningsToJson(List<PlanWarning> warnings) => [
  for (final w in warnings) planWarningToJson(w),
];

JsonMap openPlanToJson(OpenPlan p) => {
  'id': p.id,
  'sourcePlanId': p.sourcePlanId,
  ...planContentToJson(p.content),
};
