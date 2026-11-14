/// Success responses of spec/openapi.yaml: status codes, JSON bodies and
/// `Location` headers.
library;

import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../domain/catalog.dart';
import '../domain/exercise.dart';
import '../domain/exercise_json.dart';
import '../domain/plan.dart';
import '../domain/plan_json.dart';
import '../domain/training.dart';
import '../domain/training_json.dart';

/// Success responses with status codes and `Location` headers of the contract.
final class ResponseEncoder {
  const ResponseEncoder();

  Response exerciseList(List<ExerciseSummary> items) => jsonResponse(200, {
    'items': [
      for (final e in items)
        {
          'id': e.id,
          'name': e.name,
          'type': e.type.wire,
          'origin': e.origin.wire,
        },
    ],
  });

  Response exerciseCreated(Exercise exercise) => jsonResponse(
    201,
    exerciseToJson(exercise),
    location: '/exercises/${Uri.encodeComponent(exercise.id)}',
  );

  Response exercise(Exercise exercise) =>
      jsonResponse(200, exerciseToJson(exercise));

  Response dictionary(Dictionary dictionary) =>
      jsonResponse(200, dictionaryToJson(dictionary));

  Response openPlanCreated(OpenPlan plan) => jsonResponse(
    201,
    openPlanToJson(plan),
    location: '/open-plans/${Uri.encodeComponent(plan.id)}',
  );

  /// `Location` — the created item (stage 7, decision on question 9).
  Response openPlanItemCreated(OpenPlan plan, String itemId) => jsonResponse(
    201,
    openPlanToJson(plan),
    location:
        '/open-plans/${Uri.encodeComponent(plan.id)}'
        '/items/${Uri.encodeComponent(itemId)}',
  );

  Response openPlan(OpenPlan plan) => jsonResponse(200, openPlanToJson(plan));

  Response trainingPlanList(List<SavedPlanSummary> items) => jsonResponse(200, {
    'items': [
      for (final p in items)
        {
          'id': p.id,
          'name': p.name,
          'modifiedAt': dateTimeToJson(p.modifiedAt),
        },
    ],
  });

  Response savedPlanCreated(SavedPlan plan) => jsonResponse(
    201,
    savedPlanToJson(plan),
    location: '/training-plans/${Uri.encodeComponent(plan.id)}',
  );

  Response savedPlan(SavedPlan plan) => jsonResponse(200, savedPlanToJson(plan));

  /// `Location: /current-session` (stage 7, decision on question 9).
  Response currentSessionCreated(CurrentSession session) => jsonResponse(
    201,
    currentSessionToJson(session),
    location: '/current-session',
  );

  Response currentSession(CurrentSession session) =>
      jsonResponse(200, currentSessionToJson(session));

  Response completedTrainingCreated(CompletedTraining training) => jsonResponse(
    201,
    completedTrainingToJson(training),
    location: '/completed-trainings/${Uri.encodeComponent(training.id)}',
  );

  Response completedTraining(CompletedTraining training) =>
      jsonResponse(200, completedTrainingToJson(training));

  Response completedTrainingList(List<CompletedTrainingSummary> items) =>
      jsonResponse(200, {
        'items': [
          for (final t in items)
            {'id': t.id, 'startedAt': dateTimeToJson(t.startedAt)},
        ],
      });

  Response analytics(Analytics a) => jsonResponse(200, {
    'period': {
      'from': localDateToJson(a.period.from),
      'to': localDateToJson(a.period.to),
    },
    'completedTrainingCount': a.completedTrainingCount,
    'dailyCounts': [
      for (final d in a.dailyCounts)
        {'date': localDateToJson(d.date), 'count': d.count},
    ],
    'exerciseFrequencies': [
      for (final f in a.exerciseFrequencies)
        {
          'exerciseId': f.exerciseId,
          'exerciseName': f.exerciseName,
          'trainingCount': f.trainingCount,
        },
    ],
  });

  /// 204 No Content.
  Response noContent() => Response(204);
}

/// `Content-Type` of every JSON response.
const String jsonContentType = 'application/json; charset=utf-8';

/// A JSON response; [location] is the URI of a created resource (201).
Response jsonResponse(int status, Object? body, {String? location}) => Response(
  status,
  body: jsonEncode(body),
  headers: {'content-type': jsonContentType, 'location': ?location},
);
