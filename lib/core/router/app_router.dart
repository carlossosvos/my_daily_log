import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_daily_log/core/router/app_route.dart';
import 'package:my_daily_log/presentation/bloc/auth/auth_bloc.dart';
import 'package:my_daily_log/presentation/bloc/auth/auth_state.dart';
import 'package:my_daily_log/presentation/screens/auth/login_screen.dart';
import 'package:my_daily_log/presentation/screens/daily_log_detail_screen.dart';
import 'package:my_daily_log/presentation/screens/daily_log_list_screen.dart';
import 'package:my_daily_log/presentation/screens/not_found_screen.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    return GoRouter(
      initialLocation: AppRoutes.home.path,
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isLoginRoute = state.matchedLocation == AppRoutes.logIn.path;

        // Don't redirect during loading states
        if (authState is AuthLoading) {
          return null;
        }

        // If not authenticated and not on login screen, redirect to login
        if (authState is AuthUnauthenticated && !isLoginRoute) {
          return AppRoutes.logIn.path;
        }

        // If has error and not on login screen, redirect to login
        if (authState is AuthError && !isLoginRoute) {
          return AppRoutes.logIn.path;
        }

        // If authenticated and on login screen, redirect to home
        if (authState is AuthAuthenticated && isLoginRoute) {
          return AppRoutes.home.path;
        }

        // No redirect needed
        return null;
      },
      refreshListenable: GoRouterRefreshStream(context.read<AuthBloc>().stream),
      routes: [
        GoRoute(
          path: AppRoutes.logIn.path,
          name: AppRoutes.logIn.name,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.home.path,
          name: AppRoutes.home.name,
          builder: (context, state) => const DailyLogListScreen(),
        ),
        GoRoute(
          path: AppRoutes.logDetail.path,
          name: AppRoutes.logDetail.name,
          builder: (context, state) {
            final logId = state.pathParameters['id']!;
            return DailyLogDetailScreen(logId: logId);
          },
        ),
      ],
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }
}

// Helper class to make GoRouter refresh when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
