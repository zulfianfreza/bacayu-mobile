import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/session_expired_handler.dart';
import '../../../notifications/data/services/push_notification_service.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import 'auth_state.dart';

/// A singleton (not a per-page factory, contrast with most other Cubits in
/// this app): `app_router.dart`'s redirect listens to [stream] and
/// `dio_client.dart`'s 401 interceptor calls [onSessionExpired] on it, and
/// both need to reach the SAME instance login/register pages read/write —
/// a fresh instance per page would leave the router listening to nobody's
/// state changes. Pages that use it MUST obtain it via
/// `BlocProvider.value(value: getIt<AuthCubit>())`, never
/// `BlocProvider(create: ...)` — the latter closes the Cubit (and its
/// stream, permanently) when that page is popped.
@lazySingleton
class AuthCubit extends Cubit<AuthState> implements SessionExpiredHandler {
  AuthCubit(
    this._login,
    this._loginWithGoogle,
    this._register,
    this._getCurrentUser,
    this._logout,
    this._pushNotificationService,
  ) : super(const AuthInitial());

  final Login _login;
  final LoginWithGoogle _loginWithGoogle;
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

  /// Same redirect logic as [login] — Google Sign-In doubles as
  /// register-or-login (backend find-or-create), so there's no separate
  /// "register with Google" path. A `null` result means the user cancelled
  /// the native sign-in sheet: not an error, just go back to idle.
  Future<void> loginWithGoogle() async {
    emit(const AuthLoading());
    final result = await _loginWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) {
        if (user == null) {
          emit(const AuthInitial());
          return;
        }
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

  /// Triggered by [onSessionExpired] (a 401 from anywhere in the app) —
  /// idempotent: a no-op once already `AuthUnauthenticated`, so a burst of
  /// parallel 401s that each call this only clears the token/emits once.
  /// Reuses [Logout] rather than touching secure storage directly — same
  /// domain path as a manual logout, Cubit still never talks to storage.
  Future<void> forceLogout() async {
    if (state is AuthUnauthenticated) return;
    await _logout();
    emit(const AuthUnauthenticated(reason: UnauthenticatedReason.sessionExpired));
  }

  @override
  void onSessionExpired() => unawaited(forceLogout());
}

/// Binds [AuthCubit] to the [SessionExpiredHandler] interface `core/network`
/// depends on — a separate `@module` (rather than `@LazySingleton(as: ...)`
/// on the class itself) so `AuthCubit` stays registered under its own
/// concrete type too (every other call site resolves it as `AuthCubit`,
/// not `SessionExpiredHandler`).
@module
abstract class SessionExpiredHandlerModule {
  @lazySingleton
  SessionExpiredHandler sessionExpiredHandler(AuthCubit authCubit) => authCubit;
}
