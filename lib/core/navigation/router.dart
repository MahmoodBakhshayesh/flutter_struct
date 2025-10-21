import 'dart:convert';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:struct2/screens/login_screen/login_view.dart';
import 'package:struct2/screens/passenger_details/passenger_details_view.dart';
import 'package:struct2/screens/passengers/passengers_view.dart';
import '../auth/auth_providers.dart';
import 'navigation_service.dart';
import 'routes.dart';

// Screens

DateTime? _parseDateQ(Map<String, String> q) {
  final s = q['date'];
  if (s == null) return null;
  final p = s.split('-');
  if (p.length != 3) return null;
  try {
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  } catch (_) {
    return null;
  }
}



final appRouterProvider = Provider<GoRouter>((ref) {
  // react to auth changes
  final loggedIn = ref.watch(isLoggedInProvider);
  return GoRouter(
    initialLocation: "/login",
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authStateProvider.notifier).stream, // only if you expose a stream
    ),
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/passengers';

      return null;
    },
    observers: [BotToastNavigatorObserver()],
    navigatorKey: NavigationService.rootNavigatorKey,
    routes: [
      GoRoute(
        path: "/login",
        builder: (c, s) {
          return LoginView();
        },
      ),
      GoRoute(
        path: "/passengers",
        builder: (c, s) {
          DateTime d = DateTime.tryParse(s.uri.queryParameters["date"]??'')??DateTime.now();
          return PassengersView(date: d);
        },
        routes: [
          GoRoute(
            path: "passenger/:id",
            builder: (c, s) {
              DateTime d = DateTime.parse(s.uri.queryParameters["date"]!);
              // String id = s.uri.queryParameters["id"]!;
              String id = s.pathParameters["id"]!;
              return PassengerDetailsView(date: d, id: id);
            },
          ),
        ],
      ),
    ],
  );
});

class _InvalidRoute extends StatelessWidget {
  const _InvalidRoute();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Invalid or missing query parameters')));
}
