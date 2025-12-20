import 'package:my_daily_log/data/datasources/local/app_database.dart';
import 'package:my_daily_log/domain/entities/daily_log.dart' as entity;

extension DailyLogModelExtension on DailyLog {
  entity.DailyLog toEntity() {
    return entity.DailyLog(
      id: id.toString(),
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension DailyLogEntityExtension on entity.DailyLog {
  DailyLog toDrift(String userId) {
    return DailyLog(
      id: int.parse(id),
      userId: userId,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
