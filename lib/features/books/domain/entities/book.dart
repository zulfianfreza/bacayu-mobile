import 'package:equatable/equatable.dart';

class Book extends Equatable {
  const Book({
    required this.id,
    required this.source,
    required this.googleBooksId,
    required this.isbn10,
    required this.isbn13,
    required this.title,
    required this.authors,
    required this.description,
    required this.coverUrl,
    required this.totalPages,
    required this.language,
    required this.genres,
    required this.publishedDate,
  });

  /// Empty for a search result that hasn't been imported yet — a real
  /// internal id only exists after `ImportBookFromGoogle`/`LookupBookByIsbn`.
  final String id;
  final String source;
  final String? googleBooksId;
  final String? isbn10;
  final String? isbn13;
  final String title;
  final List<String> authors;
  final String? description;
  final String? coverUrl;
  final int? totalPages;
  final String language;
  final List<String> genres;
  final String publishedDate;

  bool get hasInternalId => id.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        source,
        googleBooksId,
        isbn10,
        isbn13,
        title,
        authors,
        description,
        coverUrl,
        totalPages,
        language,
        genres,
        publishedDate,
      ];
}
