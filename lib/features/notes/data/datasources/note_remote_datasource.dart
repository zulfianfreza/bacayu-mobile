import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw Dio calls only — no error mapping. Throws [DioException] on failure;
/// the repository is the only layer that catches it.
@injectable
class NoteRemoteDataSource {
  NoteRemoteDataSource(this._dio);

  final Dio _dio;

  /// Backend's `GET /notes` takes offset/limit, not a page number.
  static const pageSize = 50;

  /// GET /notes?user_book_id=&offset=&limit= — envelope's `data` is
  /// `{items, meta}`. Omit [userBookId] for every note the caller has.
  Future<List<dynamic>> listNotes({
    String? userBookId,
    int page = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notes',
      queryParameters: {
        'user_book_id': ?userBookId,
        'offset': (page - 1) * pageSize,
        'limit': pageSize,
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return data['items'] as List<dynamic>;
  }

  /// POST /notes — `content` is required and trimmed server-side.
  Future<Map<String, dynamic>> createNote({
    required String userBookId,
    required String content,
    int? page,
    String? quote,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/notes',
      data: {
        'user_book_id': userBookId,
        'content': content,
        'page': ?page,
        'quote': ?quote,
      },
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// PATCH /notes/:id — omitted fields stay unchanged server-side.
  Future<Map<String, dynamic>> updateNote({
    required String noteId,
    required String content,
    int? page,
    String? quote,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/notes/$noteId',
      data: {
        'content': content,
        'page': ?page,
        'quote': ?quote,
      },
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// DELETE /notes/:id — 204, no body.
  Future<void> deleteNote(String noteId) async {
    await _dio.delete<void>('/notes/$noteId');
  }
}
