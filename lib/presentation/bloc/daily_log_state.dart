import 'package:equatable/equatable.dart';
import 'package:my_daily_log/domain/entities/daily_log.dart';

abstract class DailyLogState extends Equatable {
  const DailyLogState();

  @override
  List<Object?> get props => [];
}

class DailyLogInitial extends DailyLogState {
  const DailyLogInitial();
}

class DailyLogLoading extends DailyLogState {
  const DailyLogLoading();
}

class DailyLogLoaded extends DailyLogState {
  final List<DailyLog> logs;

  const DailyLogLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class DailyLogError extends DailyLogState {
  final String message;

  const DailyLogError(this.message);

  @override
  List<Object?> get props => [message];
}

