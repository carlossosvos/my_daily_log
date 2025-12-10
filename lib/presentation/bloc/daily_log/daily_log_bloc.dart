import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_daily_log/domain/entities/daily_log.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_event.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_state.dart';

class DailyLogBloc extends Bloc<DailyLogEvent, DailyLogState> {
  DailyLogBloc() : super(const DailyLogInitial()) {
    on<LoadDailyLogs>(_onLoadDailyLogs);
    on<AddDailyLog>(_onAddDailyLog);
    on<UpdateDailyLog>(_onUpdateDailyLog);
    on<DeleteDailyLog>(_onDeleteDailyLog);
  }

  // Temporary in-memory storage (will be replaced with repository later)
  final List<DailyLog> _logs = [];

  void _onLoadDailyLogs(LoadDailyLogs event, Emitter<DailyLogState> emit) {
    emit(const DailyLogLoading());
    // Sort by date, newest first
    final sortedLogs = List<DailyLog>.from(_logs)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(DailyLogLoaded(sortedLogs));
  }

  void _onAddDailyLog(AddDailyLog event, Emitter<DailyLogState> emit) {
    _logs.add(event.log);
    final sortedLogs = List<DailyLog>.from(_logs)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(DailyLogLoaded(sortedLogs));
  }

  void _onUpdateDailyLog(UpdateDailyLog event, Emitter<DailyLogState> emit) {
    final index = _logs.indexWhere((log) => log.id == event.log.id);
    if (index != -1) {
      _logs[index] = event.log;
      final sortedLogs = List<DailyLog>.from(_logs)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(DailyLogLoaded(sortedLogs));
    }
  }

  void _onDeleteDailyLog(DeleteDailyLog event, Emitter<DailyLogState> emit) {
    _logs.removeWhere((log) => log.id == event.id);
    final sortedLogs = List<DailyLog>.from(_logs)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(DailyLogLoaded(sortedLogs));
  }
}
