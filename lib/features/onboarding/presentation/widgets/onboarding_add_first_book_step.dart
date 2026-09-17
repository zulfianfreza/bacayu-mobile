import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/presentation/bloc/book_search_bloc.dart';
import '../../../books/presentation/bloc/book_search_event.dart';
import '../../../books/presentation/bloc/book_search_state.dart';
import '../../../books/presentation/pages/barcode_scanner_page.dart';
import '../../../books/presentation/widgets/add_manual_book_sheet.dart';
import '../../../books/presentation/widgets/book_result_card.dart';
import '../../../shelf/domain/usecases/add_to_shelf.dart';

/// Reuses `books` (search/scan/manual) and `shelf` (AddToShelf) as-is — no
/// duplicated add-to-shelf logic. This widget's own job stops at wiring
/// those together for the onboarding layout (UI Generation Prompts
/// Section 1, screen 3).
class OnboardingAddFirstBookStep extends StatelessWidget {
  const OnboardingAddFirstBookStep({
    super.key,
    required this.onDone,
    required this.onSkip,
  });

  /// Called once a book has actually been added to the shelf.
  final VoidCallback onDone;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookSearchBloc>(),
      child: _AddFirstBookView(onDone: onDone, onSkip: onSkip),
    );
  }
}

class _AddFirstBookView extends StatefulWidget {
  const _AddFirstBookView({required this.onDone, required this.onSkip});

  final VoidCallback onDone;
  final VoidCallback onSkip;

  @override
  State<_AddFirstBookView> createState() => _AddFirstBookViewState();
}

class _AddFirstBookViewState extends State<_AddFirstBookView> {
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _addToShelf(BuildContext context, Book book) async {
    final result = await getIt<AddToShelf>().call(bookId: book.id);
    if (!context.mounted) return;
    result.fold(
      (failure) => context.showFailureSnackBar(failure),
      (_) => widget.onDone(),
    );
  }

  Future<void> _openScanner(BuildContext context) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerPage(closeOnAdd: true),
      ),
    );
    if (added == true) widget.onDone();
  }

  Future<void> _openManualAdd(BuildContext context) async {
    final book = await showModalBottomSheet<Book>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddManualBookSheet(),
    );
    if (book == null || !context.mounted) return;
    await _addToShelf(context, book);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(l10n.addFirstBookHeadline, style: AppTypography.heading),
          const SizedBox(height: 16),
          TextField(
            controller: _queryController,
            decoration: InputDecoration(
              hintText: l10n.searchTitleOrAuthorHint,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (query) =>
                context.read<BookSearchBloc>().add(SearchQueryChanged(query)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openScanner(context),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l10n.scanIsbn),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openManualAdd(context),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.addManually),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocConsumer<BookSearchBloc, BookSearchState>(
              listener: (context, state) {
                if (state is BookImported) {
                  _addToShelf(context, state.book);
                } else if (state is BookImportError) {
                  context.showFailureSnackBar(state.failure);
                }
              },
              builder: (context, state) {
                if (state is BookSearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = switch (state) {
                  BookSearchLoaded(:final results) => results,
                  BookImporting(:final results) => results,
                  BookImported(:final results) => results,
                  BookImportError(:final results) => results,
                  _ => const <Book>[],
                };

                if (results.isEmpty) return const SizedBox.shrink();

                return ListView.builder(
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
                );
              },
            ),
          ),
          Center(
            child: TextButton(
              onPressed: widget.onSkip,
              child: Text(l10n.illDoThisLater),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
