import 'package:get_it/get_it.dart';
import 'package:my_daily_log/core/auth/auth0_service.dart';
import 'package:my_daily_log/core/auth/auth_repository.dart';
import 'package:my_daily_log/core/auth/auth_repository_impl.dart';
import 'package:my_daily_log/core/config/app_config.dart';
import 'package:my_daily_log/data/datasources/local/app_database.dart';
import 'package:my_daily_log/data/datasources/remote/daily_log_remote_datasource.dart';
import 'package:my_daily_log/data/repositories/daily_log_repository_impl.dart';
import 'package:my_daily_log/domain/repositories/daily_log_repository.dart';
import 'package:my_daily_log/presentation/bloc/auth/auth_bloc.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  _initAuth();
  _initDailyLogs();
  await _initCore();
  await _initExternal();
}

void _initAuth() {
  sl.registerFactory(() => AuthBloc(sl(), sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
}

void _initDailyLogs() {
  sl.registerFactory(
    () => DailyLogBloc(repository: sl(), authRepository: sl()),
  );
  sl.registerLazySingleton<DailyLogRepository>(
    () => DailyLogRepositoryImpl(
      sl<AppDatabase>().dailyLogDao,
      sl<DailyLogRemoteDatasource>(),
      sl<AppDatabase>().pendingLogSyncDao,
    ),
  );
  sl.registerLazySingleton<DailyLogRemoteDatasource>(
    () => DailyLogRemoteDatasource(sl<SupabaseClient>()),
  );
}

Future<void> _initCore() async {
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}

Future<void> _initExternal() async {
  sl.registerLazySingleton(() => Auth0Service());
}
