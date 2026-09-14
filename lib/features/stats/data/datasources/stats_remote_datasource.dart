import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw Dio calls only — no error mapping. Throws [DioException] on failure.
@injectable
class StatsRemoteDataSource {
  StatsRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /stats/summary?range=
  Future<Map<String, dynamic>> getSummary(String range) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/stats/summary',
      queryParameters: {'range': range},
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// GET /stats/heatmap?year= — envelope's `data` is a bare JSON array.
  Future<List<dynamic>> getHeatmap(int year) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/stats/heatmap',
      queryParameters: {'year': year},
    );
    return response.data!['data'] as List<dynamic>;
  }
}
