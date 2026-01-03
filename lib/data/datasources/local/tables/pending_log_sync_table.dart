import 'package:drift/drift.dart';

class PendingLogSyncOps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()(); // create, update, delete
  IntColumn get logId => integer().nullable()();
  TextColumn get userId => text()();
  TextColumn get title => text().nullable()();
  TextColumn get content => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
  DateTimeColumn get enqueuedAt => dateTime().withDefault(currentDateAndTime)();
}
