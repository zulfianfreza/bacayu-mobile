import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../social/domain/entities/activity_visibility.dart';
import '../../../social/domain/usecases/update_activity_visibility.dart';
import '../../../social/presentation/widgets/comments_bottom_sheet.dart';
import '../../../social/presentation/widgets/like_button.dart';
import '../../domain/entities/activity.dart';

/// Bottom row shared by [SessionActivityCard]/[BadgeActivityCard] — like
/// count, comment count (tap opens [CommentsBottomSheet]), and — only for
/// the requester's own activity — a small "..." menu to change visibility.
///
/// [isOwnActivity] is caller-supplied rather than derived here: the caller
/// knows who is viewing (the social feed keeps the viewer's id alongside the
/// page), and an item's author now comes from the feed itself, so the
/// comparison belongs where both are in scope.
class ActivityCardFooter extends StatelessWidget {
  const ActivityCardFooter({
    super.key,
    required this.activity,
    this.isOwnActivity = true,
  });

  final Activity activity;
  final bool isOwnActivity;

  Future<void> _openComments(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => CommentsBottomSheet(activityId: activity.id),
    );
  }

  Future<void> _changeVisibility(
    BuildContext context,
    ActivityVisibility visibility,
  ) async {
    final l10n = context.l10n;
    final result = await getIt<UpdateActivityVisibility>().call(
      activityId: activity.id,
      visibility: visibility,
    );
    if (!context.mounted) return;
    result.fold(
      (failure) => context.showFailureSnackBar(failure),
      (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.visibilityUpdated))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        LikeButton(
          activityId: activity.id,
          initialIsLiked: activity.isLiked,
          initialLikeCount: activity.likeCount,
        ),
        InkWell(
          onTap: () => _openComments(context),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/message-stroke.png',
                  width: 24,
                  height: 24,
                  color: AppColors.inkSoft,
                ),
                const SizedBox(width: 4),
                Text('${activity.commentCount}', style: AppTypography.caption),
              ],
            ),
          ),
        ),
        const Spacer(),
        if (isOwnActivity)
          PopupMenuButton<ActivityVisibility>(
            icon: const Icon(
              Icons.more_vert,
              size: 18,
              color: AppColors.inkSoft,
            ),
            tooltip: l10n.changeVisibility,
            onSelected: (visibility) => _changeVisibility(context, visibility),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ActivityVisibility.private,
                child: Text(l10n.visibilityPrivate),
              ),
              PopupMenuItem(
                value: ActivityVisibility.followers,
                child: Text(l10n.visibilityFollowers),
              ),
              PopupMenuItem(
                value: ActivityVisibility.public,
                child: Text(l10n.visibilityPublic),
              ),
            ],
          ),
      ],
    );
  }
}
