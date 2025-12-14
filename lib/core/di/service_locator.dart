import 'package:get_it/get_it.dart';
import 'package:my_daily_log/core/auth/auth0_service.dart';
import 'package:my_daily_log/core/auth/auth_repository.dart';
import 'package:my_daily_log/core/auth/auth_repository_impl.dart';
import 'package:my_daily_log/presentation/bloc/auth/auth_bloc.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  //! Features
  _initAuth();
  _initDailyLogs();

  //! Core
  await _initCore();

  //! External
  await _initExternal();
}

void _initAuth() {
  // Bloc
  sl.registerFactory(() => AuthBloc(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
}

void _initDailyLogs() {
  // Bloc
  sl.registerFactory(() => DailyLogBloc());
}

Future<void> _initCore() async {
  // Core services will go here (Supabase later)
}

Future<void> _initExternal() async {
  // Auth0 service
  sl.registerLazySingleton(() => Auth0Service());
}
