import 'package:drift/drift.dart';
import 'package:my_daily_log/data/datasources/local/app_database.dart';
import 'package:my_daily_log/data/datasources/local/daos/daily_log_dao.dart';
import 'package:my_daily_log/data/datasources/remote/daily_log_remote_datasource.dart';
import 'package:my_daily_log/data/models/daily_log_model.dart';
import 'package:my_daily_log/domain/entities/daily_log.dart' as entity;
import 'package:my_daily_log/domain/repositories/daily_log_repository.dart';

class DailyLogRepositoryImpl implements DailyLogRepository {
  final DailyLogDao _localDao;
  final DailyLogRemoteDatasource _remoteDatasource;

  DailyLogRepositoryImpl(this._localDao, this._remoteDatasource);

  @override
  Future<List<entity.DailyLog>> getAllLogsByUser(String userId) async {
    final logs = await _localDao.getAllLogsByUser(userId);
    return logs.map((log) => log.toEntity()).toList();
  }

  @override
  Stream<List<entity.DailyLog>> watchAllLogsByUser(String userId) {
    return _localDao
        .watchAllLogsByUser(userId)
        .map((logs) => logs.map((log) => log.toEntity()).toList());
  }

  @override
  Future<entity.DailyLog?> getLogById(int id) async {
    final log = await _localDao.getLogById(id);
    return log?.toEntity();
  }

  @override
  Future<entity.DailyLog> createLog({
    required String userId,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();

    int? remoteId;

    try {
      // Create in remote first to get the Supabase-generated ID
      final remoteResponse = await _remoteDatasource.createLog(
        userId: userId,
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );

      remoteId = remoteResponse['id'] as int;

      // Now create locally with the same ID
      final companion = DailyLogsCompanion(
        id: Value(remoteId),
        userId: Value(userId),
        title: Value(title),
        content: Value(content),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      await _localDao.createLog(companion);
    } catch (e) {
      // Fallback: create locally if remote fails
      final companion = DailyLogsCompanion(
        userId: Value(userId),
        title: Value(title),
        content: Value(content),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      final localId = await _localDao.createLog(companion);
      remoteId = localId;
    }

    return entity.DailyLog(
      id: remoteId.toString(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> updateLog(entity.DailyLog log) async {
    final existingLog = await _localDao.getLogById(int.parse(log.id));
    if (existingLog == null) {
      throw Exception('Log not found');
    }

    final now = DateTime.now();
    final updatedLog = existingLog.copyWith(
      title: log.title,
      content: log.content,
      updatedAt: now,
    );

    await _localDao.updateLog(updatedLog);

    try {
      await _remoteDatasource.updateLog(
        id: int.parse(log.id),
        title: log.title,
        content: log.content,
        updatedAt: now,
      );
    } catch (e) {
      // Log error but don't fail - local-first approach
    }
  }

  @override
  Future<void> deleteLog(int id) async {
    await _localDao.deleteLog(id);

    try {
      await _remoteDatasource.deleteLog(id);
    } catch (e) {
      // Log error but don't fail - local-first approach
    }
  }

  @override
  Future<void> deleteAllLogsByUser(String userId) async {
    await _localDao.deleteAllLogsByUser(userId);

    try {
      await _remoteDatasource.deleteAllLogsByUser(userId);
    } catch (e) {
      // Log error but don't fail - local-first approach
    }
  }

  @override
  Future<List<entity.DailyLog>> searchLogs(
    String userId,
    String searchTerm,
  ) async {
    final logs = await _localDao.searchLogs(userId, searchTerm);
    return logs.map((log) => log.toEntity()).toList();
  }

  @override
  Future<int> getLogCountByUser(String userId) async {
    return _localDao.getLogCountByUser(userId);
  }

  @override
  Future<void> syncRemoteData(String userId) async {
    try {
      final remoteLogs = await _remoteDatasource.getAllLogsByUser(userId);

      for (final remoteLog in remoteLogs) {
        final remoteId = remoteLog['id'] as int;
        final localLog = await _localDao.getLogById(remoteId);

        if (localLog == null) {
          // Log doesn't exist locally, insert it
          final companion = DailyLogsCompanion(
            id: Value(remoteId),
            userId: Value(remoteLog['user_id'] as String),
            title: Value(remoteLog['title'] as String),
            content: Value(remoteLog['content'] as String),
            createdAt: Value(DateTime.parse(remoteLog['created_at'] as String)),
            updatedAt: Value(DateTime.parse(remoteLog['updated_at'] as String)),
          );
          await _localDao.createLog(companion);
        } else {
          // Log exists, check which is newer
          final remoteUpdatedAt = DateTime.parse(
            remoteLog['updated_at'] as String,
          );
          if (remoteUpdatedAt.isAfter(localLog.updatedAt)) {
            // Remote is newer, update local
            final updatedLog = localLog.copyWith(
              title: remoteLog['title'] as String,
              content: remoteLog['content'] as String,
              updatedAt: remoteUpdatedAt,
            );
            await _localDao.updateLog(updatedLog);
          }
        }
      }
    } catch (e) {
      // Sync failed, but don't block login
    }
  }
}
