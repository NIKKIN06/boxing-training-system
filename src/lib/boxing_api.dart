/// Local REST API of the boxing training system (spec/openapi.yaml; ADD-002 D-28).
library;

export 'src/application/catalog_service.dart';
export 'src/application/open_plan_service.dart';
export 'src/application/plan_generation_service.dart';
export 'src/application/training_plan_service.dart';
export 'src/application/training_services.dart';
export 'src/composition_root.dart';
export 'src/config/app_config.dart';
export 'src/domain/catalog.dart';
export 'src/domain/domain_error.dart';
export 'src/domain/enums.dart';
export 'src/domain/exercise.dart';
export 'src/domain/plan.dart';
export 'src/domain/training.dart';
export 'src/http/routes.dart' show operationIds;
export 'src/logging/app_logging.dart';
export 'src/ports/system_ports.dart';
