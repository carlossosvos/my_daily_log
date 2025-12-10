import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_daily_log/core/router/app_router.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_bloc.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_event.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DailyLogBloc()..add(const LoadDailyLogs()),
      child: MaterialApp.router(
        title: 'My Daily Log',
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
        routerConfig: AppRouter.router,
      ),
    );
  }
}
