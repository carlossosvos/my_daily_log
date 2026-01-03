import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:my_daily_log/data/datasources/local/daos/daily_log_dao.dart';
import 'package:my_daily_log/data/datasources/local/daos/pending_log_sync_dao.dart';
import 'package:my_daily_log/data/datasources/local/tables/daily_log_table.dart';
import 'package:my_daily_log/data/datasources/local/tables/pending_log_sync_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [DailyLogs, PendingLogSyncOps],
  daos: [DailyLogDao, PendingLogSyncDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  DailyLogDao get dailyLogDao => DailyLogDao(this);

  @override
  PendingLogSyncDao get pendingLogSyncDao => PendingLogSyncDao(this);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.createTable(pendingLogSyncOps);
        }
      },
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'daily_log_db');
}
