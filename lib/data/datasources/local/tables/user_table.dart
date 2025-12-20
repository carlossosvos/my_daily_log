// Commented out - will be needed when Users table is activated
// import 'package:drift/drift.dart';

// ignore_for_file: dangling_library_doc_comments

/// User table definition (example for future implementation)
/// Uncomment and modify when you're ready to store user data locally
///
/// To activate this table:
/// 1. Uncomment this class
/// 2. Add 'Users' to @DriftDatabase annotation in app_database.dart
/// 3. Run: dart run build_runner build --delete-conflicting-outputs
/*
class Users extends Table {
  /// Primary key - auto-incrementing ID
  IntColumn get id => integer().autoIncrement()();

  /// User ID from Auth0
  TextColumn get auth0Id => text().unique()();

  /// User email
  TextColumn get email => text()();

  /// User name (optional)
  TextColumn get name => text().nullable()();

  /// Profile picture URL (optional)
  TextColumn get pictureUrl => text().nullable()();

  /// Email verification status
  BoolColumn get isEmailVerified => boolean().withDefault(const Constant(false))();

  /// When the user record was created
  DateTimeColumn get createdAt => dateTime()();

  /// When the user record was last updated
  DateTimeColumn get updatedAt => dateTime()();
}
*/
