import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../di/injection.dart';
import '../error/failure.dart';
import '../storage/secure_token_storage.dart';
import 'session_expired_handler.dart';

/// Creates the single [Dio] instance the whole app shares. Base URL comes
/// from `--dart-define=API_BASE_URL=...`, never hardcoded.
@module
abstract class DioClientModule {
  @lazySingleton
  Dio dio(SecureTokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment('API_BASE_URL'),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(tokenStorage),
      // `SessionExpiredHandler` resolves to `AuthCubit`, which (through its
      // usecases) depends back on this very `Dio` instance — resolving it
      // here eagerly (as a constructor param) would recurse infinitely.
      // Deferring the `getIt` lookup into the closure, invoked only once an
      // actual 401 happens (long after Dio is fully built and cached),
      // breaks that cycle. This is also the only reason `core/network`
      // reaches for `getIt` instead of a plain constructor dependency —
      // still zero direct imports from `features/auth`.
      SessionExpiryInterceptor(() => getIt<SessionExpiredHandler>()),
      RequestLoggingInterceptor(),
    ]);

    return dio;
  }
}

/// Detects a 401 (invalid/expired token) exactly once per session and
/// triggers [SessionExpiredHandler.onSessionExpired] — never navigates
/// itself (that's go_router's `refreshListenable` + redirect job, driven by
/// `AuthCubit`'s state; see `app_router.dart`).
class SessionExpiryInterceptor extends Interceptor {
  SessionExpiryInterceptor(this._handlerProvider);

  final SessionExpiredHandler Function() _handlerProvider;

  /// Several requests can 401 in the same burst (all in flight when the
  /// token died) — this guards [SessionExpiredHandler.onSessionExpired]
  /// from firing once per failed request instead of once for the whole
  /// burst. Reset on the next successful response, so a later session's
  /// own 401 (after a fresh login) is handled again, not silently ignored.
  bool _handlingSessionExpiry = false;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _handlingSessionExpiry = false;
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && !_handlingSessionExpiry) {
      _handlingSessionExpiry = true;
      _handlerProvider().onSessionExpired();
    }
    handler.next(err);
  }
}

/// Attaches the auth token from secure storage to every outgoing request.
/// Single place this happens — datasources never touch the token directly.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final SecureTokenStorage _tokenStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Logs request/response pairs including `request_id`, so a failure here
/// can be correlated to the matching backend log line.
class RequestLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log('--> ${options.method} ${options.uri}', name: 'DioClient');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final requestId = _requestIdOf(response);
    developer.log(
      '<-- ${response.statusCode} ${response.requestOptions.uri} '
      '(request_id: $requestId)',
      name: 'DioClient',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = _requestIdOf(err.response);
    developer.log(
      '<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri} '
      '(request_id: $requestId): ${err.message}',
      name: 'DioClient',
      error: err,
    );
    handler.next(err);
  }

  String _requestIdOf(Response<dynamic>? response) {
    final header = response?.headers.value('x-request-id');
    if (header != null) return header;
    final body = response?.data;
    if (body is Map && body['request_id'] is String) {
      return body['request_id'] as String;
    }
    return 'unknown';
  }
}

/// Maps a [DioException] (network failure, or a non-2xx response following
/// the backend's error envelope `{success:false, message, data:{code,
/// details}}`) to a [Failure]. This is the ONLY place this mapping happens —
/// every datasource in the app funnels its `on DioException catch (e)` here.
Failure mapDioExceptionToFailure(DioException exception) {
  final response = exception.response;

  if (response == null) {
    // connectionTimeout / sendTimeout / receiveTimeout / connectionError /
    // unknown (no socket, DNS failure, etc.) — never reached the server.
    return const NetworkFailure();
  }

  final body = response.data;
  final envelope = body is Map<String, dynamic> ? body : null;
  final message =
      envelope?['message'] as String? ??
      exception.message ??
      'unexpected error';
  final data = envelope?['data'];
  final code = data is Map ? data['code'] as String? : null;

  if (response.statusCode == 401) {
    // `INVALID_CREDENTIALS` is a *login attempt* rejecting a wrong
    // password — no session ever existed to expire, and treating it as one
    // would show a confusing "session expired" message on the login form
    // itself instead of "invalid email or password". Every other 401 is an
    // already-authenticated request whose token died — that's the real
    // auto-logout case.
    if (code != 'INVALID_CREDENTIALS') {
      return const SessionExpiredFailure();
    }
  }

  if (response.statusCode == 422) {
    final details = <String, String>{};
    final rawDetails = data is Map ? data['details'] : null;
    if (rawDetails is Map) {
      rawDetails.forEach((key, value) {
        details[key.toString()] = value.toString();
      });
    }
    return ValidationFailure(details: details);
  }

  return ServerFailure(code: code ?? 'UNKNOWN_ERROR', message: message);
}

/// Convenience wrapper for datasources: catch [DioException], return this
/// directly as the `Left` side of `Either<Failure, T>`.
Either<Failure, T> dioExceptionToEither<T>(DioException exception) =>
    Left(mapDioExceptionToFailure(exception));
