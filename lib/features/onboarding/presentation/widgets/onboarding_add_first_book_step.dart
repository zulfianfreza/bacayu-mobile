import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../../core/widgets/raised_box.dart';
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
          Text(l10n.addFirstBookHeadline, style: AppTypography.displaySm),
          const SizedBox(height: 16),
          TextField(
            controller: _queryController,
            decoration: InputDecoration(
              hintText: l10n.searchTitleOrAuthorHint,
              prefixIcon: const Icon(Icons.search, color: AppColors.inkFaint),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: _searchBorder(AppColors.slate200),
              enabledBorder: _searchBorder(AppColors.slate200),
              focusedBorder: _searchBorder(AppColors.tangerine, width: 2.5),
            ),
            onChanged: (query) =>
                context.read<BookSearchBloc>().add(SearchQueryChanged(query)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ChoiceTile(
                  icon: Icons.qr_code_scanner,
                  label: l10n.scanIsbn,
                  onTap: () => _openScanner(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChoiceTile(
                  icon: Icons.edit_outlined,
                  label: l10n.addManually,
                  onTap: () => _openManualAdd(context),
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
                              onAdd: () => context.read<BookSearchBloc>().add(
                                SearchResultSelected(book),
                              ),
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

/// The chunky input the rest of the app's forms use: a thick rounded border,
/// with focus called out by colour rather than a hairline.
OutlineInputBorder _searchBorder(Color color, {double width = 2}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: color, width: width),
  );
}

/// One of the two ways to add a book. Icon above label rather than beside it:
/// the labels ("Scan ISBN", "Tambah manual") are long enough that a horizontal
/// row would squeeze one of them into an ellipsis at phone width.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RaisedBox(
        color: AppColors.surface,
        radius: AppRadius.md,
        edgeHeight: 3,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.tangerine),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.button,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
