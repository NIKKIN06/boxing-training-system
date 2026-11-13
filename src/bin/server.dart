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

  final App app;
  final HttpServer server;
  try {
    app = buildApp(config);
    server = await shelf_io.serve(app.handler, AppConfig.host, config.port);
  } catch (error, stackTrace) {
    log.severe('startup failed', error, stackTrace);
    await consoleSink.close();
    await fileSink.close();
    exitCode = 1;
    return;
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
  await consoleSink.close();
  await fileSink.close();
}
