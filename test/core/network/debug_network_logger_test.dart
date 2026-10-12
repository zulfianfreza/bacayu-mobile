import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/debug_network_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() {
  test(
    'logs sanitized request/response snapshots without changing payloads',
    () async {
      final talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      final logger = DebugNetworkLogger(talker);
      final payload = {'password': 'secret-password', 'title': 'Book'};
      final responseBody = {
        'data': {'access_token': 'secret-token', 'name': 'Reader'},
        'request_id': 'request-123',
      };
      dio.interceptors.addAll([
        logger,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.data, payload);
            expect(options.headers['Authorization'], 'Bearer private');
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: responseBody,
                headers: Headers.fromMap({
                  'set-cookie': ['session=private'],
                }),
              ),
            );
          },
        ),
      ]);
      final response = await dio.post<dynamic>(
        '/login?token=private-query',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer private'}),
      );
      // Resolve bypasses response interceptors by default.
      logger.onResponse(response, ResponseInterceptorHandler());
      final logs = talker.history
          .map((log) => log.generateTextMessage())
          .join('\n');
      expect(logs, contains('Book'));
      expect(logs, contains('Reader'));
      expect(logs, contains('request-123'));
      expect(logs, contains('Status: 200'));
      expect(logs, contains('Time:'));
      expect(logs, contains('[REDACTED]'));
      for (final secret in [
        'secret-password',
        'secret-token',
        'private-query',
        'Bearer private',
        'session=private',
      ]) {
        expect(logs, isNot(contains(secret)));
      }
      expect(payload['password'], 'secret-password');
      expect(
        responseBody['data'],
        containsPair('access_token', 'secret-token'),
      );
      dio.close();
    },
  );

  test('sanitizes error response bodies and headers', () {
    final talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
    final request = RequestOptions(path: 'https://example.com/books');
    final error = DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      message: 'opaque-secret',
      response: Response(
        requestOptions: request,
        statusCode: 422,
        data: {'password': 'private', 'message': 'Invalid input'},
      ),
    );
    DebugNetworkLogger(talker).onError(error, _ErrorHandler());
    final text = talker.history.single.generateTextMessage();
    expect(text, contains('Status: 422'));
    expect(text, contains('Invalid input'));
    expect(text, isNot(contains('private')));
    expect(text, isNot(contains('opaque-secret')));
  });
}

class _ErrorHandler extends ErrorInterceptorHandler {
  @override
  void next(DioException error) {}
}
