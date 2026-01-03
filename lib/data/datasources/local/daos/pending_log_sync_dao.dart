import 'package:drift/drift.dart';
import 'package:my_daily_log/data/datasources/local/app_database.dart';
import 'package:my_daily_log/data/datasources/local/tables/pending_log_sync_table.dart';

part 'pending_log_sync_dao.g.dart';

@DriftAccessor(tables: [PendingLogSyncOps])
class PendingLogSyncDao extends DatabaseAccessor<AppDatabase>
    with _$PendingLogSyncDaoMixin {
  PendingLogSyncDao(super.db);

  Future<int> insertOp(PendingLogSyncOpsCompanion op) {
    return into(pendingLogSyncOps).insert(op);
  }

  Future<List<PendingLogSyncOp>> getAllOps() {
    return (select(
      pendingLogSyncOps,
    )..orderBy([(t) => OrderingTerm.asc(t.enqueuedAt)])).get();
  }

  Future<int> deleteOp(int id) {
    return (delete(pendingLogSyncOps)..where((t) => t.id.equals(id))).go();
  }

  Future<int> clearAll() {
    return delete(pendingLogSyncOps).go();
  }

  Future<int> touchAttempt(int id, DateTime time) {
    return (update(pendingLogSyncOps)..where((t) => t.id.equals(id))).write(
      PendingLogSyncOpsCompanion(lastAttempt: Value(time)),
    );
  }
}
