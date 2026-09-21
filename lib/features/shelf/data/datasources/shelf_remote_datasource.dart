import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw Dio calls only — no error mapping, no book resolution. Throws
/// [DioException] on failure; the repository is the only layer that
/// catches it.
@injectable
class ShelfRemoteDataSource {
  ShelfRemoteDataSource(this._dio);

  final Dio _dio;

  /// POST /shelf — `status` omitted lets the backend apply its own default
  /// ("want_to_read").
  Future<Map<String, dynamic>> addToShelf({
    required String bookId,
    String? status,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/shelf',
      data: {'book_id': bookId, 'status': ?status},
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// GET /shelf?status=&page= — envelope's `data` is `{items, meta}`.
  Future<List<dynamic>> listShelf({String? status, int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/shelf',
      queryParameters: {'status': ?status, 'page': page},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return data['items'] as List<dynamic>;
  }

  /// PATCH /shelf/:id — fields left null are left unchanged server-side.
  Future<Map<String, dynamic>> updateShelfStatus({
    required String userBookId,
    String? status,
    int? currentPage,
    int? rating,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/shelf/$userBookId',
      data: {
        'status': ?status,
        'current_page': ?currentPage,
        'rating': ?rating,
      },
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// GET /shelf/books/:bookId/reads — envelope's `data` is the list itself,
  /// oldest read first.
  Future<List<dynamic>> getBookReads(String bookId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/shelf/books/$bookId/reads',
    );
    return response.data!['data'] as List<dynamic>;
  }

  /// POST /shelf/books/:bookId/reread — creates the new read and returns its
  /// flat `UserBookResponse` (no embedded book).
  Future<Map<String, dynamic>> startReread(String bookId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/shelf/books/$bookId/reread',
    );
    return response.data!['data'] as Map<String, dynamic>;
  }
}
