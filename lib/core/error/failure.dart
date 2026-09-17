import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class ServerFailure extends Failure {
  const ServerFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}

class CacheFailure extends Failure {
  const CacheFailure();
}

/// A request came back 401 (token invalid/expired) — distinct from a
/// generic [ServerFailure] so callers can tell "the session died" apart
/// from an ordinary server error. `dio_client.dart`'s interceptor is the
/// only place that produces this; it also triggers the global auto-logout
/// (see `SessionExpiredHandler`) at the same time, so by the time this
/// reaches a caller, the app is already on its way to the login screen —
/// UI code should generally not show its own error for this (see
/// `core/widgets/error_listener.dart`).
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure();
}

class ValidationFailure extends Failure {
  const ValidationFailure({required this.details});

  final Map<String, String> details;

  @override
  List<Object?> get props => [details];
}
