import 'package:drift/drift.dart';
import 'package:my_daily_log/data/datasources/local/app_database.dart';
import 'package:my_daily_log/data/datasources/local/daos/daily_log_dao.dart';
import 'package:my_daily_log/data/datasources/local/daos/pending_log_sync_dao.dart';
import 'package:my_daily_log/data/datasources/remote/daily_log_remote_datasource.dart';
import 'package:my_daily_log/data/models/daily_log_model.dart';
import 'package:my_daily_log/domain/entities/daily_log.dart' as entity;
import 'package:my_daily_log/domain/repositories/daily_log_repository.dart';

class DailyLogRepositoryImpl implements DailyLogRepository {
  final DailyLogDao _localDao;
  final DailyLogRemoteDatasource _remoteDatasource;
  final PendingLogSyncDao _pendingDao;

  DailyLogRepositoryImpl(
    this._localDao,
    this._remoteDatasource,
    this._pendingDao,
  );

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
    // Use a client-generated temp id (negative to avoid clashing with server increments)
    final tempId = -DateTime.now().millisecondsSinceEpoch;

    final companion = DailyLogsCompanion(
      id: Value(tempId),
      userId: Value(userId),
      title: Value(title),
      content: Value(content),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _localDao.createLog(companion);

    try {
      await _remoteDatasource.createLog(
        id: tempId,
        userId: userId,
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      // Enqueue pending create to sync later
      await _pendingDao.insertOp(
        PendingLogSyncOpsCompanion(
          operation: const Value('create'),
          logId: Value(tempId),
          userId: Value(userId),
          title: Value(title),
          content: Value(content),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }

    return entity.DailyLog(
      id: tempId.toString(),
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
      await _pendingDao.insertOp(
        PendingLogSyncOpsCompanion(
          operation: const Value('update'),
          logId: Value(int.parse(log.id)),
          userId: Value(existingLog.userId),
          title: Value(log.title),
          content: Value(log.content),
          updatedAt: Value(now),
          lastAttempt: Value(DateTime.now()),
        ),
      );
    }
  }

  @override
  Future<void> deleteLog(int id) async {
    await _localDao.deleteLog(id);

    try {
      await _remoteDatasource.deleteLog(id);
    } catch (e) {
      await _pendingDao.insertOp(
        PendingLogSyncOpsCompanion(
          operation: const Value('delete'),
          logId: Value(id),
          userId: const Value(''),
          lastAttempt: Value(DateTime.now()),
        ),
      );
    }
  }

  @override
  Future<void> deleteAllLogsByUser(String userId) async {
    await _localDao.deleteAllLogsByUser(userId);

    try {
      await _remoteDatasource.deleteAllLogsByUser(userId);
    } catch (e) {
      // No bulk enqueue for now
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
      // First, flush pending operations
      final pendingOps = await _pendingDao.getAllOps();
      for (final op in pendingOps) {
        try {
          if (op.operation == 'create') {
            await _remoteDatasource.createLog(
              id: op.logId,
              userId: op.userId,
              title: op.title ?? '',
              content: op.content ?? '',
              createdAt: op.createdAt ?? DateTime.now(),
              updatedAt: op.updatedAt ?? DateTime.now(),
            );
          } else if (op.operation == 'update') {
            if (op.logId != null) {
              await _remoteDatasource.updateLog(
                id: op.logId!,
                title: op.title ?? '',
                content: op.content ?? '',
                updatedAt: op.updatedAt ?? DateTime.now(),
              );
            }
          } else if (op.operation == 'delete') {
            if (op.logId != null) {
              await _remoteDatasource.deleteLog(op.logId!);
            }
          }

          await _pendingDao.deleteOp(op.id);
        } catch (_) {
          // Leave op in queue for next attempt
          await _pendingDao.touchAttempt(op.id, DateTime.now());
        }
      }

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
