import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/navigation/routes.dart';

class LoginViewPhone extends ConsumerWidget {
  const LoginViewPhone({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              ref.read(authStateProvider.notifier).state = UserSession('u-1');
              final target = Uri(path: Routes.passengers, queryParameters: Routes.qDate(DateTime.now())).toString();
              context.go(target.toString());
            },
            child: Text("Press"),
          ),
          TextButton(
            onPressed: () {
              // 1) build your desired target
              final now = DateTime.now();
              final date = DateTime(now.year, now.month, now.day);
              // final target = Uri(
              //   path: Routes.passengerDetails,
              //   queryParameters: Routes.qPassenger(date, '1'),
              // ).toString();
              //
              // // 2) stash it so the router redirect uses it
              // ref.read(postLoginTargetProvider.notifier).state = target;
              //
              // // 3) log in — the redirect will immediately navigate to `target`
              // ref.read(authStateProvider.notifier).state = UserSession('u-1');
              context.go("/passengers/passenger/${2}?date=2025-10-19");
            },
            child: Text("Go Pax 1"),
          ),
        ],
      ),
    );
  }
}
