/// Logging (lab 5 rules; stage 1, decision 3):
/// - every request: method, operationId, status, duration;
/// - key service operations: entity ids and result;
/// - validation errors: `code`, level WARNING;
/// - exceptions: level ERROR with stack trace;
/// - contents of user fields (names, notes) are never logged;
/// - files are written only locally to logs/app/ (REQ-NF-004).
library;

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;

/// Logger names used by the components.
abstract final class LogNames {
  static const String server = 'server';
  static const String app = 'app';
  static const String http = 'http';
  static const String catalog = 'catalog';
  static const String storage = 'storage';
  static const String plans = 'plans';
  static const String trainings = 'trainings';
}

/// Description of an exception for an ERROR record (REQ-NF-004; stage 1,
/// decision 3): the type and, for SQLite, the result code and its
/// explanation — never the text of the exception, which may contain field
/// contents (the text of [SqliteException] includes the SQL statement and
/// its parameters; finding of group 3). With `NativeDatabase.createInBackground`
/// the SQLite error arrives wrapped in `DriftRemoteException`, so only its
/// type is logged. The stack trace is logged separately.
String safeErrorDescription(Object error) => switch (error) {
  SqliteException() =>
    'SqliteException(${error.extendedResultCode}): ${error.message}'
        '${error.explanation == null ? '' : ', ${error.explanation}'}',
  _ => error.runtimeType.toString(),
};

/// Level names used in log files: INFO / WARNING / ERROR (lab 5 rules).
String levelName(Level level) {
  if (level >= Level.SEVERE) return 'ERROR';
  if (level >= Level.WARNING) return 'WARNING';
  return level.name;
}

/// One record as one or more lines: timestamp, level, logger, message,
/// then the error and the stack trace when present.
String formatRecord(LogRecord record) {
  final buffer = StringBuffer()
    ..write(record.time.toUtc().toIso8601String())
    ..write(' ')
    ..write(levelName(record.level))
    ..write(' ')
    ..write(record.loggerName)
    ..write(': ')
    ..write(record.message);
  if (record.error != null) {
    buffer
      ..write('\n  error: ')
      ..write(record.error);
  }
  if (record.stackTrace != null) {
    buffer
      ..write('\n  stack:\n')
      ..write(record.stackTrace.toString().trimRight());
  }
  buffer.write('\n');
  return buffer.toString();
}

/// A subscription to the root logger that can be detached.
final class LogSink {
  LogSink._(this._subscription, this.file);

  /// Appends every record to `<directory>/<fileName>` synchronously, so the
  /// file is complete even if the process stops abruptly.
  factory LogSink.file({
    required String directory,
    required String fileName,
    Level level = Level.INFO,
  }) {
    final dir = Directory(directory)..createSync(recursive: true);
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    Logger.root.level = level;
    final subscription = Logger.root.onRecord.listen(
      (record) => file.writeAsStringSync(
        formatRecord(record),
        mode: FileMode.append,
        flush: true,
      ),
    );
    return LogSink._(subscription, file);
  }

  /// Echoes records to stdout.
  factory LogSink.stdout({Level level = Level.INFO}) {
    Logger.root.level = level;
    final subscription = Logger.root.onRecord.listen(
      (record) => stdout.write(formatRecord(record)),
    );
    return LogSink._(subscription, null);
  }

  final StreamSubscription<LogRecord> _subscription;

  /// Target file, `null` for stdout.
  final File? file;

  Future<void> close() => _subscription.cancel();
}
