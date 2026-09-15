import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw Dio calls only — no error mapping. Throws [DioException] on failure.
@injectable
class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._dio);

  final Dio _dio;

  /// POST /notifications/register-device — authenticated endpoint, must
  /// only be called once a session exists.
  Future<void> registerDevice({
    required String token,
    required String platform,
  }) {
    return _dio.post<void>(
      '/notifications/register-device',
      data: {'token': token, 'platform': platform},
    );
  }
}
