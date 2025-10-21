import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart'; // ✅

class UserSession {
  final String userId;
  UserSession(this.userId);
}

final authStateProvider = StateProvider<UserSession?>((_) => null);

final isLoggedInProvider =
Provider<bool>((ref) => ref.watch(authStateProvider) != null);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // initial
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
      onError: (_, __) {}, // ignore errors
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
