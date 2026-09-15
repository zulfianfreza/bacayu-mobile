import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw Dio calls only — no error mapping. Throws [DioException] on failure.
@injectable
class SocialRemoteDataSource {
  SocialRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> followUser(String userId) {
    return _dio.post<void>('/social/follow/$userId');
  }

  Future<void> unfollowUser(String userId) {
    return _dio.delete<void>('/social/follow/$userId');
  }

  /// GET /social/followers — envelope's `data` is `{items, meta}`.
  Future<List<dynamic>> listFollowers() async {
    final response = await _dio.get<Map<String, dynamic>>('/social/followers');
    final data = response.data!['data'] as Map<String, dynamic>;
    return data['items'] as List<dynamic>;
  }

  /// GET /social/following — envelope's `data` is `{items, meta}`.
  Future<List<dynamic>> listFollowing() async {
    final response = await _dio.get<Map<String, dynamic>>('/social/following');
    final data = response.data!['data'] as Map<String, dynamic>;
    return data['items'] as List<dynamic>;
  }

  Future<void> likeActivity(String activityId) {
    return _dio.post<void>('/feed/$activityId/like');
  }

  Future<void> unlikeActivity(String activityId) {
    return _dio.delete<void>('/feed/$activityId/like');
  }

  Future<Map<String, dynamic>> addComment({
    required String activityId,
    required String body,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/feed/$activityId/comments',
      data: {'body': body},
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// GET /feed/:activityId/comments — envelope's `data` is `{items, meta}`.
  Future<List<dynamic>> listComments(String activityId) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/feed/$activityId/comments');
    final data = response.data!['data'] as Map<String, dynamic>;
    return data['items'] as List<dynamic>;
  }

  /// GET /social/leaderboard?range= — envelope's `data` is a bare
  /// `{entries, current_user}` object (not list-paginated).
  Future<Map<String, dynamic>> getLeaderboard(String range) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/social/leaderboard',
      queryParameters: {'range': range},
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  Future<void> updateActivityVisibility({
    required String activityId,
    required String visibility,
  }) {
    return _dio.patch<void>(
      '/feed/$activityId/visibility',
      data: {'visibility': visibility},
    );
  }
}
