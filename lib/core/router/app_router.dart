import 'package:go_router/go_router.dart';
import 'package:my_daily_log/presentation/screens/daily_log_detail_screen.dart';
import 'package:my_daily_log/presentation/screens/daily_log_list_screen.dart';
import 'package:my_daily_log/presentation/screens/not_found_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String logDetail = '/log/:id';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const DailyLogListScreen(),
      ),
      GoRoute(
        path: logDetail,
        name: 'logDetail',
        builder: (context, state) {
          final logId = state.pathParameters['id']!;
          return DailyLogDetailScreen(logId: logId);
        },
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
