import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../domain/entities/activity.dart';

/// Read-only — same visual language as `ShelfBookCard`, but no actions
/// (nothing to tap: this is someone's past activity, not their shelf).
class SessionActivityCard extends StatelessWidget {
  const SessionActivityCard({super.key, required this.payload});

  final SessionActivityPayload payload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                  Text(l10n.pagesCount(payload.pagesRead), style: AppTypography.caption),
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
    );
  }
}
