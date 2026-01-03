import 'package:my_daily_log/domain/entities/daily_log.dart';

abstract class DailyLogRepository {
  Future<List<DailyLog>> getAllLogsByUser(String userId);
  Stream<List<DailyLog>> watchAllLogsByUser(String userId);
  Future<DailyLog?> getLogById(int id);

  Future<DailyLog> createLog({
    required String userId,
    required String title,
    required String content,
  });

  Future<void> updateLog(DailyLog log);
  Future<void> deleteLog(int id);
  Future<void> deleteAllLogsByUser(String userId);
  Future<List<DailyLog>> searchLogs(String userId, String searchTerm);
  Future<int> getLogCountByUser(String userId);
  Future<void> syncRemoteData(String userId);
}
