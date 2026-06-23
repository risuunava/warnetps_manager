import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Stream of Firebase Auth State (User? object)
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// FutureProvider for fetching the profile of the currently authenticated user
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return null;

  final authService = ref.watch(authServiceProvider);
  return await authService.getUserProfile(authState.uid);
});
