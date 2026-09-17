import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../shelf/domain/usecases/add_to_shelf.dart';
import '../../domain/entities/book.dart';
import '../bloc/book_search_bloc.dart';
import '../bloc/book_search_event.dart';
import '../bloc/book_search_state.dart';
import '../widgets/book_result_card.dart';
import 'barcode_scanner_page.dart';

class BookSearchPage extends StatelessWidget {
  const BookSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookSearchBloc>(),
      child: const _BookSearchView(),
    );
  }
}

class _BookSearchView extends StatefulWidget {
  const _BookSearchView();

  @override
  State<_BookSearchView> createState() => _BookSearchViewState();
}

class _BookSearchViewState extends State<_BookSearchView> {
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _addToShelf(BuildContext context, Book book) async {
    final l10n = context.l10n;
    final result = await getIt<AddToShelf>().call(bookId: book.id);
    if (!context.mounted) return;
    result.fold(
      (failure) => context.showFailureSnackBar(failure),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bookAddedToShelf)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchBooksHint,
            border: InputBorder.none,
          ),
          onChanged: (query) =>
              context.read<BookSearchBloc>().add(SearchQueryChanged(query)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: l10n.scanBarcode,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
            ),
          ),
        ],
      ),
      body: BlocConsumer<BookSearchBloc, BookSearchState>(
        listener: (context, state) {
          if (state is BookImported) {
            _addToShelf(context, state.book);
          } else if (state is BookImportError) {
            context.showFailureSnackBar(state.failure);
          }
        },
        builder: (context, state) {
          return switch (state) {
            BookSearchInitial() => const SizedBox.shrink(),
            BookSearchLoading() =>
              const Center(child: CircularProgressIndicator()),
            BookSearchError(:final failure) => Center(
                child: Text(
                  failure.localizedMessage(context),
                  style: AppTypography.body,
                ),
              ),
            BookSearchLoaded(:final results) ||
            BookImporting(:final results) ||
            BookImported(:final results) ||
            BookImportError(:final results) =>
              results.isEmpty
                  ? Center(
                      child: Text(l10n.noSearchResults,
                          style: AppTypography.body),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final book = results[index];
                        final isImportingThis =
                            state is BookImporting && state.selected == book;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: isImportingThis
                              ? const Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                )
                              : BookResultCard(
                                  book: book,
                                  onAdd: () => context
                                      .read<BookSearchBloc>()
                                      .add(SearchResultSelected(book)),
                                ),
                        );
                      },
                    ),
          };
        },
      ),
    );
  }
}
