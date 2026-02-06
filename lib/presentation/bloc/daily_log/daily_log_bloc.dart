import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_daily_log/core/auth/auth_repository.dart';
import 'package:my_daily_log/domain/repositories/daily_log_repository.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_event.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_state.dart';

class DailyLogBloc extends Bloc<DailyLogEvent, DailyLogState> {
  final DailyLogRepository repository;
  final AuthRepository authRepository;

  DailyLogBloc({required this.repository, required this.authRepository})
    : super(const DailyLogInitial()) {
    on<LoadDailyLogs>(_onLoadDailyLogs);
    on<SyncDailyLogs>(_onSyncDailyLogs);
    on<AddDailyLog>(_onAddDailyLog);
    on<UpdateDailyLog>(_onUpdateDailyLog);
    on<DeleteDailyLog>(_onDeleteDailyLog);
    on<ClearAllLogs>(_onClearAllLogs);
  }

  Future<void> _onLoadDailyLogs(
    LoadDailyLogs event,
    Emitter<DailyLogState> emit,
  ) async {
    try {
      emit(const DailyLogLoading());

      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(const DailyLogError('User not authenticated'));
        return;
      }

      final logs = await repository.getAllLogsByUser(user.id);
      emit(DailyLogLoaded(logs));
    } catch (e) {
      emit(DailyLogError('Failed to load logs: $e'));
    }
  }

  Future<void> _onSyncDailyLogs(
    SyncDailyLogs event,
    Emitter<DailyLogState> emit,
  ) async {
    try {
      emit(const DailyLogLoading());

      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(const DailyLogError('User not authenticated'));
        return;
      }

      // Attempt to sync remote changes first
      await repository.syncRemoteData(user.id);

      final logs = await repository.getAllLogsByUser(user.id);
      emit(DailyLogLoaded(logs));
    } catch (e) {
      emit(DailyLogError('Failed to sync logs: $e'));
    }
  }

  Future<void> _onAddDailyLog(
    AddDailyLog event,
    Emitter<DailyLogState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(const DailyLogError('User not authenticated'));
        return;
      }

      await repository.createLog(
        userId: user.id,
        title: event.log.title,
        content: event.log.content,
      );

      final logs = await repository.getAllLogsByUser(user.id);
      emit(DailyLogLoaded(logs));
    } catch (e) {
      emit(DailyLogError('Failed to add log: $e'));
    }
  }

  Future<void> _onUpdateDailyLog(
    UpdateDailyLog event,
    Emitter<DailyLogState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(const DailyLogError('User not authenticated'));
        return;
      }

      await repository.updateLog(event.log);

      final logs = await repository.getAllLogsByUser(user.id);
      emit(DailyLogLoaded(logs));
    } catch (e) {
      emit(DailyLogError('Failed to update log: $e'));
    }
  }

  Future<void> _onDeleteDailyLog(
    DeleteDailyLog event,
    Emitter<DailyLogState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(const DailyLogError('User not authenticated'));
        return;
      }

      await repository.deleteLog(int.parse(event.id));

      final logs = await repository.getAllLogsByUser(user.id);
      emit(DailyLogLoaded(logs));
    } catch (e) {
      emit(DailyLogError('Failed to delete log: $e'));
    }
  }

  Future<void> _onClearAllLogs(
    ClearAllLogs event,
    Emitter<DailyLogState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(const DailyLogInitial());
        return;
      }

      await repository.deleteAllLogsByUser(user.id);
      emit(const DailyLogInitial());
    } catch (e) {
      emit(const DailyLogInitial());
    }
  }
}
