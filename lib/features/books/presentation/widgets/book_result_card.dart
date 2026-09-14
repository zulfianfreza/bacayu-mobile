import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
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

    return Card(
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
            if (onAdd != null)
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle, color: AppColors.tangerine),
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
    return Container(
      color: AppColors.tangerine50,
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book, color: AppColors.tangerine300),
    );
  }
}
