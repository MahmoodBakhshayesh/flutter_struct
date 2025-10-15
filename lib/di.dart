import 'package:get_it/get_it.dart';
import 'core/logger/logger_service.dart';
import 'core/networking/network_manager.dart';

/// Global service locator
final di = GetIt.instance;

/// 1) Base DI setup (NO network init here)
/// Call this first in `bootstrap()`.
Future<void> configureDependenciesBase() async {
  // Logger (optional)
  if (!di.isRegistered<LoggerService>()) {
    di.registerSingleton<LoggerService>(LoggerService());
  }

  await initNetworkManager(
    baseUrl: 'https://msapi.farateams.com/api',
    // from env/config
    enableLogs: true,
    logLevel: LogLevel.full,
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
Future<void> initNetworkManager({required String baseUrl, bool enableLogs = true, LogLevel logLevel = LogLevel.basic, int maxRetries = 2, bool throwOnFailureGlobal = true}) async {
  // Only initialize once
  if (!di.isRegistered<NetworkManager>()) {
    await NetworkManager.initialize(
      baseUrl: baseUrl,
      enableLogs: enableLogs,
      logLevel: logLevel,
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
      onStart: (req) => log.d('Starting ${req.method.name} ${req.pathOrUrl}'),
      onEnd: (req, res) => log.d('Finished in ${res.duration.inMilliseconds}ms'),
      onSuccess: (req, res) => log.i('OK ${res.statusCode} ${req.pathOrUrl}'),
      onFailed: (req, res) => log.w('Fail ${res.statusCode} ${req.pathOrUrl}: ${res.message}'),
      onTokenExpire: (req, res) {
        // Optionally trigger refresh/logout here
        log.w('Token expired on ${req.pathOrUrl}');
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
