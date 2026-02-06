import 'package:my_daily_log/core/auth/auth0_service.dart';
import 'package:my_daily_log/core/auth/auth_repository.dart';
import 'package:my_daily_log/domain/entities/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Auth0Service _auth0Service;

  const AuthRepositoryImpl(this._auth0Service);

  @override
  Future<User?> login({bool forceLogin = false}) async {
    return await _auth0Service.login(forceLogin: forceLogin);
  }

  @override
  Future<void> logout() async {
    await _auth0Service.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _auth0Service.getCurrentUser();
  }

  @override
  Future<String?> getAccessToken() async {
    return await _auth0Service.getAccessToken();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _auth0Service.hasValidCredentials();
  }
}
