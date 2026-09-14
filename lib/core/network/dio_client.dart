import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../error/failure.dart';
import '../storage/secure_token_storage.dart';

/// Creates the single [Dio] instance the whole app shares. Base URL comes
/// from `--dart-define=API_BASE_URL=...`, never hardcoded.
@module
abstract class DioClientModule {
  @lazySingleton
  Dio dio(SecureTokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8080/api/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(tokenStorage),
      RequestLoggingInterceptor(),
    ]);

    return dio;
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
