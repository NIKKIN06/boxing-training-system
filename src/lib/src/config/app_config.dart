/// Composition-root configuration (stage 1 of lab 5; ADD-002 D-28).
///
/// The server listens only on 127.0.0.1; the host is not configurable. Port 4010
/// is reserved for the Prism proxy, so the default port differs from it.
/// Relative default paths assume the process is started from `src/`.
library;

final class AppConfig {
  const AppConfig({
    required this.catalogPath,
    required this.logDirectory,
    required this.logFileName,
    this.port = defaultPort,
    this.databasePath = defaultDatabasePath,
  });

  /// Parses `--port=`, `--db=`, `--catalog=`, `--log-dir=`, `--log-file=`.
  /// Throws [FormatException] on an unknown option or an invalid port.
  factory AppConfig.fromArgs(List<String> args, {DateTime? startedAt}) {
    var port = defaultPort;
    var databasePath = defaultDatabasePath;
    var catalogPath = defaultCatalogPath;
    var logDirectory = defaultLogDirectory;
    String? logFileName;
    for (final arg in args) {
      final separator = arg.indexOf('=');
      if (!arg.startsWith('--') || separator < 0) {
        throw FormatException('Expected --option=value', arg);
      }
      final name = arg.substring(2, separator);
      final value = arg.substring(separator + 1);
      switch (name) {
        case 'port':
          final parsed = int.tryParse(value);
          if (parsed == null || parsed < 0 || parsed > 65535) {
            throw FormatException('Invalid port', value);
          }
          port = parsed;
        case 'db':
          databasePath = value;
        case 'catalog':
          catalogPath = value;
        case 'log-dir':
          logDirectory = value;
        case 'log-file':
          logFileName = value;
        default:
          throw FormatException('Unknown option', arg);
      }
    }
    return AppConfig(
      port: port,
      databasePath: databasePath,
      catalogPath: catalogPath,
      logDirectory: logDirectory,
      logFileName:
          logFileName ?? defaultLogFileName(startedAt ?? DateTime.now()),
    );
  }

  static const String host = '127.0.0.1';
  static const int defaultPort = 8080;

  /// Value of `--db` that selects an in-memory database.
  static const String inMemoryDatabase = ':memory:';
  static const String defaultDatabasePath = '.data/boxing_api.sqlite';
  static const String defaultCatalogPath = 'assets/catalog/test-catalog.json';

  /// Logs are written only locally (REQ-NF-004; stage 1, decision 3).
  static const String defaultLogDirectory = '../logs/app';

  /// `api-YYYYMMDD-HHMMSS.log` in local time.
  static String defaultLogFileName(DateTime at) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'api-${at.year}${two(at.month)}${two(at.day)}'
        '-${two(at.hour)}${two(at.minute)}${two(at.second)}.log';
  }

  final int port;
  final String databasePath;
  final String catalogPath;
  final String logDirectory;
  final String logFileName;

  bool get isInMemoryDatabase => databasePath == inMemoryDatabase;
}
