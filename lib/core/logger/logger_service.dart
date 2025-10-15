import 'package:logger/logger.dart';

/// Centralized logging service built on top of the `logger` package.
///
/// Provides:
/// - Pretty console logging in debug.
/// - Optional release filtering.
/// - Static access via [log] shortcut.
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  /// Internal `Logger` instance.
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Logs only in debug mode (won’t spam release builds).
  bool enableInRelease = false;

  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_shouldLog) _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_shouldLog) _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_shouldLog) _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_shouldLog) _logger.e(message, error: error, stackTrace: stackTrace);
  }

  bool get _shouldLog {
    const inDebug = bool.fromEnvironment('dart.vm.product') == false;
    return inDebug || enableInRelease;
  }

  /// Quick access singleton
  static LoggerService get I => _instance;
}

/// Shortcut global logger.
/// Example: `log.d("hello world")`
final log = LoggerService.I;
