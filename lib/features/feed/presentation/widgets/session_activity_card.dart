import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../domain/entities/activity.dart';
import 'activity_card_footer.dart';

/// Same visual language as `ShelfBookCard`. The cover/title/stats block
/// navigates to [ActivityDetailPage] — kept as a plain sibling of
/// [ActivityCardFooter] (not wrapping it), so this tap target never
/// overlaps the footer's own like/comment/visibility gestures.
class SessionActivityCard extends StatelessWidget {
  const SessionActivityCard({
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
    final payload = activity.payload as SessionActivityPayload;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _openDetail(context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: SizedBox(
                      width: 48,
                      height: 68,
                      child: payload.bookCoverUrl == null
                          ? Container(color: AppColors.tangerine50)
                          : Image.network(
                              payload.bookCoverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: AppColors.tangerine50),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payload.bookTitle,
                          style: AppTypography.subheading,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatSessionDuration(
                            Duration(seconds: payload.activeDurationSeconds),
                          ),
                          style: AppTypography.caption,
                        ),
                        Text(
                          l10n.pagesCount(payload.pagesRead),
                          style: AppTypography.caption,
                        ),
                        Text(
                          l10n.speedPpmValue(payload.speedPpm.toStringAsFixed(1)),
                          style: AppTypography.caption,
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
      ),
    );
  }
}
