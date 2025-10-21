import 'package:get_it/get_it.dart';
import 'core/abstracts/base_failure.dart';
import 'core/abstracts/base_result.dart';
import 'core/logger/logger_service.dart';
import 'core/networking/network_manager.dart';

/// Global service locator
final di = GetIt.instance;

/// 1) Base DI setup (NO network init here)
/// Call this first in `bootstrap()`.
Future<void> configureDependenciesBase() async {
  // Logger (optional)
  if (!di.isRegistered<LoggerService>()) {
    di.registerSingleton<LoggerService>(appLog);
  }
  appLog.configure(
    level: LogLevel.debug,      // set to LogLevel.info in production
    showTimestamp: true,
    tag: 'MYAPP',
  );

  await initNetworkManager(
    baseUrl: 'https://msapi.farateams.com/api',
    // from env/config
    enableLogs: true,
    logLevel: NetworkLogLevel.full,
    maxRetries: 2,

    throwOnFailureGlobal: true, // default: throw NetworkException on failure
  );

  // Register other non-network singletons/factories here…
  // e.g. SecureStorage, Analytics, Local DB, etc.
  //
  // di.registerSingleton<SecureStorage>(SecureStorageImpl());
  // di.registerLazySingleton<Analytics>(() => AnalyticsImpl());
}

/// 2) Initialize the NetworkManager separately
/// Call this AFTER you know env/baseUrl or after user login flow if needed.
Future<void> initNetworkManager({required String baseUrl, bool enableLogs = true, NetworkLogLevel logLevel = NetworkLogLevel.basic, int maxRetries = 2, bool throwOnFailureGlobal = true}) async {
  // Only initialize once
  if (!di.isRegistered<NetworkManager>()) {
    await NetworkManager.initialize(
      baseUrl: baseUrl,
      enableLogs: enableLogs,
      // logLevel: logLevel,
      exposeUrlInUi: true,
      maxRetries: maxRetries,
      retryPolicy: RetryPolicy.exponential,
      throwOnFailureGlobal: throwOnFailureGlobal,

      // ---- Global rules & hooks (customize to your backend) ----
      messageExtractor: (json) => json['message']?.toString() ?? json['error_description']?.toString(),

      // Transport success is 2xx; add business rules here:
      // successCheck: (req, res) {
      //   final m = res.data is Map ? (res.data as Map) : const {};
      //   final httpOk = (res.statusCode != null &&
      //       res.statusCode! >= 200 &&
      //       res.statusCode! < 300);
      //   // Example business rules: either {status: true} or {code: 0}
      //   final businessOk = (m['status'] == true) || (m['code'] == 0);
      //   // If body isn’t a map, just rely on HTTP
      //   return httpOk && (m.isEmpty || businessOk);
      // },
      //
      // failedCheck: (req, res) {
      //   final m = res.data is Map ? (res.data as Map) : const {};
      //   return m['success'] == false; // tweak for your schema
      // },
      //
      // tokenExpireCheck: (req, res) {
      //   final m = res.data is Map ? (res.data as Map) : const {};
      //   return res.statusCode == 401 ||
      //       m['error'] == 'token_expired' ||
      //       m['code'] == 'TOKEN_EXPIRED';
      // },
      onStart: (req) => appLog.d('Starting ${req.method.name} ${req.pathOrUrl}'),
      onEnd: (req, res) => appLog.d('Finished in ${res.duration.inMilliseconds}ms'),
      onSuccess: (req, res) => appLog.i('OK ${res.statusCode} ${req.pathOrUrl}'),
      onFailed: (req, res) {
        appLog.w('Fail ${res.statusCode} ${req.pathOrUrl}: ${res.message}');
        final fail = NetworkFailure.fromResponse(
          method: req.method.name,
          url: _resolveUrl(NetworkManager.instance.baseUrl, req.pathOrUrl),
          code: res.statusCode,
          message: res.message ?? 'Request failed',
          duration: res.duration,
        );
        FailureBus.I.emit(FailureNotice(
          failure: fail,
          severity: _severityFromCode(res.statusCode),
        ));
      },
      onTokenExpire: (req, res) {
        // Optionally trigger refresh/logout here
        appLog.w('Token expired on ${req.pathOrUrl}');
      },
    );

    di.registerSingleton<NetworkManager>(NetworkManager.instance);
  }
}

/// Convenience resolver
T locate<T extends Object>() => di<T>();

/// Helpers to manage the bearer token centrally
void setAuthToken(String token) => di<NetworkManager>().setToken(token);

void clearAuthToken() => di<NetworkManager>().clearToken();

/// For tests/hot restarts
Future<void> resetDi() async => di.reset();

String _resolveUrl(String base, String pathOrUrl) {
  // If pathOrUrl is absolute, return it; else join with base
  if (pathOrUrl.startsWith('http')) return pathOrUrl;
  return Uri.parse(base).resolve(pathOrUrl).toString();
}

FailureSeverity _severityFromCode(int? code) {
  if (code == 401 || code == 403) return FailureSeverity.critical;
  if (code != null && code >= 500) return FailureSeverity.error;
  return FailureSeverity.warning;
}