import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../domain/entities/activity_comment.dart';

/// One comment, as its own chunky card so a thread reads as a stack of posts
/// rather than loose lines of text.
///
/// Shared by the inline thread on an activity's detail page and the quick
/// comments sheet — the same comment has to look the same in both.
class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment});

  final ActivityComment comment;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = comment.userAvatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return BorderedCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.tangerine100,
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
            child: hasAvatar
                ? null
                : Text(
                    comment.userName.isEmpty
                        ? '?'
                        : comment.userName[0].toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.tangerine700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.userName, style: AppTypography.bodyStrong),
                const SizedBox(height: 2),
                Text(comment.body, style: AppTypography.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Nothing said yet — an invitation rather than a blank gap. Shared with
/// [CommentTile] for the same reason.
class CommentsEmpty extends StatelessWidget {
  const CommentsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/message-stroke.png',
            width: 32,
            height: 32,
            color: AppColors.tangerine300,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.noComments,
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
