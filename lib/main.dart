import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_daily_log/core/config/app_config.dart';
import 'package:my_daily_log/core/di/injection.dart';
import 'package:my_daily_log/core/di/service_locator.dart';
import 'package:my_daily_log/core/router/app_router.dart';
import 'package:my_daily_log/presentation/bloc/auth/auth_bloc.dart';
import 'package:my_daily_log/presentation/bloc/auth/auth_event.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_bloc.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await Injection.init();

  // Debug configuration on startup
  if (AppConfig.isDevelopment) {
    debugPrint('=== Development Configuration ===');
    debugPrint(AppConfig.debugInfo.toString());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => sl<DailyLogBloc>()..add(const LoadDailyLogs()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: AppConfig.appName,
            theme: ThemeData(
              colorScheme: const ColorScheme.light(
                primary: Colors.black87,
                surface: Colors.white,
              ),
              scaffoldBackgroundColor: Colors.grey[50],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black87),
                titleTextStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              useMaterial3: false,
            ),
            routerConfig: AppRouter.router(context),
          );
        },
      ),
    );
  }
}
