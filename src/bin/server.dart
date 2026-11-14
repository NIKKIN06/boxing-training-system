/// Starts the local API on 127.0.0.1 (ADD-002 D-28). Run from `src/`:
///
///   dart run bin/server.dart [--port=8080] [--db=.data/boxing_api.sqlite | --db=:memory:]
///       [--catalog=assets/catalog/test-catalog.json] [--log-dir=../logs/app]
///       [--log-file=api-YYYYMMDD-HHMMSS.log]
///
/// Port 4010 is used by the Prism proxy; the default port is 8080.
library;

import 'dart:async';
import 'dart:io';

import 'package:boxing_api/boxing_api.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<void> main(List<String> args) async {
  final AppConfig config;
  try {
    config = AppConfig.fromArgs(args);
  } on FormatException catch (error) {
    stderr.writeln('Invalid arguments: ${error.message} (${error.source})');
    exitCode = 64;
    return;
  }

  final fileSink = LogSink.file(
    directory: config.logDirectory,
    fileName: config.logFileName,
  );
  final consoleSink = LogSink.stdout();
  final log = Logger(LogNames.server);
  log.info('starting pid=$pid logFile=${fileSink.file!.path}');

  Future<void> closeSinks() async {
    await consoleSink.close();
    await fileSink.close();
  }

  /// A failed start: the application (if built) and the sinks are closed.
  Future<void> abort([App? app]) async {
    await app?.close();
    await closeSinks();
    exitCode = 1;
  }

  final App app;
  try {
    app = buildApp(config);
  } catch (error, stackTrace) {
    log.severe('startup failed', safeErrorDescription(error), stackTrace);
    return abort();
  }

  // T-32: requests are served only after the catalog is initialized; the
  // failure itself is logged at ERROR with the stack trace by buildApp.
  try {
    await app.initialized;
  } on Object {
    log.severe('startup aborted reason=catalog-initialization-failed');
    return abort(app);
  }

  final HttpServer server;
  try {
    server = await shelf_io.serve(app.handler, AppConfig.host, config.port);
  } catch (error, stackTrace) {
    log.severe('startup failed', safeErrorDescription(error), stackTrace);
    return abort(app);
  }
  log.info('listening host=${AppConfig.host} port=${server.port}');

  final stop = Completer<ProcessSignal>();
  final subscriptions = [
    ProcessSignal.sigint.watch().listen(
      (signal) => stop.isCompleted ? null : stop.complete(signal),
    ),
    ProcessSignal.sigterm.watch().listen(
      (signal) => stop.isCompleted ? null : stop.complete(signal),
    ),
  ];
  final signal = await stop.future;
  log.info('stopping signal=$signal');
  for (final subscription in subscriptions) {
    await subscription.cancel();
  }
  await server.close(force: true);
  await app.close();
  log.info('stopped');
  await closeSinks();
}
