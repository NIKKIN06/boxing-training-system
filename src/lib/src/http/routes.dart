/// 27 routes of spec/openapi.yaml, one per operationId. Handlers only decode the
/// request, call the service and encode the response.
library;

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../application/catalog_service.dart';
import '../application/open_plan_service.dart';
import '../application/plan_generation_service.dart';
import '../application/training_plan_service.dart';
import '../application/training_services.dart';
import 'middleware.dart';
import 'request_decoder.dart';
import 'response_encoder.dart';

/// Application services used by the HTTP layer.
final class Services {
  const Services({
    required this.catalog,
    required this.generation,
    required this.openPlans,
    required this.trainingPlans,
    required this.currentSession,
    required this.completedTrainings,
    required this.analytics,
  });

  final CatalogService catalog;
  final PlanGenerationService generation;
  final OpenPlanService openPlans;
  final TrainingPlanService trainingPlans;
  final CurrentSessionService currentSession;
  final CompletedTrainingService completedTrainings;
  final AnalyticsService analytics;
}

/// operationIds in the order of spec/openapi.yaml.
const List<String> operationIds = [
  'listExercises',
  'createExercise',
  'getExercise',
  'updateExercise',
  'getDictionary',
  'generatePlan',
  'openSavedPlan',
  'getOpenPlan',
  'renameOpenPlan',
  'addOpenPlanItem',
  'replaceOpenPlanItem',
  'updateOpenPlanItem',
  'deleteOpenPlanItem',
  'listTrainingPlans',
  'saveNewTrainingPlan',
  'getTrainingPlan',
  'overwriteTrainingPlan',
  'deleteTrainingPlan',
  'startCurrentSession',
  'getCurrentSession',
  'abortCurrentSession',
  'updateExecutedPlanItem',
  'deleteExecutedPlanItem',
  'completeTraining',
  'listCompletedTrainings',
  'getCompletedTraining',
  'getAnalytics',
];

Router buildRouter(
  Services s, {
  RequestDecoder decode = const RequestDecoder(),
  ResponseEncoder encode = const ResponseEncoder(),
}) {
  final router = Router();

  void route(
    String method,
    String path,
    String operationId,
    Future<Response> Function(Request request) handler,
  ) {
    router.add(method, path, operation(operationId, handler));
  }

  String p(Request request, String name) => request.params[name]!;

  // exercises, variants (REQ-F-001…REQ-F-004)
  route('GET', '/exercises', 'listExercises', (r) async {
    final filter = decode.exerciseFilter(r.url.queryParametersAll);
    return encode.exerciseList(await s.catalog.listExercises(filter));
  });
  route('POST', '/exercises', 'createExercise', (r) async {
    final input = decode.exerciseInput(await r.readAsString());
    return encode.exerciseCreated(await s.catalog.createExercise(input));
  });
  route('GET', '/exercises/<exerciseId>', 'getExercise', (r) async {
    return encode.exercise(await s.catalog.getExercise(p(r, 'exerciseId')));
  });
  route('PUT', '/exercises/<exerciseId>', 'updateExercise', (r) async {
    final input = decode.exerciseInput(await r.readAsString());
    return encode.exercise(
      await s.catalog.updateExercise(p(r, 'exerciseId'), input),
    );
  });

  // dictionaries (SRS §4.4)
  route('GET', '/dictionaries/<dictionaryName>', 'getDictionary', (r) async {
    final name = decode.dictionaryName(p(r, 'dictionaryName'));
    return encode.dictionary(await s.catalog.getDictionary(name));
  });

  // plan-generations (REQ-F-005…REQ-F-009)
  route('POST', '/plan-generations', 'generatePlan', (r) async {
    final params = decode.generationParameters(await r.readAsString());
    return encode.openPlanCreated(await s.generation.generatePlan(params));
  });

  // open-plans, items (REQ-F-010, REQ-F-011)
  route('POST', '/open-plans', 'openSavedPlan', (r) async {
    final sourcePlanId = decode.sourcePlanId(await r.readAsString());
    return encode.openPlanCreated(
      await s.openPlans.openSavedPlan(sourcePlanId),
    );
  });
  route('GET', '/open-plans/<openPlanId>', 'getOpenPlan', (r) async {
    return encode.openPlan(await s.openPlans.getOpenPlan(p(r, 'openPlanId')));
  });
  route('PATCH', '/open-plans/<openPlanId>', 'renameOpenPlan', (r) async {
    final name = decode.planName(await r.readAsString());
    return encode.openPlan(
      await s.openPlans.renameOpenPlan(p(r, 'openPlanId'), name),
    );
  });
  route('POST', '/open-plans/<openPlanId>/items', 'addOpenPlanItem', (r) async {
    final item = decode.planItemCreate(await r.readAsString());
    final (plan, itemId) = await s.openPlans.addOpenPlanItem(
      p(r, 'openPlanId'),
      item,
    );
    return encode.openPlanItemCreated(plan, itemId);
  });
  route(
    'PUT',
    '/open-plans/<openPlanId>/items/<itemId>',
    'replaceOpenPlanItem',
    (r) async {
      final item = decode.planItemReplace(await r.readAsString());
      return encode.openPlan(
        await s.openPlans.replaceOpenPlanItem(
          p(r, 'openPlanId'),
          p(r, 'itemId'),
          item,
        ),
      );
    },
  );
  route(
    'PATCH',
    '/open-plans/<openPlanId>/items/<itemId>',
    'updateOpenPlanItem',
    (r) async {
      final patch = decode.planItemPatch(await r.readAsString());
      return encode.openPlan(
        await s.openPlans.updateOpenPlanItem(
          p(r, 'openPlanId'),
          p(r, 'itemId'),
          patch,
        ),
      );
    },
  );
  route(
    'DELETE',
    '/open-plans/<openPlanId>/items/<itemId>',
    'deleteOpenPlanItem',
    (r) async {
      return encode.openPlan(
        await s.openPlans.deleteOpenPlanItem(
          p(r, 'openPlanId'),
          p(r, 'itemId'),
        ),
      );
    },
  );

  // training-plans (REQ-F-011)
  route('GET', '/training-plans', 'listTrainingPlans', (r) async {
    return encode.trainingPlanList(await s.trainingPlans.listTrainingPlans());
  });
  route('POST', '/training-plans', 'saveNewTrainingPlan', (r) async {
    final openPlanId = decode.openPlanId(await r.readAsString());
    return encode.savedPlanCreated(
      await s.trainingPlans.saveNewTrainingPlan(openPlanId),
    );
  });
  route('GET', '/training-plans/<planId>', 'getTrainingPlan', (r) async {
    return encode.savedPlan(
      await s.trainingPlans.getTrainingPlan(p(r, 'planId')),
    );
  });
  route('PUT', '/training-plans/<planId>', 'overwriteTrainingPlan', (r) async {
    final openPlanId = decode.openPlanId(await r.readAsString());
    return encode.savedPlan(
      await s.trainingPlans.overwriteTrainingPlan(p(r, 'planId'), openPlanId),
    );
  });
  route('DELETE', '/training-plans/<planId>', 'deleteTrainingPlan', (r) async {
    await s.trainingPlans.deleteTrainingPlan(p(r, 'planId'));
    return encode.noContent();
  });

  // current-session, executed-plan (REQ-F-012, REQ-F-013)
  route('POST', '/current-session', 'startCurrentSession', (r) async {
    final openPlanId = decode.openPlanId(await r.readAsString());
    return encode.currentSessionCreated(
      await s.currentSession.startCurrentSession(openPlanId),
    );
  });
  route('GET', '/current-session', 'getCurrentSession', (r) async {
    return encode.currentSession(await s.currentSession.getCurrentSession());
  });
  route('DELETE', '/current-session', 'abortCurrentSession', (r) async {
    await s.currentSession.abortCurrentSession();
    return encode.noContent();
  });
  route(
    'PATCH',
    '/current-session/executed-plan/items/<itemId>',
    'updateExecutedPlanItem',
    (r) async {
      final params = decode.executedItemParameters(await r.readAsString());
      return encode.currentSession(
        await s.currentSession.updateExecutedPlanItem(p(r, 'itemId'), params),
      );
    },
  );
  route(
    'DELETE',
    '/current-session/executed-plan/items/<itemId>',
    'deleteExecutedPlanItem',
    (r) async {
      return encode.currentSession(
        await s.currentSession.deleteExecutedPlanItem(p(r, 'itemId')),
      );
    },
  );

  // completed-trainings (REQ-F-013, REQ-F-014)
  route('POST', '/completed-trainings', 'completeTraining', (r) async {
    final note = decode.trainingNote(await r.readAsString());
    return encode.completedTrainingCreated(
      await s.completedTrainings.completeTraining(note),
    );
  });
  route('GET', '/completed-trainings', 'listCompletedTrainings', (r) async {
    return encode.completedTrainingList(
      await s.completedTrainings.listCompletedTrainings(),
    );
  });
  route('GET', '/completed-trainings/<trainingId>', 'getCompletedTraining', (
    r,
  ) async {
    return encode.completedTraining(
      await s.completedTrainings.getCompletedTraining(p(r, 'trainingId')),
    );
  });

  // analytics (REQ-F-015, REQ-F-016)
  route('GET', '/analytics', 'getAnalytics', (r) async {
    final period = decode.analyticsPeriod(r.url.queryParametersAll);
    return encode.analytics(
      await s.analytics.getAnalytics(from: period.from, to: period.to),
    );
  });

  return router;
}
