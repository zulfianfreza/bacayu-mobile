import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../books/presentation/pages/book_detail_page.dart';
import '../../domain/entities/user_book.dart';
import '../cubit/shelf_cubit.dart';
import 'status_picker_bottom_sheet.dart';

/// Cover/title/progress area and the status chip each own their own tap
/// target — NEVER nest one inside the other's `InkWell`. A tap landing
/// inside the chip must only open [StatusPickerBottomSheet], never also
/// navigate to [BookDetailPage] (and vice versa); nested `InkWell`s make
/// that ambiguous (only one of the two ever wins the gesture arena).
class ShelfBookCard extends StatelessWidget {
  const ShelfBookCard({super.key, required this.userBook}) : compact = false;

  /// For a horizontal carousel, which hands the card a fixed height instead
  /// of the intrinsic one a vertical list gives it.
  ///
  /// It drops the status chip: the row that uses this is "Continue reading",
  /// where every book is reading by definition, so the chip said the same
  /// word on every card and cost the height the layout did not have.
  const ShelfBookCard.compact({super.key, required this.userBook})
      : compact = true;

  /// The height the compact variant needs at the default text size.
  static const compactHeight = 132.0;

  /// [compactHeight] scaled with the user's font size.
  ///
  /// The compact variant grows with its text, so a plain fixed box would
  /// overflow again the moment someone sets a larger type size — always size
  /// the carousel through this, never with the raw constant.
  static double compactHeightFor(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(compactHeight);

  final UserBook userBook;

  /// Whether this card is laid out for a fixed-height carousel slot.
  final bool compact;

  void _openBookDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookDetailPage(bookId: userBook.book.id),
      ),
    );
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
    final book = userBook.book;
    final showProgress = userBook.status == ShelfStatus.reading &&
        book.totalPages != null &&
        book.totalPages! > 0;

    return Card(
      // The carousel supplies its own gaps, and the default margin would knock
      // the row out of line with the section title above it.
      margin: compact ? EdgeInsets.zero : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _openBookDetail(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
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
                        Text(
                          book.title,
                          style: AppTypography.subheading,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (book.authors.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.byAuthor(book.authors.join(', ')),
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!compact)
            Padding(
              padding: EdgeInsets.fromLTRB(72, 0, 12, showProgress ? 4 : 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusChip(
                  status: userBook.status,
                  onTap: () => _openStatusPicker(context),
                ),
              ),
            ),
          if (showProgress)
            InkWell(
              onTap: () => _openBookDetail(context),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(72, 4, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: (userBook.currentPage / book.totalPages!)
                            .clamp(0, 1)
                            .toDouble(),
                        minHeight: 4,
                        backgroundColor: AppColors.line,
                        color: AppColors.lagoon500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.pageProgress(
                        userBook.currentPage,
                        book.totalPages!,
                      ),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ),
        ],
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
          AppColors.line,
          AppColors.inkSoft,
        ),
      ShelfStatus.reading => (
          l10n.statusReading,
          AppColors.lagoon100,
          AppColors.lagoon700,
        ),
      ShelfStatus.finished => (
          l10n.statusFinished,
          AppColors.sunshine100,
          AppColors.sunshine700,
        ),
      ShelfStatus.dnf => (
          l10n.statusDnf,
          AppColors.line,
          AppColors.inkSoft,
        ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
      color: AppColors.tangerine50,
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book, color: AppColors.tangerine300),
    );
  }
}
