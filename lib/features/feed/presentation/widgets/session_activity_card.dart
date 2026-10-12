import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../domain/entities/activity.dart';
import 'activity_author_header.dart';
import 'activity_card_footer.dart';
import '../../../../core/theme/build_context_extension.dart';

/// Same visual language as `ShelfBookCard`. The cover/title/stats block
/// navigates to [ActivityDetailPage] — kept as a plain sibling of
/// [ActivityCardFooter] (not wrapping it), so this tap target never
/// overlaps the footer's own like/comment/visibility gestures.
class SessionActivityCard extends StatelessWidget {
  const SessionActivityCard({
    super.key,
    required this.activity,
    this.isOwnActivity = true,
    this.author,
    this.bordered = true,
  });

  final Activity activity;
  final bool isOwnActivity;
  final bool bordered;

  /// Optional author header override. Own activities always show a header
  /// so their visibility menu has a place next to the name.
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
    final payload = activity.payload as SessionActivityPayload;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (author != null || isOwnActivity) ...[
          ActivityAuthorHeader(
            name: author?.name ?? activity.author.name,
            avatarUrl: author?.avatarUrl ?? activity.author.avatarUrl,
            occurredAt: author?.occurredAt ?? activity.occurredAt,
            trailing: isOwnActivity
                ? ActivityVisibilityMenu(activityId: activity.id)
                : null,
          ),
          const SizedBox(height: 12),
        ],
        Material(
          // Transparent so the card's own colour still shows, but the tap
          // ripple has something to paint on.
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => _openDetail(context),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(payload.bookTitle, style: AppTypography.subheading),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          for (final stat in [
                            (
                              label: l10n.shareStatTime,
                              value: formatSessionDurationWords(
                                Duration(
                                  seconds: payload.activeDurationSeconds,
                                ),
                              ),
                            ),
                            (
                              label: l10n.shareStatPages,
                              value: payload.pagesRead.toString(),
                            ),
                            (
                              label: l10n.shareStatSpeed,
                              value: l10n.speedPpmValue(
                                payload.speedPpm.toStringAsFixed(1),
                              ),
                            ),
                          ])
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stat.label, style: AppTypography.caption),
                                const SizedBox(height: 4),
                                Text(
                                  stat.value,
                                  style: AppTypography.subheading,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: SizedBox(
                    // Bigger than the list-row thumbnail it started as: the
                    // book is what the eye should land on in a feed, and it
                    // stays on the right so the author's name, the title and
                    // the stats above and below it keep one left edge.
                    width: 56,
                    height: 80,
                    child: payload.bookCoverUrl == null
                        ? Container(color: context.colors.tangerineWash)
                        : Image.network(
                            payload.bookCoverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: context.colors.tangerineWash),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ActivityCardFooter(activity: activity, isOwnActivity: isOwnActivity),
      ],
    );
    if (!bordered) {
      return Padding(padding: const EdgeInsets.all(16), child: content);
    }
    return BorderedCard(
      radius: AppRadius.md,
      padding: const EdgeInsets.all(12),
      child: content,
    );
  }
}
