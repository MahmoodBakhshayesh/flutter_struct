// lib/core/network/dio_network_manager.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../logger/logger_service.dart';
import 'dart:developer' as dev;

/// =========================================================================
/// ENUMS & TYPEDEFS
/// =========================================================================

/// Safer than strings for HTTP methods.
enum HttpMethod { get, post, put, patch, delete, upload, download }

extension HttpMethodName on HttpMethod {
  String get name => toString().split('.').last.toUpperCase();
}

/// Retry strategy (expandable later).
enum RetryPolicy { none, exponential }

/// Logging levels for NetworkManager.
enum NetworkLogLevel { none, basic, full }

typedef NetworkHook = void Function(NetworkRequest req, NetworkResponse res);
typedef NetworkCheck = bool Function(NetworkRequest req, NetworkResponse res);
typedef NetworkMessageExtractor = String? Function(Map<String, dynamic> json);

/// =========================================================================
/// EXCEPTION TYPE (used when throwOnFailure is true — default)
/// =========================================================================
class NetworkException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;   // server body if any
  final dynamic raw;    // raw Dio Response or DioException
  final bool tokenExpired;

  NetworkException({
    required this.message,
    this.statusCode,
    this.data,
    this.raw,
    this.tokenExpired = false,
  });

  @override
  String toString() =>
      'NetworkException(code: $statusCode, tokenExpired: $tokenExpired, message: $message)\n raw: $raw';
}

/// =========================================================================
/// MAIN MANAGER (Singleton)
/// =========================================================================
class NetworkManager {
  static final NetworkManager instance = NetworkManager._internal();
  factory NetworkManager() => instance;
  NetworkManager._internal();

  late final Dio _dio;
  bool _initialized = false;

  // Global settings
  String baseUrl = '';
  Duration connectTimeout = const Duration(seconds: 10);
  Duration receiveTimeout = const Duration(seconds: 25);
  Map<String, dynamic>? defaultHeaders;
  bool enableLogs = true;
  NetworkLogLevel logLevel = NetworkLogLevel.basic;
  RetryPolicy retryPolicy = RetryPolicy.exponential;
  int maxRetries = 2;

  /// NEW: by default, failures throw NetworkException
  bool throwOnFailureGlobal = true;

  // Token
  String? _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;
  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  // Hooks
  void Function(NetworkRequest req)? onStart;
  NetworkHook? onEnd;
  NetworkHook? onSuccess;
  NetworkHook? onFailed;
  NetworkHook? onTokenExpire;

  // Checks
  NetworkCheck? successCheck;
  NetworkCheck? failedCheck;
  NetworkCheck? tokenExpireCheck;
  NetworkMessageExtractor? messageExtractor;

  /// Initialize once at app start.
  static Future<void> initialize({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 25),
    Map<String, dynamic>? headers,
    bool enableLogs = true,
    NetworkLogLevel logLevel = NetworkLogLevel.basic,
    RetryPolicy retryPolicy = RetryPolicy.exponential,
    int maxRetries = 2,
    bool throwOnFailureGlobal = true, // default: throw on failures
    void Function(NetworkRequest req)? onStart,
    NetworkHook? onEnd,
    NetworkHook? onSuccess,
    NetworkHook? onFailed,
    NetworkHook? onTokenExpire,
    NetworkCheck? successCheck,
    NetworkCheck? failedCheck,
    NetworkCheck? tokenExpireCheck,
    NetworkMessageExtractor? messageExtractor,
  }) async {
    final mgr = instance;
    if (mgr._initialized) return;

    mgr.baseUrl = baseUrl;
    mgr.connectTimeout = connectTimeout;
    mgr.receiveTimeout = receiveTimeout;
    mgr.defaultHeaders = headers;
    mgr.enableLogs = enableLogs;
    mgr.logLevel = logLevel;
    mgr.retryPolicy = retryPolicy;
    mgr.maxRetries = maxRetries;
    mgr.throwOnFailureGlobal = throwOnFailureGlobal;

    mgr.onStart = onStart;
    mgr.onEnd = onEnd;
    mgr.onSuccess = onSuccess;
    mgr.onFailed = onFailed;
    mgr.onTokenExpire = onTokenExpire;

    mgr.successCheck = successCheck;
    mgr.failedCheck = failedCheck;
    mgr.tokenExpireCheck = tokenExpireCheck;
    mgr.messageExtractor = messageExtractor;

    mgr._dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: headers ?? {},
      responseType: ResponseType.json,
      followRedirects: true,
      maxRedirects: 3,
      // Transport success (2xx); business success handled via checks.
      validateStatus: (code) => code != null && code >= 200 && code < 300,
    ));

    // Logging interceptor with per-request override via options.extra['enableLogs']
    mgr._dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final reqLogs = (options.extra['enableLogs'] as bool?) ?? mgr.enableLogs;
        if (mgr.logLevel != NetworkLogLevel.none && reqLogs) {
          if (mgr.logLevel == NetworkLogLevel.basic || mgr.logLevel == NetworkLogLevel.full) {
            appLog.d('➡️ ${options.method} ${options.uri}');
          }
          if (mgr.logLevel == NetworkLogLevel.full && options.data != null) {
            appLog.d('Headers: ${options.headers}');
            appLog.d('Body: ${_short(options.data)}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        final reqLogs = (response.requestOptions.extra['enableLogs'] as bool?) ?? mgr.enableLogs;
        if (mgr.logLevel != NetworkLogLevel.none && reqLogs) {
          appLog.i('✅ ${response.statusCode} ${response.requestOptions.uri}');
          if (mgr.logLevel == NetworkLogLevel.full) {
            appLog.i('Resp: ${_short(response.data)}');
          }
        }
        handler.next(response);
      },
      onError: (e, handler) {
        final reqLogs = (e.requestOptions.extra['enableLogs'] as bool?) ?? mgr.enableLogs;
        if (mgr.logLevel != NetworkLogLevel.none && reqLogs) {
          appLog.e('❌ ${e.message}', e, e.stackTrace);
        }
        handler.next(e);
      },
    ));

    mgr._initialized = true;
  }

  // ========================================================================
  // PUBLIC HELPERS (typed verbs)
  // ========================================================================

  Future<NetworkResponse> get(
      String pathOrUrl, {
        Map<String, dynamic>? query,
        Map<String, dynamic>? headers,
        Duration? timeout,
        bool? enableLogs,
        bool? throwOnFailure, // override default behavior
        CancelToken? cancelToken,
      }) =>
      _request(
        HttpMethod.get,
        pathOrUrl,
        query: query,
        headers: headers,
        timeout: timeout,
        enableLogs: enableLogs,
        throwOnFailure: throwOnFailure,
        cancelToken: cancelToken
      );

  Future<NetworkResponse> post(
      String pathOrUrl, {
        dynamic body,
        Map<String, dynamic>? query,
        Map<String, dynamic>? headers,
        Duration? timeout,
        bool? enableLogs,
        bool? throwOnFailure,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        CancelToken? cancelToken,

      }) =>
      _request(
        HttpMethod.post,
        pathOrUrl,
        body: body,
        query: query,
        headers: headers,
        timeout: timeout,
        enableLogs: enableLogs,
        throwOnFailure: throwOnFailure,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken
      );

  Future<NetworkResponse> put(
      String pathOrUrl, {
        dynamic body,
        Map<String, dynamic>? query,
        Map<String, dynamic>? headers,
        Duration? timeout,
        bool? enableLogs,
        bool? throwOnFailure,
        CancelToken? cancelToken,

      }) =>
      _request(
        HttpMethod.put,
        pathOrUrl,
        body: body,
        query: query,
        headers: headers,
        timeout: timeout,
        enableLogs: enableLogs,
        throwOnFailure: throwOnFailure,
        cancelToken: cancelToken
      );

  Future<NetworkResponse> patch(
      String pathOrUrl, {
        dynamic body,
        Map<String, dynamic>? query,
        Map<String, dynamic>? headers,
        Duration? timeout,
        bool? enableLogs,
        bool? throwOnFailure,
        CancelToken? cancelToken,

      }) =>
      _request(
        HttpMethod.patch,
        pathOrUrl,
        body: body,
        query: query,
        headers: headers,
        timeout: timeout,
        enableLogs: enableLogs,
        throwOnFailure: throwOnFailure,
      );

  Future<NetworkResponse> delete(
      String pathOrUrl, {
        dynamic body,
        Map<String, dynamic>? query,
        Map<String, dynamic>? headers,
        Duration? timeout,
        bool? enableLogs,
        bool? throwOnFailure,
        CancelToken? cancelToken,

      }) =>
      _request(
        HttpMethod.delete,
        pathOrUrl,
        body: body,
        query: query,
        headers: headers,
        timeout: timeout,
        enableLogs: enableLogs,
        throwOnFailure: throwOnFailure,
        cancelToken: cancelToken
      );

  Future<NetworkResponse> upload(
      String pathOrUrl, {
        required FormData formData,
        Map<String, dynamic>? query,
        Map<String, dynamic>? headers,
        Duration? timeout,
        bool? enableLogs,
        bool? throwOnFailure,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        CancelToken? cancelToken,

      }) =>
      _request(
        HttpMethod.upload,
        pathOrUrl,
        body: formData,
        query: query,
        headers: {'Content-Type': 'multipart/form-data', ...?headers},
        timeout: timeout,
        enableLogs: enableLogs,
        throwOnFailure: throwOnFailure,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken
      );

  Future<NetworkResponse> download(
      String url, // must be absolute for download
      String savePath, {
        Map<String, dynamic>? query,
        Map<String, dynamic>? headers,
        bool? enableLogs,
        bool? throwOnFailure,
        ProgressCallback? onReceiveProgress,
        CancelToken? cancelToken,

      }) async {
    final req = NetworkRequest(HttpMethod.download, url, query, headers, null, enableLogs ?? this.enableLogs);
    onStart?.call(req);
    final sw = Stopwatch()..start();
    final shouldThrow = throwOnFailure ?? throwOnFailureGlobal;

    try {
      await _dio.download(
        url,
        cancelToken: cancelToken,
        savePath,
        queryParameters: query,
        options: Options(headers: _composeHeaders(headers), extra: {'enableLogs': enableLogs ?? this.enableLogs}),
        onReceiveProgress: onReceiveProgress,
      );

      final res = NetworkResponse(
        success: true,
        statusCode: 200,
        message: 'Download complete',
        data: {'path': savePath},
        raw: null,
        duration: sw.elapsed,
      );
      onSuccess?.call(req, res);
      onEnd?.call(req, res);
      return res;
    } catch (e, st) {
      final res = NetworkResponse(
        success: false,
        statusCode: -1,
        message: e.toString(),
        data: null,
        raw: e,
        duration: sw.elapsed,
      );
      appLog.e('Download error', e, st);
      onFailed?.call(req, res);
      onEnd?.call(req, res);

      if (shouldThrow) {
        throw NetworkException(message: res.message ?? 'Download failed', statusCode: res.statusCode, data: res.data, raw: e);
      }
      return res;
    }
  }

  // ========================================================================
  // CORE REQUEST PIPELINE
  // ========================================================================

  Future<NetworkResponse> _request(
      HttpMethod method,
      String pathOrUrl, {
        dynamic body,
        Map<String, dynamic>? query,
        Map<String, dynamic>? headers,
        Duration? timeout,
        bool? enableLogs,
        bool? throwOnFailure,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        CancelToken? cancelToken,

      }) async {
    final req = NetworkRequest(method, pathOrUrl, query, headers, body, enableLogs ?? this.enableLogs);
    onStart?.call(req);
    final sw = Stopwatch()..start();

    // If absolute URL is provided, Dio uses it directly (ignores baseUrl).
    final requestPath = pathOrUrl;
    final shouldThrow = throwOnFailure ?? throwOnFailureGlobal;

    int attempt = 0;
    while (true) {
      try {
        final response = await _dio.request(
          requestPath,
          data: body,
          cancelToken: cancelToken,
          queryParameters: query,
          options: Options(
            method: method.name,
            headers: _composeHeaders(headers),
            receiveTimeout: timeout ?? receiveTimeout,
            sendTimeout: timeout ?? connectTimeout,
            extra: {'enableLogs': enableLogs ?? this.enableLogs},
          ),
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );

        final res = _parseResponse(req, response, sw.elapsed);

        if (res.success) {
          onSuccess?.call(req, res);
          onEnd?.call(req, res);
          return res;
        } else if (tokenExpireCheck?.call(req, res) ?? false) {
          onTokenExpire?.call(req, res);
          onEnd?.call(req, res);
          if (shouldThrow) {
            throw NetworkException(
              statusCode: res.statusCode,
              message: res.message ?? 'Token expired',
              data: res.data,
              raw: response,
              tokenExpired: true,
            );
          }
          return res;
        } else {
          onFailed?.call(req, res);
          onEnd?.call(req, res);
          if (shouldThrow) {
            throw NetworkException(
              statusCode: res.statusCode,
              message: res.message ?? 'Request failed',
              data: res.data,
              raw: response,
            );
          }
          return res;
        }
      } on DioException catch (e, st) {
        if (_shouldRetry(e) && attempt < maxRetries && retryPolicy == RetryPolicy.exponential) {
          attempt++;
          final delay = Duration(milliseconds: 200 * pow(2, attempt).toInt());
          await Future.delayed(delay);
          continue;
        }
        final res = _wrapError(req, e, sw.elapsed);
        onFailed?.call(req, res);
        onEnd?.call(req, res);
        appLog.e('Request error', e, st);

        if (shouldThrow) {
          throw NetworkException(
            statusCode: res.statusCode,
            message: res.message ?? 'Network error',
            data: res.data,
            raw: e,
          );
        }
        return res;
      } catch (e, st) {
        final res = NetworkResponse(
          success: false,
          statusCode: -600,
          message: e.toString(),
          data: null,
          raw: e,
          duration: sw.elapsed,
        );
        onFailed?.call(req, res);
        onEnd?.call(req, res);
        appLog.e('Unknown error', e, st);

        if (shouldThrow) {
          throw NetworkException(
            statusCode: res.statusCode,
            message: res.message ?? 'Unknown error',
            data: res.data,
            raw: e,
          );
        }
        return res;
      }
    }
  }

  Map<String, dynamic> _composeHeaders(Map<String, dynamic>? override) {
    final all = <String, dynamic>{};
    if (defaultHeaders != null) all.addAll(defaultHeaders!);
    if (hasToken) all['Authorization'] = 'Bearer $_token';
    if (override != null) all.addAll(override);
    return all;
  }

  bool _shouldRetry(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return true;
    }
    final code = e.response?.statusCode ?? 0;
    return code >= 500 && code < 600;
  }

  NetworkResponse _wrapError(NetworkRequest req, DioException e, Duration duration) {
    final code = e.response?.statusCode ?? -1;
    final data = e.response?.data;
    final message = e.message ?? 'Network error';
    return NetworkResponse(
      success: false,
      statusCode: code,
      message: message,
      data: data,
      raw: e,
      duration: duration,
    );
  }

  NetworkResponse _parseResponse(NetworkRequest req, Response response, Duration duration) {
    final statusCode = response.statusCode;
    dynamic data = response.data;

    // Try to decode string payloads as JSON.
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (e) {

        // Keep raw string if not JSON.
      }
    }else if(data is Map<String,dynamic>){
      data = data;
    }

    // Extract message: custom extractor > common fields > default.
    final msg = messageExtractor?.call(data is Map<String, dynamic> ? data : {}) ??
        (data is Map<String, dynamic> ? (data['message'] ?? data['error'] ?? data['msg'])?.toString() : null) ??
        'Success';

    // Transport success (2xx) first; then business-level success via custom checks.
    final initial = NetworkResponse(
      success: statusCode != null && statusCode >= 200 && statusCode < 300,
      statusCode: statusCode,
      message: msg,
      data: data,
      raw: response,
      duration: duration,
    );

    // Apply business rules: successCheck/failedCheck/tokenExpireCheck
    if (!(successCheck?.call(req, initial) ?? true)) {
      return initial.copyWith(success: false);
    }
    if (failedCheck?.call(req, initial) ?? false) {
      return initial.copyWith(success: false);
    }
    if (tokenExpireCheck?.call(req, initial) ?? false) {
      return initial.copyWith(success: false, message: 'Token expired');
    }

    return initial;
  }

  static String _short(dynamic v) {
    try {
      final s = v is String ? v : jsonEncode(v);
      return s.length > 700 ? '${s.substring(0, 700)}…' : s;
    } catch (_) {
      return v.toString();
    }
  }
}

/// =========================================================================
/// SUPPORT TYPES
/// =========================================================================

class NetworkRequest {
  final HttpMethod method;
  final String pathOrUrl; // can be relative (uses baseUrl) or absolute (overrides)
  final Map<String, dynamic>? query;
  final Map<String, dynamic>? headers;
  final dynamic body;
  final bool enableLogs;

  NetworkRequest(this.method, this.pathOrUrl, this.query, this.headers, this.body, this.enableLogs);

  @override
  String toString() => '${method.name} $pathOrUrl';
}

class NetworkResponse {
  final bool success;
  final int? statusCode;
  final String? message;
  final dynamic data; // decoded JSON or raw payload
  final dynamic raw;  // raw Dio Response or error
  final Duration duration;

  const NetworkResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.raw,
    required this.duration,
  });

  const NetworkResponse.empty()
      : success = false,
        statusCode = null,
        message = null,
        data = null,
        raw = null,
        duration = Duration.zero;

  NetworkResponse copyWith({
    bool? success,
    int? statusCode,
    String? message,
    dynamic data,
    dynamic raw,
    Duration? duration,
  }) =>
      NetworkResponse(
        success: success ?? this.success,
        statusCode: statusCode ?? this.statusCode,
        message: message ?? this.message,
        data: data ?? this.data,
        raw: raw ?? this.raw,
        duration: duration ?? this.duration,
      );

  @override
  String toString() =>
      'NetworkResponse(success: $success, code: $statusCode, msg: $message, took: ${duration.inMilliseconds}ms)';
}
