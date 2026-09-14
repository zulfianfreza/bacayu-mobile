import 'package:equatable/equatable.dart';

import '../../../books/domain/entities/book.dart';

enum ShelfStatus { wantToRead, reading, finished, dnf }

enum BookFormat { physical, ebook, audiobook }

class UserBook extends Equatable {
  const UserBook({
    required this.id,
    required this.book,
    required this.status,
    required this.format,
    required this.currentPage,
    required this.startedAt,
    required this.finishedAt,
    required this.rating,
    required this.isReread,
  });

  final String id;

  /// Resolved separately via `books`' `GetBookDetail` — the shelf API only
  /// returns `book_id`, never a joined book object.
  final Book book;

  final ShelfStatus status;
  final BookFormat? format;
  final int currentPage;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? rating;
  final bool isReread;

  @override
  List<Object?> get props => [
        id,
        book,
        status,
        format,
        currentPage,
        startedAt,
        finishedAt,
        rating,
        isReread,
      ];
}
