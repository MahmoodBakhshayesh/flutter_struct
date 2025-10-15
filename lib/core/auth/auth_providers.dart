import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

/// Replace with your real user model
class UserSession {
  final String userId;
  UserSession(this.userId);
}

/// Async auth state (null when logged out)
final authStateProvider = StateProvider<UserSession?>((_) => null);

/// Derived convenience
final isLoggedInProvider = Provider<bool>((ref) => ref.watch(authStateProvider) != null);

final postLoginTargetProvider = StateProvider<String?>((_) => null);
