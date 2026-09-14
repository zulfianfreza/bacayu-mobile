import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw Dio calls only — no error mapping, no local persistence. Throws
/// [DioException] on failure.
@injectable
class SessionRemoteDataSource {
  SessionRemoteDataSource(this._dio);

  final Dio _dio;

  /// POST /sessions — `payload` is a `ReadingSessionModel.toJson()`. Returns
  /// the full envelope `data` (session fields + `badges_unlocked`).
  Future<Map<String, dynamic>> submit(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/sessions',
      data: payload,
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// GET /sessions?page=
  Future<List<dynamic>> getHistory({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/sessions',
      queryParameters: {'page': page},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return data['items'] as List<dynamic>;
  }
}
