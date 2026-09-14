import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/book.dart';

sealed class BookSearchState extends Equatable {
  const BookSearchState();

  @override
  List<Object?> get props => [];
}

class BookSearchInitial extends BookSearchState {
  const BookSearchInitial();
}

class BookSearchLoading extends BookSearchState {
  const BookSearchLoading();
}

class BookSearchLoaded extends BookSearchState {
  const BookSearchLoaded(this.results);

  final List<Book> results;

  @override
  List<Object?> get props => [results];
}

class BookSearchError extends BookSearchState {
  const BookSearchError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// `ImportBookFromGoogle` in flight after the user tapped "+" on [selected].
/// Keeps [results] so the list stays on screen while it resolves.
class BookImporting extends BookSearchState {
  const BookImporting({required this.results, required this.selected});

  final List<Book> results;
  final Book selected;

  @override
  List<Object?> get props => [results, selected];
}

/// Import succeeded — [book] now has a real internal id, ready to be passed
/// to shelf's `AddToShelf`. This bloc's job ends here; the page composes
/// the shelf call.
class BookImported extends BookSearchState {
  const BookImported({required this.results, required this.book});

  final List<Book> results;
  final Book book;

  @override
  List<Object?> get props => [results, book];
}

class BookImportError extends BookSearchState {
  const BookImportError({required this.results, required this.failure});

  final List<Book> results;
  final Failure failure;

  @override
  List<Object?> get props => [results, failure];
}
