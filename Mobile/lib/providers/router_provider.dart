import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/job_models.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_shell.dart';
import '../screens/jobs/job_detail_screen.dart';
import '../screens/preferences/preferences_screen.dart';
import '../screens/resume/resume_screen.dart';
import 'auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Fade + slight upward slide, used for top-level pushed routes.
CustomTransitionPage<void> _buildPageWithTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/jobs',
    refreshListenable: _RouterRefreshListenable(ref),
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isBootstrapping = authState.status == AuthStatus.unknown;
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/signup';

      if (isBootstrapping) return null;
      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/jobs';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/preferences',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const PreferencesScreen(),
        ),
      ),
      GoRoute(
        path: '/jobs/:jobId',
        pageBuilder: (context, state) {
          final job = state.extra as JobPosting?;
          return _buildPageWithTransition(
            key: state.pageKey,
            child: JobDetailScreen(
              jobId: state.pathParameters['jobId']!,
              initialJob: job,
            ),
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/jobs', builder: (context, state) => const JobsTab()),
          GoRoute(
            path: '/saved',
            builder: (context, state) => const SavedTab(),
          ),
          GoRoute(
            path: '/resume',
            builder: (context, state) {
              final extra = state.extra;
              if (extra is JobMatchResponse) {
                return ResumeScreen(matchResult: extra);
              }
              return const ResumeScreen();
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileTab(),
          ),
        ],
      ),
    ],
  );
});

class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(this.ref) {
    ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }

  final Ref ref;
}
