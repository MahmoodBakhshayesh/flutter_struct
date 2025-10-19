import 'dart:convert';
import 'dart:developer';

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
          DateTime d = DateTime.parse(s.uri.queryParameters["date"]!)!;
          log("passengers: ${s.uri.toString()}");
          return PassengersView(date: d);
        },
        routes: [
          GoRoute(
            path: "passenger/:id",
            builder: (c, s) {
              DateTime d = DateTime.parse(s.uri.queryParameters["date"]!);
              // String id = s.uri.queryParameters["id"]!;
              String id = s.pathParameters["id"]!;
              log("details ${s.uri.toString()}");
              return PassengerDetailsView(date: d, passengerId: id);
            },
          ),
        ],
      ),
    ],
  );
  return GoRouter(
    initialLocation: '/login',
    navigatorKey: NavigationService.rootNavigatorKey,
    // refreshListenable: auth,
    redirect: (context, state) {
      final qp = Map<String, String>.from(state.uri.queryParameters);

      // If already going to /passengers/passenger-details, do NOT rewrite the path.
      final segs = state.uri.pathSegments;
      final goingToDetails = segs.length >= 2 && segs[0] == 'passengers' && segs[1] == 'passenger-details';

      if (!qp.containsKey('date')) {
        final today = DateTime.now().toUtc().toIso8601String().split('T').first; // yyyy-MM-dd
        final newUri = Uri(
          path: state.uri.path, // ✅ preserve /passengers[/passenger-details]
          queryParameters: {...qp, 'date': today}, // ✅ just add date
        );
        return goingToDetails ? newUri.toString() : newUri.toString();
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(
        path: '/passengers',
        builder: (context, state) {
          // read date from query (?date=YYYY-MM-DD), default to today if missing
          final date = state.uri.queryParameters['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
          return PassengersView(date: DateTime.now());
        },
        routes: [
          GoRoute(
            path: 'passenger-details',
            builder: (context, state) {
              final id = state.uri.queryParameters['id'];
              final date = state.uri.queryParameters['date']; // pass date again
              // if (id == null || date == null) {
              //   return const _BadLinkScreen();
              // }
              // Parent (/passengers) still builds first because this is a nested route.
              return PassengerDetailsView(date: DateTime.now(), passengerId: id!);
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
