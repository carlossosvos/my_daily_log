import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_daily_log/core/auth/auth_repository.dart';
import 'package:my_daily_log/domain/repositories/daily_log_repository.dart';
import 'package:my_daily_log/presentation/bloc/auth/auth_event.dart';
import 'package:my_daily_log/presentation/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final DailyLogRepository _dailyLogRepository;

  AuthBloc(this._authRepository, this._dailyLogRepository)
    : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          // Force logout if email not verified
          if (!user.isEmailVerified) {
            await _authRepository.logout();
            emit(
              const AuthError('Please verify your email before signing in.'),
            );
            return;
          }

          // Sync remote data on app startup if already authenticated
          try {
            await _dailyLogRepository.syncRemoteData(user.id);
          } catch (e) {
            debugPrint('Warning: Failed to sync remote data: $e');
          }

          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login();
      if (user != null) {
        // Force logout if email not verified
        if (!user.isEmailVerified) {
          await _authRepository.logout();
          emit(const AuthError('Please verify your email before signing in.'));
          return;
        }

        // Sync remote data after successful login
        try {
          await _dailyLogRepository.syncRemoteData(user.id);
        } catch (e) {
          debugPrint('Warning: Failed to sync remote data: $e');
        }

        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        try {
          await _dailyLogRepository.deleteAllLogsByUser(user.id);
        } catch (e) {
          debugPrint('Warning: Failed to clean up user data: $e');
        }
      }

      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
