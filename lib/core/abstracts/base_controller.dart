import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/navigation_service.dart';
import '../logger/logger_service.dart';
import 'dart:developer' as dev;
/// BaseController
/// - No BuildContext stored; uses NavigationService.rootNavigatorKey.
/// - Works with go_router (go/push/pop, named variants, replacements).
/// - UI helpers: dialogs, bottom sheets, snackbars, confirm/alert, optional loading dialog.
/// - Lifecycle: onInit/onDispose + `mounted` flag to guard async work.
/// - Extend this per View (e.g., PassengersListController extends BaseController).
abstract class BaseController {
  BaseController() {
    // Optional: auto-run onInit in your provider wiring.
  }

  // ---------------- Lifecycle ----------------
  bool _mounted = true;
  bool get mounted => _mounted;

  /// Called once when the controller is created (wire this from your Provider).
  @mustCallSuper
  Future<void> onInit() async {}

  /// Called once when the controller is disposed (wire this from your Provider).
  @mustCallSuper
  Future<void> onDispose() async {
    _mounted = false;
  }

  // ---------------- Context / Router access ----------------
  @protected
  BuildContext? get context => NavigationService.rootNavigatorKey.currentContext;

  bool get hasContext => context != null;

  GoRouter? get _router => hasContext ? GoRouter.of(context!) : null;

  // ---------------- Navigation (go_router) ----------------

  /// Replace the current location.
  void go(String location, {Object? extra}) {
    final r = _router;
    if (r != null) r.go(location, extra: extra);
  }

  /// Replace using route name (when you configured named routes).
  void goNamed(String name, {Map<String, String> pathParams = const {}, Map<String, dynamic> queryParams = const {}, Object? extra}) {
    final r = _router;
    if (r != null) {
      r.goNamed(
        name,
        pathParameters: pathParams,
        queryParameters: queryParams.isEmpty ? {} : queryParams,
        extra: extra,
      );
    }
  }

  /// Push a new location on top of the stack.
  Future<T?> push<T>(String location, {Object? extra}) async {
    final r = _router;
    if (r == null) return null;
    return r.push<T>(location, extra: extra);
  }

  /// Push using route name.
  Future<T?> pushNamed<T>(String name, {Map<String, String> pathParams = const {}, Map<String, dynamic> queryParams = const {}, Object? extra}) async {
    final r = _router;
    if (r == null) return null;
    return r.pushNamed<T>(
      name,
      pathParameters: pathParams,
      queryParameters: queryParams.isEmpty ? {} : queryParams,
      extra: extra,
    );
  }

  /// Replace the top-most route (pushReplacement equivalent for GoRouter).
  Future<T?> replace<T>(String location, {Object? extra}) async {
    final r = _router;
    if (r == null) return null;
    return r.replace<T>(location, extra: extra);
  }

  /// Pop the current route if possible.
  void pop<T extends Object?>([T? result]) {
    final ctx = context;
    if (ctx != null && Navigator.of(ctx).canPop()) {
      Navigator.of(ctx).pop<T>(result);
    }
  }

  // ---------------- UI helpers ----------------

  /// Show a Material dialog.
  Future<T?> showAppDialog<T>(
      WidgetBuilder builder, {
        bool barrierDismissible = true,
        RouteSettings? settings,
      }) async {
    final ctx = context;
    if (ctx == null) return null;
    return showDialog<T>(
      context: ctx,
      barrierDismissible: barrierDismissible,
      builder: builder,
      routeSettings: settings,
    );
  }

  /// Show a confirm dialog; returns true if confirmed.
  Future<bool> confirmDialog({
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    bool barrierDismissible = true,
  }) async {
    final res = await showAppDialog<bool>(
          (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(cancelText)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(confirmText)),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
    return res ?? false;
  }

  /// Show a simple alert dialog.
  Future<void> alertDialog({
    required String title,
    required String message,
    String dismissText = 'Close',
  }) async {
    await showAppDialog<void>(
          (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(dismissText))],
      ),
    );
  }

  /// Show a modal bottom sheet.
  Future<T?> showBottomSheet<T>(
      WidgetBuilder builder, {
        bool isScrollControlled = false,
        bool useSafeArea = true,
        RouteSettings? settings,
      }) async {
    final ctx = context;
    if (ctx == null) return null;
    return showModalBottomSheet<T>(
      context: ctx,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      builder: builder,
      routeSettings: settings,
    );
  }

  /// Show a snackbar.
  void showSnack(String message, {SnackBarAction? action, Duration? duration}) {
    final ctx = context;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(message), action: action, duration: duration ?? const Duration(seconds: 3)),
    );
  }

  /// Optional: show/hide a simple loading dialog.
  Future<void> showLoading({String message = 'Loading…'}) async {
    final ctx = context;
    if (ctx == null) return;
    await showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4),
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Flexible(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  void hideLoading() {
    final ctx = context;
    if (ctx != null && Navigator.of(ctx).canPop()) {
      Navigator.of(ctx).pop();
    }
  }

  // ---------------- Logging (optional) ----------------
  @protected
  void logD(String msg) => appLog.d('[$runtimeType] $msg');
  @protected
  void logI(String msg) => appLog.i('[$runtimeType] $msg');
  @protected
  void logW(String msg) => appLog.w('[$runtimeType] $msg');
  @protected
  void logE(String msg, [Object? e, StackTrace? st]) => appLog.e('[$runtimeType] $msg', e, st);

  // ---------------- Utilities ----------------

  /// Guard to ignore work after dispose in async tasks.
  @protected
  void checkMountedOrThrow() {
    if (!mounted) {
      throw StateError('$runtimeType used after dispose');
    }
  }

  /// Run async and swallow errors to snackbar (handy for button handlers).
  @protected
  Future<void> safeRun(Future<void> Function() body, {String? onErrorSnack}) async {
    try {
      await body();
    } catch (e, st) {
      logE('safeRun error', e, st);
      if (onErrorSnack != null) showSnack(onErrorSnack);
      rethrow; // or remove if you prefer absorb
    }
  }
}
