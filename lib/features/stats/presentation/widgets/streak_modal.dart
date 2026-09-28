import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/build_context_extension.dart';

class StreakModal extends StatelessWidget {
  const StreakModal({super.key, required this.current, required this.longest});

  final int current;
  final int longest;

  static Future<void> show(
    BuildContext context, {
    required int current,
    required int longest,
  }) => showDialog<void>(
    context: context,
    builder: (_) => StreakModal(current: current, longest: longest),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.tangerine,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(l10n.streakExtendedTitle, style: AppTypography.heading),
            const SizedBox(height: 12),
            Text('$current', style: AppTypography.displayLg),
            Text(l10n.dayStreak, style: context.captionStyle),
            const SizedBox(height: 12),
            Text(l10n.longestStreakDays(longest), style: context.captionStyle),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.tangerine,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(l10n.awesome),
            ),
          ],
        ),
      ),
    );
  }
}
