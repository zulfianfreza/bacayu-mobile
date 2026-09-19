import '../../../books/data/models/book_model.dart';
import '../../../books/domain/entities/book.dart';
import '../../domain/entities/user_book.dart';

extension ShelfStatusWire on ShelfStatus {
  static ShelfStatus fromWire(String value) => switch (value) {
        'want_to_read' => ShelfStatus.wantToRead,
        'reading' => ShelfStatus.reading,
        'finished' => ShelfStatus.finished,
        'dnf' => ShelfStatus.dnf,
        _ => throw ArgumentError('Unknown shelf status from backend: $value'),
      };

  String get wireValue => switch (this) {
        ShelfStatus.wantToRead => 'want_to_read',
        ShelfStatus.reading => 'reading',
        ShelfStatus.finished => 'finished',
        ShelfStatus.dnf => 'dnf',
      };
}

extension BookFormatWire on BookFormat {
  static BookFormat fromWire(String value) => switch (value) {
        'physical' => BookFormat.physical,
        'ebook' => BookFormat.ebook,
        'audiobook' => BookFormat.audiobook,
        _ => throw ArgumentError('Unknown book format from backend: $value'),
      };

  String get wireValue => switch (this) {
        BookFormat.physical => 'physical',
        BookFormat.ebook => 'ebook',
        BookFormat.audiobook => 'audiobook',
      };
}

/// Mirrors `ShelfItemResponse` in
/// `api/internal/features/shelf/delivery/http/response.go`: the entry's own
/// fields, with the book embedded as a *summary* (id, title, authors, cover,
/// page count) rather than only a `book_id`.
///
/// The write responses (`POST`/`PATCH /shelf`) stay flat — no embedded book —
/// so [UserBookModel.fromJson] still takes one; [UserBookModel.fromShelfItemJson]
/// is the list's, and needs nothing fetched.
class UserBookModel extends UserBook {
  const UserBookModel({
    required super.id,
    required super.book,
    required super.status,
    required super.format,
    required super.currentPage,
    required super.startedAt,
    required super.finishedAt,
    required super.rating,
    required super.isReread,
  });

  static String bookIdOf(Map<String, dynamic> json) => json['book_id'] as String;

  /// One `GET /shelf` item, whose book the backend already sent.
  factory UserBookModel.fromShelfItemJson(Map<String, dynamic> json) {
    return UserBookModel._fromJson(
      json,
      BookModel.fromSummaryJson(json['book'] as Map<String, dynamic>),
    );
  }

  /// A write response, composed with a book the caller had to resolve.
  factory UserBookModel.fromJson(
    Map<String, dynamic> json, {
    required Book book,
  }) {
    return UserBookModel._fromJson(json, book);
  }

  factory UserBookModel._fromJson(Map<String, dynamic> json, Book book) {
    return UserBookModel(
      id: json['id'] as String,
      book: book,
      status: ShelfStatusWire.fromWire(json['status'] as String),
      format: json['format'] == null
          ? null
          : BookFormatWire.fromWire(json['format'] as String),
      currentPage: json['current_page'] as int? ?? 0,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      finishedAt: json['finished_at'] == null
          ? null
          : DateTime.parse(json['finished_at'] as String),
      rating: json['rating'] as int?,
      isReread: json['is_reread'] as bool? ?? false,
    );
  }
}
