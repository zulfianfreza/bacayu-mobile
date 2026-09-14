import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/activity.dart';

/// Sunshine-tinted, more celebratory than [SessionActivityCard] — PRD
/// Section 3.9 / Style Guide: badge unlocks are the "loud" feed moment.
class BadgeActivityCard extends StatelessWidget {
  const BadgeActivityCard({super.key, required this.payload});

  final BadgeActivityPayload payload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sunshine100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
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
    );
  }
}
