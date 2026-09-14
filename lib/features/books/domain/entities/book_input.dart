import 'package:equatable/equatable.dart';

/// Payload for `AddManualBook` — mirrors `AddManualBookRequest` in
/// `api/internal/features/books/delivery/http/request.go`.
class BookInput extends Equatable {
  const BookInput({
    required this.title,
    required this.authors,
    required this.totalPages,
    required this.genres,
    required this.language,
    required this.coverUrl,
    required this.description,
    required this.publishedDate,
  });

  final String title;
  final List<String> authors;
  final int? totalPages;
  final List<String> genres;
  final String language;
  final String? coverUrl;
  final String? description;
  final String publishedDate;

  @override
  List<Object?> get props => [
        title,
        authors,
        totalPages,
        genres,
        language,
        coverUrl,
        description,
        publishedDate,
      ];
}
