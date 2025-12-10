import 'package:equatable/equatable.dart';
import 'package:my_daily_log/domain/entities/daily_log.dart';

abstract class DailyLogEvent extends Equatable {
  const DailyLogEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailyLogs extends DailyLogEvent {
  const LoadDailyLogs();
}

class AddDailyLog extends DailyLogEvent {
  final DailyLog log;

  const AddDailyLog(this.log);

  @override
  List<Object?> get props => [log];
}

class UpdateDailyLog extends DailyLogEvent {
  final DailyLog log;

  const UpdateDailyLog(this.log);

  @override
  List<Object?> get props => [log];
}

class DeleteDailyLog extends DailyLogEvent {
  final String id;

  const DeleteDailyLog(this.id);

  @override
  List<Object?> get props => [id];
}
