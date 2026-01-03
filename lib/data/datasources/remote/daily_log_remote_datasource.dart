import 'package:supabase_flutter/supabase_flutter.dart';

class DailyLogRemoteDatasource {
  final SupabaseClient _client;

  DailyLogRemoteDatasource(this._client);

  Future<List<Map<String, dynamic>>> getAllLogsByUser(String userId) async {
    try {
      final response = await _client
          .from('daily_logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
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

      return response;
    } catch (e) {
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
      final response = await _client
          .from('daily_logs')
          .update({
            'title': title,
            'content': content,
            'updated_at': updatedAt.toIso8601String(),
          })
          .eq('id', id)
          .select();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteLog(int id) async {
    try {
      final response = await _client
          .from('daily_logs')
          .delete()
          .eq('id', id)
          .select();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllLogsByUser(String userId) async {
    try {
      await _client.from('daily_logs').delete().eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
