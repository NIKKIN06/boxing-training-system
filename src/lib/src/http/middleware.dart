/// Per-operation wrapper and request logging (stage 1, decision 3).
library;

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

import '../domain/domain_error.dart';
import '../logging/app_logging.dart';
import 'json_mapping.dart';

/// Response context key carrying the operationId to the request logger.
const String operationIdContextKey = 'boxing_api.operationId';

/// operationId logged for requests that matched no route.
const String unmatchedOperationId = '-';

final Logger _httpLog = Logger(LogNames.http);

/// Runs [inner] as the operation [operationId] and maps exceptions:
/// - [DomainError] → its contract status and an `Error` body, WARNING with the
///   code and the field paths of `details` (never field values);
/// - [UnimplementedError] (T-10 stub) → 501 without a body, WARNING;
/// - any other exception → 500 without a body, ERROR with the stack trace and
///   [safeErrorDescription] (type and SQLite code, never the exception text).
///
/// 501 is not part of spec/openapi.yaml: it marks a not yet implemented
/// operation of the skeleton. No error `code` outside the contract is sent
/// (stage 1, decision 7).
Handler operation(String operationId, Handler inner) {
  return (request) async {
    Response response;
    try {
      response = await inner(request);
    } on DomainError catch (error) {
      final status = errorStatus(error.code, operationId);
      final details = [
        for (final d in error.details) '${d.field}:${d.constraint}',
      ];
      _httpLog.warning(
        'domain error operationId=$operationId code=${error.code.wire} '
        'status=$status details=[${details.join(',')}]',
      );
      response = jsonResponse(status, errorBody(error));
    } on UnimplementedError catch (error) {
      _httpLog.warning(
        'not implemented operationId=$operationId stub="${error.message}"',
      );
      response = Response(501);
    } catch (error, stackTrace) {
      _httpLog.severe(
        'unhandled exception operationId=$operationId',
        safeErrorDescription(error),
        stackTrace,
      );
      response = Response(500);
    }
    return response.change(context: {operationIdContextKey: operationId});
  };
}

/// Logs one INFO line per request: method, operationId, status, duration.
/// Query strings and bodies are not logged (user field contents).
Middleware requestLogging() {
  return (inner) {
    return (request) async {
      final stopwatch = Stopwatch()..start();
      Response response;
      try {
        response = await inner(request);
      } catch (error, stackTrace) {
        _httpLog.severe(
          'unhandled exception outside operation',
          safeErrorDescription(error),
          stackTrace,
        );
        response = Response(500);
      }
      final operationId =
          response.context[operationIdContextKey] as String? ??
          unmatchedOperationId;
      _httpLog.info(
        'request method=${request.method} operationId=$operationId '
        'status=${response.statusCode} '
        'durationMs=${stopwatch.elapsedMilliseconds}',
      );
      return response;
    };
  };
}
