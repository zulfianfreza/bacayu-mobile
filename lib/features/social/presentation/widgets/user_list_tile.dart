import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/followed_user.dart';

/// Reused by both `FollowersPage` and `FollowingPage`.
class UserListTile extends StatelessWidget {
  const UserListTile({
    super.key,
    required this.user,
    required this.isPending,
    required this.onToggleFollow,
  });

  final FollowedUser user;
  final bool isPending;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final avatarUrl = user.avatarUrl;

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.tangerine100,
        backgroundImage: avatarUrl == null || avatarUrl.isEmpty
            ? null
            : NetworkImage(avatarUrl),
        child: avatarUrl == null || avatarUrl.isEmpty
            ? Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: AppTypography.bodyStrong.copyWith(color: AppColors.tangerine700),
              )
            : null,
      ),
      title: Text(user.name, style: AppTypography.subheading),
      trailing: SizedBox(
        width: 100,
        child: isPending
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : user.isFollowing
                ? OutlinedButton(
                    onPressed: onToggleFollow,
                    child: Text(l10n.followingButton),
                  )
                : ElevatedButton(
                    onPressed: onToggleFollow,
                    child: Text(l10n.follow),
                  ),
      ),
    );
  }
}
