import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_daily_log/core/auth/auth_repository.dart';

class DailyLogRemoteDatasource {
  final SupabaseClient _client;
  final AuthRepository _authRepository;

  DailyLogRemoteDatasource(this._client, this._authRepository);

  Future<List<Map<String, dynamic>>> getAllLogsByUser(String userId) async {
    try {
      final response = await _client
          .from('daily_logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching logs from Supabase: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createLog({
    required String userId,
    required String title,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    try {
      print('Attempting to insert log to Supabase...');
      print('User ID: $userId');
      print('Title: $title');

      final response = await _client
          .from('daily_logs')
          .insert({
            'user_id': userId,
            'title': title,
            'content': content,
            'created_at': createdAt.toIso8601String(),
            'updated_at': updatedAt.toIso8601String(),
          })
          .select()
          .single();

      print('Successfully inserted log to Supabase: $response');
      return response;
    } catch (e) {
      print('ERROR inserting log to Supabase: $e');
      print('Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('Postgrest error code: ${e.code}');
        print('Postgrest error message: ${e.message}');
        print('Postgrest error details: ${e.details}');
        print('Postgrest error hint: ${e.hint}');
      }
      rethrow;
    }
  }

  Future<void> updateLog({
    required int id,
    required String title,
    required String content,
    required DateTime updatedAt,
  }) async {
    try {
      print('Attempting to update log in Supabase...');
      print('Log ID: $id');
      print('Title: $title');

      final response = await _client
          .from('daily_logs')
          .update({
            'title': title,
            'content': content,
            'updated_at': updatedAt.toIso8601String(),
          })
          .eq('id', id)
          .select();

      print('Update response: $response');

      if (response.isEmpty) {
        print(
          'WARNING: No rows were updated. ID $id may not exist in Supabase.',
        );
      } else {
        print('Successfully updated log in Supabase');
      }
    } catch (e) {
      print('ERROR updating log in Supabase: $e');
      if (e is PostgrestException) {
        print('Postgrest error code: ${e.code}');
        print('Postgrest error message: ${e.message}');
      }
      rethrow;
    }
  }

  Future<void> deleteLog(int id) async {
    try {
      print('Attempting to delete log from Supabase...');
      print('Log ID: $id');

      final response = await _client
          .from('daily_logs')
          .delete()
          .eq('id', id)
          .select();

      print('Delete response: $response');

      if (response.isEmpty) {
        print(
          'WARNING: No rows were deleted. ID $id may not exist in Supabase.',
        );
      } else {
        print('Successfully deleted log from Supabase');
      }
    } catch (e) {
      print('ERROR deleting log from Supabase: $e');
      if (e is PostgrestException) {
        print('Postgrest error code: ${e.code}');
        print('Postgrest error message: ${e.message}');
      }
      rethrow;
    }
  }

  Future<void> deleteAllLogsByUser(String userId) async {
    try {
      await _client.from('daily_logs').delete().eq('user_id', userId);
    } catch (e) {
      print('Error deleting all logs from Supabase: $e');
      rethrow;
    }
  }
}
