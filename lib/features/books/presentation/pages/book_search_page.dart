import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/navigation/full_screen_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../shelf/domain/usecases/add_to_shelf.dart';
import '../../domain/entities/book.dart';
import '../bloc/book_search_bloc.dart';
import '../bloc/book_search_event.dart';
import '../bloc/book_search_state.dart';
import '../widgets/book_result_card.dart';
import 'barcode_scanner_page.dart';
import '../../../../core/theme/build_context_extension.dart';

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
      (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.bookAddedToShelf))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addABook),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/barcode-scan-stroke.png',
              width: 24,
              height: 24,
              color: context.colors.ink,
            ),
            tooltip: l10n.scanBarcode,
            onPressed: () =>
                pushFullScreen(context, (_) => const BarcodeScannerPage()),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // The field lives in the body, not in the app bar: a chunky
            // bordered input does not fit an app bar's height.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _queryController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.searchBooksHint,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Image.asset(
                      'assets/icons/search-stroke.png',
                      width: 20,
                      height: 20,
                      color: context.colors.textFaint,
                    ),
                  ),
                  // The decorator's default minimum here is 48x48 — a tap
                  // target, which would stretch this decorative glyph to the
                  // field's full height.
                  prefixIconConstraints: const BoxConstraints(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: _fieldBorder(context.colors.hairline),
                  enabledBorder: _fieldBorder(context.colors.hairline),
                  focusedBorder: _fieldBorder(
                    AppColors.tangerine,
                    width: 2.5,
                  ),
                ),
                onChanged: (query) => context.read<BookSearchBloc>().add(
                  SearchQueryChanged(query),
                ),
              ),
            ),
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
                  return switch (state) {
                    BookSearchInitial() => const SizedBox.shrink(),
                    BookSearchLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    BookSearchError(:final failure) => _SearchMessage(
                      icon: Icons.cloud_off,
                      text: failure.localizedMessage(context),
                    ),
                    BookSearchLoaded(:final results) ||
                    BookImporting(:final results) ||
                    BookImported(:final results) ||
                    BookImportError(:final results) =>
                      results.isEmpty
                          ? _SearchMessage(
                              icon: Icons.search_off,
                              text: l10n.noSearchResults,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final book = results[index];
                                final isImportingThis =
                                    state is BookImporting &&
                                    state.selected == book;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: isImportingThis
                                      ? const _ImportingCard()
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
            ),
          ],
        ),
      ),
    );
  }
}

/// The chunky input the rest of the app's forms use: a thick rounded border,
/// with focus called out by colour rather than a hairline.
OutlineInputBorder _fieldBorder(Color color, {double width = 2}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: color, width: width),
  );
}

/// A centred icon and line — used for both "nothing matched" and "the search
/// itself failed", so an empty result never reads as a broken screen.
class _SearchMessage extends StatelessWidget {
  const _SearchMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.tangerine300),
            const SizedBox(height: 12),
            Text(text, style: AppTypography.body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// The result that is being imported right now, in the same chunky card the
/// others use — the list should not change shape while a row is busy.
class _ImportingCard extends StatelessWidget {
  const _ImportingCard();

  @override
  Widget build(BuildContext context) {
    return const BorderedCard(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
