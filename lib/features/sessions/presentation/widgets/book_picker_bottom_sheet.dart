import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/sheet_header.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../../../shelf/domain/usecases/list_shelf.dart';

/// Reuses `shelf`'s `ListShelf` usecase (filtered to `reading`) — no
/// separate query/logic here.
class BookPickerBottomSheet extends StatefulWidget {
  const BookPickerBottomSheet({super.key});

  @override
  State<BookPickerBottomSheet> createState() => _BookPickerBottomSheetState();
}

class _BookPickerBottomSheetState extends State<BookPickerBottomSheet> {
  late final Future<Either<Failure, List<UserBook>>> _future =
      getIt<ListShelf>().call(status: ShelfStatus.reading);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetHeader(
              title: l10n.whatAreYouReading,
              subtitle: l10n.bookPickerSubtitle,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: FutureBuilder<Either<Failure, List<UserBook>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return snapshot.data!.fold(
                    (failure) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(failure.localizedMessage(context)),
                    ),
                    (books) => books.isEmpty
                        ? const _EmptyPicker()
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: books.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final userBook = books[index];
                              return _BookOption(
                                userBook: userBook,
                                onTap: () =>
                                    Navigator.of(context).pop(userBook),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nothing in progress: say so, and say what to do about it — with the same
/// quiet illustration the shelf's own empty state uses.
class _EmptyPicker extends StatelessWidget {
  const _EmptyPicker();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          const Icon(
            Icons.menu_book_outlined,
            size: 40,
            color: AppColors.tangerine300,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.noReadingBooks,
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// One pickable book: cover, title, author, and how far in the reader is.
///
/// Deliberately the same shape as `ShelfBookCard.compact` — a book should look
/// like a book wherever it is listed — but it pops the sheet with its entry
/// rather than navigating, so it stays its own widget. A hand-rolled row rather
/// than a [ListTile]: the tile's fixed heights fight a title that is allowed to
/// run to its full length.
class _BookOption extends StatelessWidget {
  const _BookOption({required this.userBook, required this.onTap});

  final UserBook userBook;
  final VoidCallback onTap;

  /// Cover size, matching the compact shelf card.
  static const _coverWidth = 48.0;
  static const _coverHeight = 68.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final book = userBook.book;
    final totalPages = book.totalPages;
    // Only when there is a total to measure against — a bare "page 50" would
    // read as progress it cannot show.
    final showProgress = totalPages != null && totalPages > 0;

    return BorderedCard(
      radius: AppRadius.md,
      padding: const EdgeInsets.all(12),
      child: Material(
        // Transparent so the card's own colour still shows, but the row's tap
        // ripple has something to paint on.
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: _coverWidth,
                  height: _coverHeight,
                  child: book.coverUrl == null
                      ? const _CoverPlaceholder()
                      : Image.network(
                          book.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const _CoverPlaceholder(),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: AppTypography.subheading),
                    if (book.authors.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.byAuthor(book.authors.join(', ')),
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (showProgress) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: (userBook.currentPage / totalPages)
                              .clamp(0, 1)
                              .toDouble(),
                          minHeight: 4,
                          backgroundColor: AppColors.slate200,
                          color: AppColors.lagoon500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.pageProgress(userBook.currentPage, totalPages),
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: AppColors.tangerine50);
  }
}
