import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Central place to hold global Navigator keys & (optionally) the GoRouter.
/// BaseController uses [rootNavigatorKey.currentContext] to access a live context.
class NavigationService {
  NavigationService._();

  /// Root navigator key used by MaterialApp.router (top-level).
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

  /// Optional shell navigator key (useful when you add a ShellRoute / bottom nav).
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellNavigator');

  /// Optional: keep a reference to the app router if you want static access.
  static GoRouter? _router;

  static void attachRouter(GoRouter router) => _router = router;

  static GoRouter? get router => _router;

  /// Convenience getters.
  static BuildContext? get rootContext => rootNavigatorKey.currentContext;

  static NavigatorState? get navigator => rootNavigatorKey.currentState;

  /// Helpers (purely optional).
  static void pop<T extends Object?>([T? result]) => navigator?.pop<T>(result);

  static Future<T?> pushDialog<T>(WidgetBuilder builder, {bool barrierDismissible = true}) {
    final ctx = rootContext;
    if (ctx == null) return Future.value(null);
    return showDialog<T>(context: ctx, barrierDismissible: barrierDismissible, builder: builder);
  }

  static Future<T?> showBottomSheet<T>(WidgetBuilder builder, {bool isScrollControlled = false, bool useSafeArea = true}) {
    final ctx = rootContext;
    if (ctx == null) return Future.value(null);
    return showModalBottomSheet<T>(context: ctx, isScrollControlled: isScrollControlled, useSafeArea: useSafeArea, builder: builder);
  }
}
