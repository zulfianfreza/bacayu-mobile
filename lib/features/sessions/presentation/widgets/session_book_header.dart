import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../shelf/domain/entities/user_book.dart';

/// The book a session is about, as a card: cover, title, author.
///
/// Shared by the timer/manual choice page and the manual form so the reader
/// always sees the same book card while logging.
class SessionBookHeader extends StatelessWidget {
  const SessionBookHeader({super.key, required this.userBook});

  final UserBook userBook;

  static const _coverWidth = 48.0;
  static const _coverHeight = 68.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final book = userBook.book;

    return BorderedCard(
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
                // Uncapped, like every other book card: a half-title is worse
                // than a taller card.
                Text(book.title, style: AppTypography.subheading),
                if (book.authors.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.byAuthor(book.authors.join(', ')),
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ),
          ),
        ],
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
        child: Icon(Icons.menu_book, color: AppColors.tangerine300, size: 20),
      ),
    );
  }
}
