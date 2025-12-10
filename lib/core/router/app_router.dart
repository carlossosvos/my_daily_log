import 'package:go_router/go_router.dart';
import 'package:my_daily_log/core/router/app_route.dart';
import 'package:my_daily_log/presentation/screens/daily_log_detail_screen.dart';
import 'package:my_daily_log/presentation/screens/daily_log_list_screen.dart';
import 'package:my_daily_log/presentation/screens/not_found_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home.path,
    routes: [
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
