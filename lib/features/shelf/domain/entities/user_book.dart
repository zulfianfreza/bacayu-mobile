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
    required this.readCount,
  });

  final String id;

  /// The book on this shelf entry.
  ///
  /// A shelf read embeds a *summary* of it — id, title, authors, cover and page
  /// count (backend's `BookSummaryResponse`); the rest of [Book] is empty
  /// because the backend never sent it. Fetch `GET /books/:id` for the full
  /// record.
  final Book book;

  final ShelfStatus status;
  final BookFormat? format;
  final int currentPage;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? rating;
  final bool isReread;

  /// How many reads (original + rereads) this book has. Backend collapses a
  /// book's rows into one representative card and sends the total here, so a
  /// card can show "read 2×". Only unique to the shelf list; the write
  /// responses (`POST`/`PATCH /shelf`) omit it and default to 1.
  final int readCount;

  UserBook copyWith({int? readCount}) => UserBook(
    id: id,
    book: book,
    status: status,
    format: format,
    currentPage: currentPage,
    startedAt: startedAt,
    finishedAt: finishedAt,
    rating: rating,
    isReread: isReread,
    readCount: readCount ?? this.readCount,
  );

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
    readCount,
  ];
}
