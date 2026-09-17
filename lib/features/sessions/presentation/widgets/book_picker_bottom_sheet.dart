import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.whatAreYouReading, style: AppTypography.heading),
            const SizedBox(height: 4),
            Text(l10n.bookPickerSubtitle, style: AppTypography.caption),
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
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.noReadingBooks,
                              style: AppTypography.body,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: books.length,
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

/// One pickable book: cover, title, author, and where the reader is up to.
///
/// A hand-rolled row rather than a [ListTile]: the tile's fixed two/three-line
/// heights fight a title that is allowed to run to its full length.
class _BookOption extends StatelessWidget {
  const _BookOption({required this.userBook, required this.onTap});

  final UserBook userBook;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final book = userBook.book;
    final totalPages = book.totalPages;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                width: 40,
                height: 56,
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
                    const SizedBox(height: 2),
                    Text(
                      l10n.byAuthor(book.authors.join(', ')),
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // Only when there is a total to measure against — a bare
                  // "page 50" would read as progress it cannot show.
                  if (totalPages != null && totalPages > 0) ...[
                    const SizedBox(height: 2),
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
