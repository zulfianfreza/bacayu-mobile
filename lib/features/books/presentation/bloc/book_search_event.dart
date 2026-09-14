import 'package:equatable/equatable.dart';

import '../../domain/entities/book.dart';

sealed class BookSearchEvent extends Equatable {
  const BookSearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends BookSearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// User tapped "+" on a search result — triggers `ImportBookFromGoogle`.
class SearchResultSelected extends BookSearchEvent {
  const SearchResultSelected(this.book);

  final Book book;

  @override
  List<Object?> get props => [book];
}
