import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

/// Distinguishes a user-initiated logout from an auto-logout triggered by a
/// 401 (see `SessionExpiredHandler`/`AuthCubit.forceLogout`) — `LoginPage`
/// uses this to show a "session expired" message only for the latter.
enum UnauthenticatedReason { manualLogout, sessionExpired }

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({
    this.reason = UnauthenticatedReason.manualLogout,
  });

  final UnauthenticatedReason reason;

  @override
  List<Object?> get props => [reason];
}

class AuthError extends AuthState {
  const AuthError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
