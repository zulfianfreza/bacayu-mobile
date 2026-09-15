import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../notifications/data/services/push_notification_service.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._login,
    this._register,
    this._getCurrentUser,
    this._logout,
    this._pushNotificationService,
  ) : super(const AuthInitial());

  final Login _login;
  final Register _register;
  final GetCurrentUser _getCurrentUser;
  final Logout _logout;
  final PushNotificationService _pushNotificationService;

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    final result = await _login(email: email, password: password);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) {
        emit(AuthAuthenticated(user));
        unawaited(_pushNotificationService.registerAfterLogin());
      },
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(const AuthLoading());
    final result = await _register(email: email, password: password, name: name);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) {
        emit(AuthAuthenticated(user));
        unawaited(_pushNotificationService.registerAfterLogin());
      },
    );
  }

  Future<void> checkCurrentUser() async {
    emit(const AuthLoading());
    final result = await _getCurrentUser();
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    await _logout();
    emit(const AuthUnauthenticated());
  }
}
