import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/user_book.dart';

class ShelfBookCard extends StatelessWidget {
  const ShelfBookCard({super.key, required this.userBook, this.onTap});

  final UserBook userBook;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final book = userBook.book;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                    const SizedBox(height: 8),
                    _StatusChip(status: userBook.status),
                    if (userBook.status == ShelfStatus.reading &&
                        book.totalPages != null &&
                        book.totalPages! > 0) ...[
                      const SizedBox(height: 8),
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
  const _StatusChip({required this.status});

  final ShelfStatus status;

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: foreground),
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
