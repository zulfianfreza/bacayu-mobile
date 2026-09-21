import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/navigation/full_screen_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/raised_box.dart';
import '../../../books/presentation/pages/book_detail_page.dart';
import '../../domain/entities/user_book.dart';
import '../cubit/shelf_cubit.dart';
import 'status_picker_bottom_sheet.dart';

/// One book on the shelf: cover on top, everything else under it.
///
/// The card and the status chip each own their own tap target — NEVER nest one
/// inside the other's `InkWell`. A tap landing inside the chip must only open
/// [StatusPickerBottomSheet], never also navigate to [BookDetailPage] (and
/// vice versa); the chip is a sibling stacked over the card for exactly that
/// reason, so the topmost hit always wins outright.
class ShelfBookCard extends StatelessWidget {
  const ShelfBookCard({super.key, required this.userBook}) : compact = false;

  /// Cover ratio for the shelf tile, and the shape book covers actually come
  /// in — the tile takes its width from the grid column.
  static const coverAspectRatio = 2 / 3;

  /// For the home "Continue reading" carousel.
  ///
  /// It drops the status chip: every book in that row is reading by
  /// definition, so the chip said the same word on every card and cost height
  /// the row did not have. The card is otherwise sized by its own content —
  /// there is no fixed slot height to keep it inside.
  const ShelfBookCard.compact({super.key, required this.userBook})
    : compact = true;

  final UserBook userBook;

  /// Whether this card is laid out for the carousel.
  final bool compact;

  void _openBookDetail(BuildContext context) {
    pushFullScreen(context, (_) => BookDetailPage(bookId: userBook.book.id));
  }

  Future<void> _openStatusPicker(BuildContext context) async {
    final cubit = context.read<ShelfCubit>();
    final newStatus = await StatusPickerBottomSheet.show(
      context,
      currentStatus: userBook.status,
    );
    if (newStatus != null) {
      cubit.updateStatus(userBookId: userBook.id, status: newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return compact ? _buildCompact(context) : _buildGrid(context);
  }

  Widget _buildGrid(BuildContext context) {
    final l10n = context.l10n;
    final book = userBook.book;
    final totalPages = book.totalPages;
    final showProgress =
        userBook.status == ShelfStatus.reading &&
        totalPages != null &&
        totalPages > 0;

    return RaisedBox(
      color: context.colors.surface,
      outlineColor: context.colors.hairline,
      // A shallower edge than the stat tiles: a shelf is a grid of these, and
      // at 4px apiece the whole page starts to look embossed. Still thicker
      // than the hairline sides/top, so the base reads as the base.
      edgeHeight: 4,
      child: Material(
        // Transparent so the white body still shows through, but the tile's
        // own tap ripple has something to paint on.
        type: MaterialType.transparency,
        child: Stack(
          children: [
            InkWell(
              onTap: () => _openBookDetail(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: coverAspectRatio,
                    child: book.coverUrl == null
                        ? const _CoverPlaceholder()
                        : Image.network(
                            book.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const _CoverPlaceholder(),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Deliberately uncapped: a grid of half-titles is worse
                        // than a grid of uneven tiles.
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
                        if (showProgress) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: (userBook.currentPage / totalPages)
                                  .clamp(0, 1)
                                  .toDouble(),
                              minHeight: 4,
                              backgroundColor: context.colors.hairline,
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
            // Sits on the cover rather than in the text column: it is a badge,
            // and a tile this narrow has no vertical room to spare.
            Positioned(
              top: 8,
              left: 8,
              child: _StatusChip(
                status: userBook.status,
                onTap: () => _openStatusPicker(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final l10n = context.l10n;
    final book = userBook.book;
    final totalPages = book.totalPages;
    final showProgress =
        userBook.status == ShelfStatus.reading &&
        totalPages != null &&
        totalPages > 0;

    return BorderedCard(
      radius: AppRadius.md,
      padding: const EdgeInsets.all(12),
      child: Material(
        // Transparent so the card's own colour still shows, but the tile's tap
        // ripple has something to paint on.
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _openBookDetail(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: 48,
                  height: 68,
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
                    // Uncapped, like the shelf tile: the card is as tall as its
                    // own title needs, and the carousel row takes the tallest.
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
                          backgroundColor: context.colors.hairline,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, this.onTap});

  final ShelfStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, background, foreground) = switch (status) {
      ShelfStatus.wantToRead => (
        l10n.statusWantToRead,
        context.colors.hairline,
        context.colors.textSecondary,
      ),
      ShelfStatus.reading => (
        l10n.statusReading,
        context.colors.lagoonTint,
        context.colors.lagoonAccent,
      ),
      ShelfStatus.finished => (
        l10n.statusFinished,
        context.colors.sunshineTint,
        context.colors.sunshineAccent,
      ),
      ShelfStatus.dnf => (
        l10n.statusDnf,
        context.colors.hairline,
        context.colors.textSecondary,
      ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(color: foreground),
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
    return Container(
      color: context.colors.tangerineWash,
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book,
        color: AppColors.tangerine300,
        size: 32,
      ),
    );
  }
}
