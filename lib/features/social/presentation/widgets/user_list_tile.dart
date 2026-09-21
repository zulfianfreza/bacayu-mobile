import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../domain/entities/followed_user.dart';
import '../../../../core/theme/build_context_extension.dart';

/// One person in a follow list: who they are, and the button that changes
/// whether you follow them. Reused by `FollowersPage` and `FollowingPage`.
class UserListTile extends StatelessWidget {
  const UserListTile({
    super.key,
    required this.user,
    required this.isPending,
    required this.onToggleFollow,
    this.showFollowsYouBack = false,
  });

  final FollowedUser user;
  final bool isPending;
  final VoidCallback onToggleFollow;

  /// Only the following list passes true: in a followers list every row
  /// follows you by definition, so the caption would repeat itself down the
  /// whole page.
  final bool showFollowsYouBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final avatarUrl = user.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return BorderedCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: context.colors.tangerineTint,
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
            child: hasAvatar
                ? null
                : Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: AppTypography.bodyStrong.copyWith(
                      color: context.colors.tangerineAccent,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user.name, style: AppTypography.subheading),
                if (showFollowsYouBack && user.isFollowedBy) ...[
                  const SizedBox(height: 2),
                  Text(l10n.followsYouBack, style: AppTypography.caption),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Bounded width on purpose: ChunkyButton lays its label out with a
          // Flexible, so as a bare Row child it would get unbounded space.
          SizedBox(
            width: 116,
            child: ChunkyButton(
              label: user.isFollowing ? l10n.followingButton : l10n.follow,
              variant: user.isFollowing
                  ? ChunkyButtonVariant.secondary
                  : ChunkyButtonVariant.primary,
              onPressed: isPending ? null : onToggleFollow,
              isLoading: isPending,
            ),
          ),
        ],
      ),
    );
  }
}
