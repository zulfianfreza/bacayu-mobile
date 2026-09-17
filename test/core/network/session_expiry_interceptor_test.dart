import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/network/session_expired_handler.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionExpiredHandler extends Mock implements SessionExpiredHandler {}

/// A real `Dio` pipeline awaits `ErrorInterceptorHandler.next()`'s internal
/// completer to chain to the next interceptor; nothing does that here since
/// these tests call `SessionExpiryInterceptor.onError` directly, isolated
/// from a real Dio instance. Left alone, that completer's `completeError`
/// surfaces as an unhandled async error and fails the test even though
/// production code always consumes it — `runZonedGuarded` scopes that
/// (expected, harmless) noise to just this call.
void _sendError(SessionExpiryInterceptor interceptor, DioException err) {
  runZonedGuarded(
    () => interceptor.onError(err, ErrorInterceptorHandler()),
    (error, stackTrace) {},
  );
}

DioException _error401() {
  final options = RequestOptions(path: '/users/me');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: options,
      statusCode: 401,
      data: {
        'success': false,
        'message': 'invalid or expired token',
        'data': {'code': 'UNAUTHORIZED'},
      },
    ),
  );
}

DioException _error500() {
  final options = RequestOptions(path: '/users/me');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: 500),
  );
}

Response<dynamic> _okResponse() {
  final options = RequestOptions(path: '/users/me');
  return Response(requestOptions: options, statusCode: 200);
}

void main() {
  late _MockSessionExpiredHandler handler;
  late SessionExpiryInterceptor interceptor;

  setUp(() {
    handler = _MockSessionExpiredHandler();
    interceptor = SessionExpiryInterceptor(() => handler);
  });

  test('a single 401 calls onSessionExpired once', () {
    _sendError(interceptor, _error401());

    verify(() => handler.onSessionExpired()).called(1);
  });

  test(
      'several requests 401-ing in the same burst call onSessionExpired '
      'exactly once, not once per failed request', () {
    // Simulates N in-flight requests that all had the same dying token —
    // their onError calls land close together, before anything resets the
    // guard.
    _sendError(interceptor, _error401());
    _sendError(interceptor, _error401());
    _sendError(interceptor, _error401());
    _sendError(interceptor, _error401());

    verify(() => handler.onSessionExpired()).called(1);
  });

  test('a non-401 error never calls onSessionExpired', () {
    _sendError(interceptor, _error500());

    verifyNever(() => handler.onSessionExpired());
  });

  test(
      'a successful response resets the guard, so a LATER 401 (a new '
      'session dying) is handled again', () {
    _sendError(interceptor, _error401());
    interceptor.onResponse(_okResponse(), ResponseInterceptorHandler());
    _sendError(interceptor, _error401());

    verify(() => handler.onSessionExpired()).called(2);
  });
}
