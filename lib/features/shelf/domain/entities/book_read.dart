import 'package:equatable/equatable.dart';

import 'user_book.dart';

/// One entry in a book's read history (`GET /shelf/books/:bookId/reads`): the
/// original read plus each reread, oldest first.
///
/// Deliberately not a [UserBook]: this response has no book (it is fixed by the
/// URL) and no `book_id`/`user_id` either, so it carries only what a history row
/// renders.
class BookRead extends Equatable {
  const BookRead({
    required this.id,
    required this.status,
    required this.currentPage,
    required this.rating,
    required this.isReread,
    required this.startedAt,
    required this.finishedAt,
    required this.createdAt,
  });

  final String id;
  final ShelfStatus status;
  final int currentPage;
  final int? rating;

  /// `true` for every read after the first — the backend inserts a new row per
  /// read rather than reopening the finished one.
  final bool isReread;

  final DateTime? startedAt;
  final DateTime? finishedAt;

  /// Set even when the reader never tapped start (a reread row is created
  /// directly), so it is the row's "when" fallback for the history list.
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    status,
    currentPage,
    rating,
    isReread,
    startedAt,
    finishedAt,
    createdAt,
  ];
}
