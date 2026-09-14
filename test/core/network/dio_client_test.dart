import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/network/dio_client.dart';

DioException _networkError() {
  return DioException(
    requestOptions: RequestOptions(path: '/sessions'),
    type: DioExceptionType.connectionError,
  );
}

DioException _errorResponse({
  required int statusCode,
  required String message,
  required Map<String, dynamic> data,
}) {
  final options = RequestOptions(path: '/sessions');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: options,
      statusCode: statusCode,
      data: {
        'success': false,
        'status_code': statusCode,
        'timestamp': '2026-01-01T00:00:00Z',
        'request_id': 'req-1',
        'message': message,
        'data': data,
      },
    ),
  );
}

void main() {
  group('mapDioExceptionToFailure / dioExceptionToEither', () {
    test('connection error (no response) maps to NetworkFailure', () {
      final either = dioExceptionToEither<String>(_networkError());

      expect(either, const Left<Failure, String>(NetworkFailure()));
    });

    test('401 maps to ServerFailure with backend code/message', () {
      final exception = _errorResponse(
        statusCode: 401,
        message: 'invalid email or password',
        data: {'code': 'INVALID_CREDENTIALS', 'details': null},
      );

      final either = dioExceptionToEither<String>(exception);

      expect(
        either,
        const Left<Failure, String>(
          ServerFailure(
            code: 'INVALID_CREDENTIALS',
            message: 'invalid email or password',
          ),
        ),
      );
    });

    test('404 maps to ServerFailure with backend code/message', () {
      final exception = _errorResponse(
        statusCode: 404,
        message: 'session not found',
        data: {'code': 'SESSION_NOT_FOUND', 'details': null},
      );

      final either = dioExceptionToEither<String>(exception);

      expect(
        either,
        const Left<Failure, String>(
          ServerFailure(code: 'SESSION_NOT_FOUND', message: 'session not found'),
        ),
      );
    });

    test('422 maps to ValidationFailure with field details', () {
      final exception = _errorResponse(
        statusCode: 422,
        message: 'validation failed',
        data: {
          'code': 'VALIDATION_ERROR',
          'details': {'end_page': 'must be greater than start_page'},
        },
      );

      final either = dioExceptionToEither<String>(exception);

      expect(
        either,
        const Left<Failure, String>(
          ValidationFailure(
            details: {'end_page': 'must be greater than start_page'},
          ),
        ),
      );
    });

    test('result is always Left — never throws past the mapper', () {
      expect(
        () => dioExceptionToEither<String>(_networkError()),
        returnsNormally,
      );
    });
  });
}
