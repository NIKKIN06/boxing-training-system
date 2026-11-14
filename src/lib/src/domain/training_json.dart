/// Wire form of the current session and completed trainings (schemas
/// `ExecutedPlan`, `CurrentSession`, `CompletedTraining`,
/// `CompletedTrainingListItem` of spec/openapi.yaml). Decoding is for
/// trusted stored copies only.
library;

import 'exercise_json.dart';
import 'plan_json.dart';
import 'training.dart';

/// `format: date` — `YYYY-MM-DD`.
String localDateToJson(LocalDate d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

LocalDate localDateFromJson(String raw) {
  final parts = raw.split('-');
  if (parts.length != 3) throw FormatException('Expected YYYY-MM-DD', raw);
  return LocalDate(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

JsonMap executedPlanToJson(ExecutedPlan p) => {
  'stages': stagesToJson(p.stages),
};

ExecutedPlan executedPlanFromJson(Object? raw) =>
    ExecutedPlan(stages: stagesFromJson((raw! as JsonMap)['stages']));

JsonMap currentSessionToJson(CurrentSession s) => {
  'startedAt': dateTimeToJson(s.startedAt),
  'localStartDate': localDateToJson(s.localStartDate),
  'executedPlan': executedPlanToJson(s.executedPlan),
};

JsonMap completedTrainingToJson(CompletedTraining t) => {
  'id': t.id,
  'startedAt': dateTimeToJson(t.startedAt),
  'localStartDate': localDateToJson(t.localStartDate),
  'executedPlan': executedPlanToJson(t.executedPlan),
  'note': t.note,
};
