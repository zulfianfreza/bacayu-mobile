import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw Dio calls only — no error mapping. Throws [DioException] on failure.
@injectable
class FeedRemoteDataSource {
  FeedRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /feed?cursor= — envelope's `data` is `{items, meta}`.
  Future<List<dynamic>> getFeed({String? cursor}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/feed',
      queryParameters: {'cursor': ?cursor},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return data['items'] as List<dynamic>;
  }
}
