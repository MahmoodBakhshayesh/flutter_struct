import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/navigation_service.dart';

/// BaseController
/// - Provides access to the current BuildContext via NavigationService.
/// - Convenience methods for navigation (go/push/pop), dialogs, sheets, and snackbars.
/// - Extend this in each feature controller (e.g., HomeController extends BaseController).
abstract class BaseController {
  /// Current context from the root navigator (may be null very early in app boot).
  @protected
  BuildContext? get context => NavigationService.rootNavigatorKey.currentContext;

  bool get hasContext => context != null;

  GoRouter? get _router => hasContext ? GoRouter.of(context!) : null;

  // ---------------- Navigation 2.0 (go_router) helpers ----------------

  /// Replace the current location.
  void go(String location, {Object? extra}) {
    final r = _router;
    if (r != null) r.go(location, extra: extra);
  }

  /// Push a new location on top of the stack.
  Future<T?> push<T>(String location, {Object? extra}) async {
    final r = _router;
    if (r == null) return null;
    return r.push<T>(location, extra: extra);
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
}
