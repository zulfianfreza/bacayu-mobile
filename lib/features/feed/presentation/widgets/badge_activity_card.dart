import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../badges/presentation/widgets/badge_artwork.dart';
import '../../domain/entities/activity.dart';
import 'activity_author_header.dart';
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
    this.author,
  });

  final Activity activity;
  final bool isOwnActivity;

  /// Who unlocked it. Omitted by callers that have nobody to name.
  final ActivityAuthorHeader? author;

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

    return BorderedCard(
      color: AppColors.lagoon50,
      // Tinted border rather than the neutral hairline: on a yellow card, the
      // warm grey edge reads as a mistake.
      borderColor: AppColors.lagoon300,
      radius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (author != null) ...[author!, const SizedBox(height: 12)],
          Material(
            // Transparent so the card's own colour still shows, but the tap
            // ripple has something to paint on.
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => _openDetail(context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.newBadge,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.sunshine700,
                          ),
                        ),
                        Text(
                          payload.badgeName,
                          style: AppTypography.subheading,
                        ),
                        const SizedBox(height: 2),
                        // Shown in full: a badge description is one or two
                        // sentences, and cutting it mid-sentence reads worse
                        // than a slightly taller card.
                        Text(
                          payload.badgeDescription,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // The feed payload carries the badge's emoji snapshot, not
                  // its artwork — so this shows the placeholder until
                  // `image_url` reaches the feed too.
                  const BadgeArtwork(imageUrl: null, size: 60),
                ],
              ),
            ),
          ),
          ActivityCardFooter(activity: activity, isOwnActivity: isOwnActivity),
        ],
      ),
    );
  }
}
