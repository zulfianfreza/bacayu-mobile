import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/book_input.dart';

/// Raw Dio calls only — no error mapping. Throws [DioException] on failure;
/// the repository is the only layer that catches it.
@injectable
class BookRemoteDataSource {
  BookRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /books/search?q= — the envelope's `data` is a bare JSON array (not
  /// `{items, meta}`), unlike list endpoints elsewhere in the app.
  Future<List<dynamic>> search(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/books/search',
      queryParameters: {'q': query},
    );
    return response.data!['data'] as List<dynamic>;
  }

  /// GET /books/lookup?isbn=
  Future<Map<String, dynamic>> lookupByIsbn(String isbn) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/books/lookup',
      queryParameters: {'isbn': isbn},
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// POST /books/import — idempotent find-or-create by `google_books_id`.
  Future<Map<String, dynamic>> importFromGoogle(String googleBooksId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/books/import',
      data: {'google_books_id': googleBooksId},
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// GET /books/:id
  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/books/$id');
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// POST /books — manual add for books not found via Google Books.
  Future<Map<String, dynamic>> addManual(BookInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/books',
      data: {
        'title': input.title,
        'authors': input.authors,
        'total_pages': input.totalPages,
        'genres': input.genres,
        'language': input.language,
        'cover_url': input.coverUrl,
        'description': input.description,
        'published_date': input.publishedDate,
      },
    );
    return response.data!['data'] as Map<String, dynamic>;
  }
}
