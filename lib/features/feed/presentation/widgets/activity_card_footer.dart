import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../social/domain/entities/activity_visibility.dart';
import '../../../social/domain/usecases/update_activity_visibility.dart';
import '../../../social/presentation/widgets/comments_bottom_sheet.dart';
import '../../../social/presentation/widgets/like_button.dart';
import '../../domain/entities/activity.dart';
import 'activity_share.dart';
import '../../../../core/theme/build_context_extension.dart';

/// Bottom row shared by [SessionActivityCard]/[BadgeActivityCard] — like
/// count, comment count (tap opens [CommentsBottomSheet]), a share button on
/// the viewer's own session activities, and — only for the viewer's own
/// activity — a small "..." menu to change visibility.
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
    return CommentsBottomSheet.show(context, activityId: activity.id);
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
    final canShare = canShareActivity(activity, isOwnActivity: isOwnActivity);

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
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text('${activity.commentCount}', style: AppTypography.caption),
              ],
            ),
          ),
        ),
        // Sharing is offered on the card itself, not only inside the detail
        // page: posting the session is what the card is for, and on your own
        // activity this is the action you came back for.
        if (canShare) ...[
          const SizedBox(width: 4),
          Semantics(
            label: l10n.share,
            button: true,
            child: InkWell(
              onTap: () => shareActivity(context, activity),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Padding(
                // Same padding as the comment action so the two read as one
                // row of equally weighted controls.
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Image.asset(
                  'assets/icons/share-stroke.png',
                  width: 24,
                  height: 24,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
        const Spacer(),
        if (isOwnActivity)
          PopupMenuButton<ActivityVisibility>(
            icon: Icon(
              Icons.more_vert,
              size: 18,
              color: context.colors.textSecondary,
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
