import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:my_daily_log/core/config/app_config.dart';
import 'package:my_daily_log/domain/entities/user.dart';

class Auth0Service {
  late final Auth0 _auth0;

  Auth0Service() {
    if (AppConfig.auth0Domain.isEmpty || AppConfig.auth0ClientId.isEmpty) {
      throw Exception(
        'Auth0 configuration is missing. Check your environment variables.',
      );
    }

    _auth0 = Auth0(AppConfig.auth0Domain, AppConfig.auth0ClientId);
  }

  // Simple test method to verify setup
  Future<bool> testConnection() async {
    try {
      // Just check if we can create the Auth0 instance
      return _auth0.toString().isNotEmpty;
    } catch (e) {
      debugPrint('Auth0 setup error: $e');
      return false;
    }
  }

  Future<User?> login({Map<String, String>? parameters}) async {
    try {
      final credentials = await _auth0
          .webAuthentication(scheme: 'com.cgcvdev.dailylog')
          .login(parameters: parameters ?? const {});
      if (credentials.user.sub.isNotEmpty) {
        return _mapToUser(credentials.user);
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        debugPrint('Auth0 login error: $e');
      }
      rethrow;
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _auth0.webAuthentication().logout();
    } catch (e) {
      if (AppConfig.enableLogging) {
        debugPrint('Auth0 logout error: $e');
      }
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final credentials = await _auth0.credentialsManager.credentials();
      if (credentials.user.sub.isNotEmpty) {
        return _mapToUser(credentials.user);
      }
    } catch (e) {
      // User not logged in or credentials expired
      return null;
    }
    return null;
  }

  Future<String?> getAccessToken() async {
    try {
      final credentials = await _auth0.credentialsManager.credentials();
      return credentials.accessToken;
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasValidCredentials() async {
    try {
      return await _auth0.credentialsManager.hasValidCredentials();
    } catch (e) {
      return false;
    }
  }

  User _mapToUser(UserProfile userProfile) {
    return User(
      id: userProfile.sub,
      email: userProfile.email ?? '',
      name: userProfile.name,
      pictureUrl: userProfile.pictureUrl?.toString(),
      isEmailVerified: userProfile.isEmailVerified ?? false,
    );
  }
}
