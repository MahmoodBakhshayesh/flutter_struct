import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:struct2/screens/login_screen/login_view.dart';
import 'package:struct2/screens/passenger_details/passenger_details_view.dart';
import 'package:struct2/screens/passengers/passengers_view.dart';
import '../auth/auth_providers.dart';
import 'routes.dart';

// Screens

DateTime? _parseDateQ(Map<String, String> q) {
  final s = q['date'];
  if (s == null) return null;
  final p = s.split('-');
  if (p.length != 3) return null;
  try { return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2])); }
  catch (_) { return null; }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // react to auth changes
  final loggedIn = ref.watch(isLoggedInProvider);

  return GoRouter(
    initialLocation: Routes.passengers,
    redirect: (context, state) {
      final loggedIn = ref.read(isLoggedInProvider);
      final loggingIn = state.matchedLocation == Routes.login;

      if (!loggedIn && !loggingIn) {
        // preserve intended URL when unauthenticated
        return Uri(path: Routes.login, queryParameters: {'from': state.uri.toString()}).toString();
      }

      if (loggedIn && loggingIn) {
        // priority: explicit post-login target > ?from=... > default
        final override = ref.read(postLoginTargetProvider);
        if (override != null && override.isNotEmpty) {
          // clear one-shot target so it won't loop
          ref.read(postLoginTargetProvider.notifier).state = null;
          return override;
        }
        final from = state.uri.queryParameters['from'];
        return from ?? Routes.passengers;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        name: 'login',
        pageBuilder: (_, __) => const NoTransitionPage(child: LoginView()),
      ),
      // /passengers?date=YYYY-MM-DD
      GoRoute(
        path: Routes.passengers,
        name: 'passengers',
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          final date = _parseDateQ(q) ??
              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          return NoTransitionPage(child: PassengersView(date: date));
        },
      ),
      // /passenger-details?id=123&date=YYYY-MM-DD
      GoRoute(
        path: Routes.passengerDetails,
        name: 'passengerDetails',
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          final id = q['id'];
          final date = _parseDateQ(q);
          if (id == null || id.isEmpty || date == null) {
            return const NoTransitionPage(child: _InvalidRoute());
          }
          return NoTransitionPage(child: PassengerDetailsView(date: date, passengerId: id,));
        },
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      appBar: AppBar(title: const Text('Route Error')),
      body: Center(child: Text(state.error?.toString() ?? 'Unknown route')),
    ),
  );
});

class _InvalidRoute extends StatelessWidget {
  const _InvalidRoute();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Invalid or missing query parameters')));
}
