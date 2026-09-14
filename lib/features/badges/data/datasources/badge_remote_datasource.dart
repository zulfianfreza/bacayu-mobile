import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw Dio calls only — no error mapping. Throws [DioException] on failure.
@injectable
class BadgeRemoteDataSource {
  BadgeRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /badges — envelope's `data` is a bare JSON array.
  Future<List<dynamic>> getAllBadges() async {
    final response = await _dio.get<Map<String, dynamic>>('/badges');
    return response.data!['data'] as List<dynamic>;
  }
}
