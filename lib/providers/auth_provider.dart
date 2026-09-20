import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final isGuestSignedInProvider = StateProvider<bool>((ref) => false);

final currentUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final isGuest = ref.watch(isGuestSignedInProvider);
  if (isGuest) return AuthService.demoUid;
  return authState.asData?.value?.uid ?? AuthService.demoUid;
});
