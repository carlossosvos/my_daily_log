import 'package:my_daily_log/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> login({bool forceLogin = false});
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<String?> getAccessToken();
  Future<bool> isAuthenticated();
}
