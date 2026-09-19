import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/raised_box.dart';
import '../../domain/entities/book.dart';

/// Reusable book row — cover, title, author, page count, optional trailing
/// "+" button. Used by both the search results list and the barcode scan
/// result sheet.
class BookResultCard extends StatelessWidget {
  const BookResultCard({super.key, required this.book, this.onAdd});

  final Book book;

  /// When null, the trailing "+" button is hidden (e.g. the scan sheet uses
  /// its own full-width "Add to shelf" button instead).
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BorderedCard(
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
                // Uncapped, like every other book card: a half-title is worse
                // than a taller row.
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
                if (book.totalPages != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.pagesCount(book.totalPages!),
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ),
          ),
          if (onAdd != null) ...[
            const SizedBox(width: 8),
            _AddButton(onTap: onAdd!),
          ],
        ],
      ),
    );
  }
}

/// The add affordance: a small chunky tile, the same one-accent colour the
/// app's primary actions use.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.addToShelf,
      child: GestureDetector(
        onTap: onTap,
        child: RaisedBox(
          color: AppColors.tangerine,
          radius: AppRadius.md,
          edgeHeight: 3,
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.tangerine50,
      child: Center(
        child: Icon(Icons.menu_book, color: AppColors.tangerine300),
      ),
    );
  }
}
