import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, fatal }

class AppLogger {
  static bool _initialized = false;

  static void init({
    LogLevel minimumLevel = LogLevel.debug,
    bool showTimestamp = true,
  }) {
    if (_initialized) return;
    _initialized = true;
    _minimumLevel = minimumLevel;
    _showTimestamp = showTimestamp;
    debug('Logger initialized at $minimumLevel level');
  }

  static late LogLevel _minimumLevel;
  static late bool _showTimestamp;

  static String _formatMessage(
    String message,
    LogLevel level,
    String? tag,
    StackTrace? stackTrace,
  ) {
    final timestamp =
        _showTimestamp ? '[${DateTime.now().toIso8601String()}] ' : '';
    final tagStr = tag != null ? '[$tag] ' : '';
    final levelStr = '[${level.name.toUpperCase()}]';

    final formatted = '$timestamp$levelStr $tagStr$message';

    if (stackTrace != null && kDebugMode) {
      return '$formatted\nStackTrace: $stackTrace';
    }

    return formatted;
  }

  static void _log(
    String message,
    LogLevel level,
    String? tag,
    StackTrace? stackTrace,
  ) {
    if (level.index < _minimumLevel.index) return;

    // En production solo mostramos si está habilitado el logging
    // (por ahora comentado porque AppLogger se inicializa antes que EnvironmentConfig)
    // if (EnvironmentConfig.current.isProduction &&
    //     !EnvironmentConfig.current.enableLogging) {
    //   return;
    // }

    final formatted = _formatMessage(message, level, tag, stackTrace);

    if (kDebugMode) {
      // En debug mode usamos print
      print(formatted);
    } else if (level == LogLevel.error || level == LogLevel.fatal) {
      // En release mode, solo los errores crítticos se registran
      // TODO: Integrar con Crashlytics si está disponible
      debugPrint(formatted);
    }
  }

  static void debug(
    String message, {
    String? tag,
    StackTrace? stackTrace,
  }) {
    _log(message, LogLevel.debug, tag, stackTrace);
  }

  static void info(
    String message, {
    String? tag,
    StackTrace? stackTrace,
  }) {
    _log(message, LogLevel.info, tag, stackTrace);
  }

  static void warning(
    String message, {
    String? tag,
    StackTrace? stackTrace,
  }) {
    _log(message, LogLevel.warning, tag, stackTrace);
  }

  static void error(
    String message, {
    String? tag,
    StackTrace? stackTrace,
    dynamic exception,
  }) {
    final msg = exception != null ? '$message: $exception' : message;
    _log(msg, LogLevel.error, tag, stackTrace);
  }

  static void fatal(
    String message, {
    String? tag,
    StackTrace? stackTrace,
    dynamic exception,
  }) {
    final msg = exception != null ? '$message: $exception' : message;
    _log(msg, LogLevel.fatal, tag, stackTrace);
    // TODO: Integrar con Crashlytics para fatal errors
  }
}
