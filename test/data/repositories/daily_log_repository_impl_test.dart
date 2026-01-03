import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_daily_log/data/datasources/local/app_database.dart';
import 'package:my_daily_log/data/datasources/remote/daily_log_remote_datasource.dart';
import 'package:my_daily_log/data/repositories/daily_log_repository_impl.dart';

// Mock class for remote datasource - we'll fake network calls
class MockRemoteDatasource extends Mock implements DailyLogRemoteDatasource {}

void main() {
  // These variables are shared across tests
  late AppDatabase db;
  late DailyLogRepositoryImpl repository;
  late MockRemoteDatasource mockRemote;

  // setUp runs before each test - creates fresh instances
  setUp(() {
    // Create an in-memory database that doesn't persist between tests
    db = AppDatabase.forTesting(NativeDatabase.memory());

    // Create a mock remote datasource
    mockRemote = MockRemoteDatasource();

    // Create repository with real local DAOs and mock remote
    repository = DailyLogRepositoryImpl(
      db.dailyLogDao,
      mockRemote,
      db.pendingLogSyncDao,
    );
  });

  // tearDown runs after each test - cleanup
  tearDown(() async {
    await db.close();
  });

  group('createLog', () {
    test('uses remote ID and stores locally on success', () async {
      // Arrange: Set up what we expect the mock to do
      when(
        () => mockRemote.createLog(
          userId: any(named: 'userId'),
          title: any(named: 'title'),
          content: any(named: 'content'),
          createdAt: any(named: 'createdAt'),
          updatedAt: any(named: 'updatedAt'),
          id: any(named: 'id'),
        ),
      ).thenAnswer((_) async => {'id': -12345});

      // Act: Call the method we're testing
      final log = await repository.createLog(
        userId: 'user1',
        title: 'Test Title',
        content: 'Test Content',
      );

      // Assert: Uses negative temp ID (offline-first)
      expect(int.parse(log.id), lessThan(0));
      expect(log.title, 'Test Title');
      expect(log.content, 'Test Content');

      // Check it was stored locally
      final localLog = await db.dailyLogDao.getLogById(int.parse(log.id));
      expect(localLog, isNotNull);
      expect(localLog!.title, 'Test Title');

      // Remote should have been called
      verify(
        () => mockRemote.createLog(
          id: any(named: 'id'),
          userId: 'user1',
          title: 'Test Title',
          content: 'Test Content',
          createdAt: any(named: 'createdAt'),
          updatedAt: any(named: 'updatedAt'),
        ),
      ).called(1);

      // No pending ops should be queued on success
      final pendingOps = await db.pendingLogSyncDao.getAllOps();
      expect(pendingOps, isEmpty);
    });

    test('creates locally and enqueues pending op on remote failure', () async {
      // Arrange: Make the remote call fail
      when(
        () => mockRemote.createLog(
          userId: any(named: 'userId'),
          title: any(named: 'title'),
          content: any(named: 'content'),
          createdAt: any(named: 'createdAt'),
          updatedAt: any(named: 'updatedAt'),
          id: any(named: 'id'),
        ),
      ).thenThrow(Exception('Network error'));

      // Act
      final log = await repository.createLog(
        userId: 'user1',
        title: 'Offline Title',
        content: 'Offline Content',
      );

      // Assert: Log should still be created with local ID
      expect(log.title, 'Offline Title');

      // Check pending op was queued
      final pendingOps = await db.pendingLogSyncDao.getAllOps();
      expect(pendingOps.length, 1);
      expect(pendingOps.first.operation, 'create');
      expect(pendingOps.first.title, 'Offline Title');
    });
  });

  group('updateLog', () {
    test('updates local first, then remote', () async {
      // Arrange: Create a log first
      await db.dailyLogDao.createLog(
        DailyLogsCompanion(
          id: const Value(1),
          userId: const Value('user1'),
          title: const Value('Original'),
          content: const Value('Original content'),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      when(
        () => mockRemote.updateLog(
          id: any(named: 'id'),
          title: any(named: 'title'),
          content: any(named: 'content'),
          updatedAt: any(named: 'updatedAt'),
        ),
      ).thenAnswer((_) async => {});

      // Act: Update the log
      final updatedLog = await repository.getLogById(1);
      await repository.updateLog(
        updatedLog!.copyWith(title: 'Updated', content: 'Updated content'),
      );

      // Assert: Local should be updated
      final localLog = await db.dailyLogDao.getLogById(1);
      expect(localLog!.title, 'Updated');
      expect(localLog.content, 'Updated content');

      // Remote should have been called
      verify(
        () => mockRemote.updateLog(
          id: 1,
          title: 'Updated',
          content: 'Updated content',
          updatedAt: any(named: 'updatedAt'),
        ),
      ).called(1);

      // No pending ops on success
      final pendingOps = await db.pendingLogSyncDao.getAllOps();
      expect(pendingOps, isEmpty);
    });

    test('enqueues pending op when remote update fails', () async {
      // Arrange
      await db.dailyLogDao.createLog(
        DailyLogsCompanion(
          id: const Value(1),
          userId: const Value('user1'),
          title: const Value('Original'),
          content: const Value('Original'),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      when(
        () => mockRemote.updateLog(
          id: any(named: 'id'),
          title: any(named: 'title'),
          content: any(named: 'content'),
          updatedAt: any(named: 'updatedAt'),
        ),
      ).thenThrow(Exception('Network error'));

      // Act
      final log = await repository.getLogById(1);
      await repository.updateLog(log!.copyWith(title: 'Updated Offline'));

      // Assert: Local is updated
      final localLog = await db.dailyLogDao.getLogById(1);
      expect(localLog!.title, 'Updated Offline');

      // Pending op is queued
      final pendingOps = await db.pendingLogSyncDao.getAllOps();
      expect(pendingOps.length, 1);
      expect(pendingOps.first.operation, 'update');
      expect(pendingOps.first.logId, 1);
    });
  });

  group('deleteLog', () {
    test('deletes locally and remotely on success', () async {
      // Arrange
      await db.dailyLogDao.createLog(
        DailyLogsCompanion(
          id: const Value(1),
          userId: const Value('user1'),
          title: const Value('To Delete'),
          content: const Value('Content'),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      when(() => mockRemote.deleteLog(any())).thenAnswer((_) async => {});

      // Act
      await repository.deleteLog(1);

      // Assert
      final localLog = await db.dailyLogDao.getLogById(1);
      expect(localLog, isNull);

      verify(() => mockRemote.deleteLog(1)).called(1);

      final pendingOps = await db.pendingLogSyncDao.getAllOps();
      expect(pendingOps, isEmpty);
    });

    test('enqueues pending op when remote delete fails', () async {
      // Arrange
      await db.dailyLogDao.createLog(
        DailyLogsCompanion(
          id: const Value(1),
          userId: const Value('user1'),
          title: const Value('To Delete'),
          content: const Value('Content'),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      when(
        () => mockRemote.deleteLog(any()),
      ).thenThrow(Exception('Network error'));

      // Act
      await repository.deleteLog(1);

      // Assert: Still deleted locally
      final localLog = await db.dailyLogDao.getLogById(1);
      expect(localLog, isNull);

      // Pending op queued
      final pendingOps = await db.pendingLogSyncDao.getAllOps();
      expect(pendingOps.length, 1);
      expect(pendingOps.first.operation, 'delete');
      expect(pendingOps.first.logId, 1);
    });
  });

  group('syncRemoteData', () {
    test('flushes pending creates and removes them from queue', () async {
      // Arrange: Create a local log and pending op
      await db.dailyLogDao.createLog(
        DailyLogsCompanion(
          id: const Value(100),
          userId: const Value('user1'),
          title: const Value('Pending Create'),
          content: const Value('Content'),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await db.pendingLogSyncDao.insertOp(
        PendingLogSyncOpsCompanion(
          operation: const Value('create'),
          logId: const Value(100),
          userId: const Value('user1'),
          title: const Value('Pending Create'),
          content: const Value('Content'),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Mock successful remote create
      when(
        () => mockRemote.createLog(
          id: any(named: 'id'),
          userId: any(named: 'userId'),
          title: any(named: 'title'),
          content: any(named: 'content'),
          createdAt: any(named: 'createdAt'),
          updatedAt: any(named: 'updatedAt'),
        ),
      ).thenAnswer((_) async => {'id': 100});

      // Mock empty remote logs list
      when(
        () => mockRemote.getAllLogsByUser(any()),
      ).thenAnswer((_) async => []);

      // Act
      await repository.syncRemoteData('user1');

      // Assert: Pending op should be cleared
      final pendingOps = await db.pendingLogSyncDao.getAllOps();
      expect(pendingOps, isEmpty);

      // Remote create should have been called
      verify(
        () => mockRemote.createLog(
          id: 100,
          userId: 'user1',
          title: 'Pending Create',
          content: 'Content',
          createdAt: any(named: 'createdAt'),
          updatedAt: any(named: 'updatedAt'),
        ),
      ).called(1);
    });

    test('pulls remote logs and updates local when remote is newer', () async {
      // Arrange: Create older local log
      final oldDate = DateTime.now().subtract(const Duration(days: 1));
      final newDate = DateTime.now();

      await db.dailyLogDao.createLog(
        DailyLogsCompanion(
          id: const Value(1),
          userId: const Value('user1'),
          title: const Value('Old Title'),
          content: const Value('Old Content'),
          createdAt: Value(oldDate),
          updatedAt: Value(oldDate),
        ),
      );

      // Mock remote log with newer data
      when(() => mockRemote.getAllLogsByUser(any())).thenAnswer(
        (_) async => [
          {
            'id': 1,
            'user_id': 'user1',
            'title': 'New Title',
            'content': 'New Content',
            'created_at': oldDate.toIso8601String(),
            'updated_at': newDate.toIso8601String(),
          },
        ],
      );

      // Act
      await repository.syncRemoteData('user1');

      // Assert: Local should be updated with remote data
      final localLog = await db.dailyLogDao.getLogById(1);
      expect(localLog!.title, 'New Title');
      expect(localLog.content, 'New Content');
    });
  });
}
