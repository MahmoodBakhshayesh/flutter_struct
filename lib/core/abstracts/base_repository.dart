import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart' show CancelToken;
import '../logger/logger_service.dart';
import '../networking/network_manager.dart';

// If you prefer DI over the singleton, expose the manager via a provider:
final networkManagerProvider = Provider<NetworkManager>((ref) => NetworkManager.instance);

abstract class BaseRepository {
  BaseRepository();


  // --- Access your networking layer (either DI or singleton)
  @protected
  NetworkManager get nm => NetworkManager.instance;
  // or: NetworkManager get nm => NetworkManager.instance;

  // --- Logging helpers
  @protected
  void logD(String msg) => appLog.d('[$runtimeType] $msg');
  @protected
  void logI(String msg) => appLog.i('[$runtimeType] $msg');
  @protected
  void logW(String msg) => appLog.w('[$runtimeType] $msg');
  @protected
  void logE(String msg, [Object? e, StackTrace? st]) => appLog.e('[$runtimeType] $msg', e, st);

  // --- Guard & retry
  @protected
  Future<T> guard<T>(Future<T> Function() run, {String op = 'op', bool logSuccess = false}) async {
    final sw = Stopwatch()..start();
    try {
      final v = await run();
      sw.stop();
      if (logSuccess) logI('$op ✅ in ${sw.elapsedMilliseconds}ms');
      return v;
    } catch (e, st) {
      sw.stop();
      logE('$op ❌ in ${sw.elapsedMilliseconds}ms', e, st);
      rethrow;
    }
  }

  @protected
  Future<T> withRetry<T>(
      Future<T> Function(int attempt) run, {
        int maxAttempts = 2,
        Duration Function(int attempt)? delayFor,
        bool Function(Object error)? canRetry,
        String op = 'retry',
      }) async {
    delayFor ??= (n) => Duration(milliseconds: 200 * n);
    canRetry ??= (_) => true;
    Object? last; StackTrace? lastSt;

    for (var a = 1; a <= maxAttempts; a++) {
      try {
        return await run(a);
      } catch (e, st) {
        last = e; lastSt = st;
        if (a >= maxAttempts || !canRetry(e)) {
          logE('$op failed after $a/$maxAttempts', e, st);
          rethrow;
        }
        final d = delayFor(a);
        logW('$op attempt $a failed, retrying in ${d.inMilliseconds}ms…');
        await Future<void>.delayed(d);
      }
    }
    // should not reach
    // ignore: only_throw_errors
    throw last ?? StateError('$op failed with no error');
  }

  // --- Tiny utils
  @protected
  String ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  @protected
  Map<String, String> qp(Map<String, String?> raw) {
    final out = <String, String>{};
    raw.forEach((k, v) { if (v != null) out[k] = v; });
    return out;
  }

  @protected
  List<T> mapList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    final list = (data as List).cast<Map<String, dynamic>>();
    return list.map(fromJson).toList(growable: false);
  }

  @protected
  Map<String, dynamic> asJsonMap(dynamic data) =>
      (data as Map).cast<String, dynamic>();
}
