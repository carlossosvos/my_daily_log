import 'package:drift/drift.dart';
import 'package:my_daily_log/data/datasources/local/app_database.dart';
import 'package:my_daily_log/data/datasources/local/daos/daily_log_dao.dart';
import 'package:my_daily_log/data/models/daily_log_model.dart';
import 'package:my_daily_log/domain/entities/daily_log.dart' as entity;
import 'package:my_daily_log/domain/repositories/daily_log_repository.dart';

class DailyLogRepositoryImpl implements DailyLogRepository {
  final DailyLogDao _dao;

  DailyLogRepositoryImpl(this._dao);

  @override
  Future<List<entity.DailyLog>> getAllLogsByUser(String userId) async {
    final logs = await _dao.getAllLogsByUser(userId);
    return logs.map((log) => log.toEntity()).toList();
  }

  @override
  Stream<List<entity.DailyLog>> watchAllLogsByUser(String userId) {
    return _dao
        .watchAllLogsByUser(userId)
        .map((logs) => logs.map((log) => log.toEntity()).toList());
  }

  @override
  Future<entity.DailyLog?> getLogById(int id) async {
    final log = await _dao.getLogById(id);
    return log?.toEntity();
  }

  @override
  Future<entity.DailyLog> createLog({
    required String userId,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();

    // Create a companion object for insertion
    final companion = DailyLogsCompanion(
      userId: Value(userId),
      title: Value(title),
      content: Value(content),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    // Insert and get the generated ID
    final id = await _dao.createLog(companion);

    // Return the created entity
    return entity.DailyLog(
      id: id.toString(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> updateLog(entity.DailyLog log) async {
    // We need the userId to convert back to Drift model
    // For now, we'll fetch the existing log to get the userId
    final existingLog = await _dao.getLogById(int.parse(log.id));
    if (existingLog == null) {
      throw Exception('Log not found');
    }

    final updatedLog = existingLog.copyWith(
      title: log.title,
      content: log.content,
      updatedAt: DateTime.now(),
    );

    await _dao.updateLog(updatedLog);
  }

  @override
  Future<void> deleteLog(int id) async {
    await _dao.deleteLog(id);
  }

  @override
  Future<void> deleteAllLogsByUser(String userId) async {
    await _dao.deleteAllLogsByUser(userId);
  }

  @override
  Future<List<entity.DailyLog>> searchLogs(
    String userId,
    String searchTerm,
  ) async {
    final logs = await _dao.searchLogs(userId, searchTerm);
    return logs.map((log) => log.toEntity()).toList();
  }

  @override
  Future<int> getLogCountByUser(String userId) async {
    return _dao.getLogCountByUser(userId);
  }
}
