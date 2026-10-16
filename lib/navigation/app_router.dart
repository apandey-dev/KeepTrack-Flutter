import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/profile/screens/profile_detail_screen.dart';
import '../features/schedule/schedule_screen.dart';
import '../features/today/today_screen.dart';
import '../services/auth_service.dart';
import 'main_shell_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class AuthRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  AuthRouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, _) {
      notifyListeners();
    });
  }
}

final authRouterNotifierProvider = Provider<AuthRouterNotifier>((ref) {
  return AuthRouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authRouterNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);

      // Still resolving initial auth state from Firebase
      if (authAsync.isLoading) {
        return '/splash';
      }

      final user = authAsync.value;
      final isLoggedIn = user != null;

      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';
      final isSplash = state.matchedLocation == '/splash';

      if (!isLoggedIn) {
        // If unauthenticated and on an auth page, stay there
        if (isAuthRoute) return null;
        // Otherwise, send to login
        return '/login';
      }

      // If logged in, don't allow auth pages or splash
      if (isAuthRoute || isSplash) {
        return '/today';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileDetailScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/record',
                builder: (context, state) => const ScheduleScreen(),
              ),
              GoRoute(
                path: '/schedule',
                redirect: (_, _) => '/record',
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
