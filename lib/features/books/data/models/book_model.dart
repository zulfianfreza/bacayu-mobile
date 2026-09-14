import '../../domain/entities/book.dart';

/// Mirrors `BookResponse` in `api/internal/features/books/delivery/http/response.go`
/// field-for-field. `id` is `""` for a not-yet-imported search result.
class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.source,
    required super.googleBooksId,
    required super.isbn10,
    required super.isbn13,
    required super.title,
    required super.authors,
    required super.description,
    required super.coverUrl,
    required super.totalPages,
    required super.language,
    required super.genres,
    required super.publishedDate,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String? ?? '',
      source: json['source'] as String,
      googleBooksId: json['google_books_id'] as String?,
      isbn10: json['isbn_10'] as String?,
      isbn13: json['isbn_13'] as String?,
      title: json['title'] as String,
      authors: (json['authors'] as List<dynamic>? ?? []).cast<String>(),
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      totalPages: json['total_pages'] as int?,
      language: json['language'] as String? ?? '',
      genres: (json['genres'] as List<dynamic>? ?? []).cast<String>(),
      publishedDate: json['published_date'] as String? ?? '',
    );
  }
}
