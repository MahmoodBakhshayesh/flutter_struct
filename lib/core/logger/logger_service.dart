import 'dart:developer';

import 'package:flutter/foundation.dart';

enum LogLevel { none, error, warning, info, debug }

class LoggerService {
  LoggerService._();
  static final LoggerService instance = LoggerService._();

  LogLevel _level = LogLevel.debug;
  bool _showTimestamp = true;
  String _tag = 'APP';

  void configure({
    LogLevel level = LogLevel.debug,
    bool showTimestamp = true,
    String tag = 'APP',
  }) {
    _level = level;
    _showTimestamp = showTimestamp;
    _tag = tag;
  }

  // Public API
  void d(String message) => _log(LogLevel.debug, message);
  void i(String message) => _log(LogLevel.info, message);
  void w(String message) => _log(LogLevel.warning, message);
  void e(String message, [Object? error, StackTrace? st]) =>
      _log(LogLevel.error, message, error: error, stack: st);

  // Internals
  void _log(LogLevel level, String msg, {Object? error, StackTrace? stack}) {
    // if (_level == LogLevel.none) return;
    // if (!_allows(level)) return;
    if(level == LogLevel.warning) {
      log(msg);
    }
    return;
    final ts = _showTimestamp ? _now() : '';
    final lvl = _label(level);
    final base = '$_tag $lvl ${ts.isEmpty ? '' : '[$ts]'} $msg';

    if (error != null) {
      debugPrint('$base | error: $error');
    } else {
      debugPrint(base);
    }
    if (stack != null) {
      debugPrint(stack.toString());
    }
  }

  bool _allows(LogLevel level) {
    // Order: debug < info < warning < error
    int rank(LogLevel l) => switch (l) {
      LogLevel.debug => 0,
      LogLevel.info => 1,
      LogLevel.warning => 2,
      LogLevel.error => 3,
      LogLevel.none => 99,
    };
    return rank(level) >= rank(_level); // show if >= configured level
  }

  String _label(LogLevel l) => switch (l) {
    LogLevel.debug => '[D]',
    LogLevel.info => '[I]',
    LogLevel.warning => '[W]',
    LogLevel.error => '[E]',
    LogLevel.none => '',
  };

  String _now() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final ms = n.millisecond.toString().padLeft(3, '0');
    return '${two(n.hour)}:${two(n.minute)}:${two(n.second)}.$ms';
  }
}

// Convenience global (avoid name clash with dart:developer.log)
final appLog = LoggerService.instance;
