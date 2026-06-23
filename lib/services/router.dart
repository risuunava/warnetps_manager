import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/auth/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/session/start_session_screen.dart';
import '../screens/session/session_detail_screen.dart';
import '../screens/session/checkout_screen.dart';
import '../screens/member/add_member_screen.dart';
import '../screens/member/member_detail_screen.dart';
import '../screens/settings/manage_tariff_screen.dart';
import '../screens/settings/manage_operators_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Listens directly to Firebase Auth stream.
/// Stores the latest [User?] locally so the redirect callback
/// always reads a consistent snapshot — no Riverpod timing gaps.
class _AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _sub;

  User? _user;
  bool _initialized = false; // true once we get the first emission

  _AuthNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      _initialized = true;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isInitialized => _initialized;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier();
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      // Wait until Firebase Auth emits its first event before deciding
      if (!authNotifier.isInitialized) return null;

      final user = authNotifier.user;
      final isLoggingIn = state.matchedLocation == '/login';

      if (user == null) {
        // Not authenticated → go to login
        return isLoggingIn ? null : '/login';
      }

      // Authenticated → leave login page
      if (isLoggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/start-session/:unitId',
        builder: (context, state) {
          final unitId = state.pathParameters['unitId']!;
          return StartSessionScreen(unitId: unitId);
        },
      ),
      GoRoute(
        path: '/session-detail/:sessionId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return SessionDetailScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/checkout/:sessionId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return CheckoutScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/add-member',
        builder: (context, state) => const AddMemberScreen(),
      ),
      GoRoute(
        path: '/member-detail/:memberId',
        builder: (context, state) {
          final memberId = state.pathParameters['memberId']!;
          return MemberDetailScreen(memberId: memberId);
        },
      ),
      GoRoute(
        path: '/manage-tariffs',
        builder: (context, state) => const ManageTariffScreen(),
      ),
      GoRoute(
        path: '/manage-operators',
        builder: (context, state) => const ManageOperatorsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Text(
          'Rute tidak ditemukan: ${state.error}',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    ),
  );
});
