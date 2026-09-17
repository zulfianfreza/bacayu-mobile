import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/activity.dart';
import 'activity_card_footer.dart';

/// Sunshine-tinted, more celebratory than [SessionActivityCard] — PRD
/// Section 3.9 / Style Guide: badge unlocks are the "loud" feed moment. The
/// medal/text block navigates to [ActivityDetailPage] — a plain sibling of
/// [ActivityCardFooter], never wrapping it, so it never overlaps the
/// footer's own like/comment/visibility gestures.
class BadgeActivityCard extends StatelessWidget {
  const BadgeActivityCard({
    super.key,
    required this.activity,
    this.isOwnActivity = true,
  });

  final Activity activity;
  final bool isOwnActivity;

  void _openDetail(BuildContext context) {
    context.push(
      AppRoutes.feedActivityDetailPath(activity.id),
      extra: activity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final payload = activity.payload as BadgeActivityPayload;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sunshine100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _openDetail(context),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sunshine500,
                  ),
                  alignment: Alignment.center,
                  child: Text(payload.badgeIcon, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.newBadge,
                        style: AppTypography.caption.copyWith(color: AppColors.sunshine700),
                      ),
                      Text(payload.badgeName, style: AppTypography.subheading),
                      const SizedBox(height: 2),
                      Text(
                        payload.badgeDescription,
                        style: AppTypography.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ActivityCardFooter(activity: activity, isOwnActivity: isOwnActivity),
        ],
      ),
    );
  }
}
