import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw Dio calls only — no error mapping. Throws [DioException] on failure.
@injectable
class FeedRemoteDataSource {
  FeedRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /feed?cursor= — the requester's own activities.
  Future<({List<dynamic> items, String? nextCursor})> getFeed({
    String? cursor,
  }) {
    return _list('/feed', cursor: cursor);
  }

  /// GET /feed/social?cursor= — activities from the people they follow.
  Future<({List<dynamic> items, String? nextCursor})> getSocialFeed({
    String? cursor,
  }) {
    return _list('/feed/social', cursor: cursor);
  }

  /// GET /feed/:activityId — one activity with its type-specific detail.
  Future<Map<String, dynamic>> getActivityDetail(String activityId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/feed/$activityId',
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// Both feeds share one envelope: `data` is `{items, meta}`, and `meta`
  /// carries the explicit `next_cursor` (`null` on the last page).
  Future<({List<dynamic> items, String? nextCursor})> _list(
    String path, {
    String? cursor,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {'cursor': ?cursor},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    final meta = data['meta'] as Map<String, dynamic>;
    return (
      items: data['items'] as List<dynamic>,
      nextCursor: meta['next_cursor'] as String?,
    );
  }
}
