import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/relative_time.dart';

/// Who posted an activity, and when: an avatar, a name, and a relative time —
/// the way a feed introduces a post before showing what was read or unlocked.
///
/// The avatar follows the same idiom as the rest of the app: a tangerine
/// circle with the first initial when there is no picture.
///
/// The feed endpoint currently only ever returns the requester's own
/// activities, so Home hands in the signed-in user. Once a following feed
/// exists, the activity's own author goes in here instead; the cards
/// themselves do not have to change.
class ActivityAuthorHeader extends StatelessWidget {
  const ActivityAuthorHeader({
    super.key,
    required this.name,
    required this.occurredAt,
    this.avatarUrl,
  });

  final String name;

  /// When it happened — "2h ago", or a plain date once it is over a week old.
  final DateTime occurredAt;

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    final hasAvatar = url != null && url.isNotEmpty;

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.tangerine100,
          backgroundImage: hasAvatar ? NetworkImage(url) : null,
          child: hasAvatar
              ? null
              : Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.tangerine700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTypography.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              formatRelativeTime(
                l10n: context.l10n,
                locale: Localizations.localeOf(context).toLanguageTag(),
                occurredAt: occurredAt,
              ),
              style: AppTypography.caption,
            ),
          ],
        ),
      ],
    );
  }
}
