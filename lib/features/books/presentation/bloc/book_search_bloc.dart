import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/debounce_event_transformer.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/import_book_from_google.dart';
import '../../domain/usecases/search_books.dart';
import 'book_search_event.dart';
import 'book_search_state.dart';

/// BLoC (not Cubit) — search-as-you-type needs the debounce transformer on
/// `SearchQueryChanged`, per CLAUDE.md Section 5.2.
@injectable
class BookSearchBloc extends Bloc<BookSearchEvent, BookSearchState> {
  BookSearchBloc(this._searchBooks, this._importBookFromGoogle)
      : super(const BookSearchInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounce(const Duration(milliseconds: 400)),
    );
    on<SearchResultSelected>(_onResultSelected);
  }

  final SearchBooks _searchBooks;
  final ImportBookFromGoogle _importBookFromGoogle;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<BookSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const BookSearchInitial());
      return;
    }

    emit(const BookSearchLoading());
    final result = await _searchBooks(query);
    result.fold(
      (failure) => emit(BookSearchError(failure)),
      (books) => emit(BookSearchLoaded(books)),
    );
  }

  Future<void> _onResultSelected(
    SearchResultSelected event,
    Emitter<BookSearchState> emit,
  ) async {
    final results = _currentResults(state);
    emit(BookImporting(results: results, selected: event.book));

    final result = await _importBookFromGoogle(event.book.googleBooksId!);
    result.fold(
      (failure) => emit(BookImportError(results: results, failure: failure)),
      (book) => emit(BookImported(results: results, book: book)),
    );
  }

  List<Book> _currentResults(BookSearchState state) => switch (state) {
        BookSearchLoaded(:final results) => results,
        BookImporting(:final results) => results,
        BookImported(:final results) => results,
        BookImportError(:final results) => results,
        _ => const [],
      };
}
