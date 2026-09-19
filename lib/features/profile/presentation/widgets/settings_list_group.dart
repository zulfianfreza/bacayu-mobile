import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';

/// Rounded card housing a group of [SettingsListTile]s with a divider
/// between rows — Style Guide list pattern (one card per GROUP, never one
/// card per item).
///
/// Built on [BorderedCard] so the group carries the app's chunky border: a
/// hairline on three sides and a slightly thicker base. That is what makes it
/// read as a panel you could press rather than a flat section.
class SettingsListGroup extends StatelessWidget {
  const SettingsListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // BorderedCard does not clip on its own; without this the row ripples
      // would paint past the rounded corners.
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: BorderedCard(
        radius: AppRadius.md,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                const Divider(
                  height: 1,
                  color: AppColors.slate200,
                  indent: 16,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.danger : AppColors.tangerine700;
    // The chip recipe one size up: a tint of the row's own colour behind an
    // icon in its 700 step.
    final bubble = destructive
        ? AppColors.danger.withValues(alpha: 0.12)
        : AppColors.tangerine100;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bubble,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Image.asset(icon, width: 18, height: 18, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyStrong.copyWith(
                  color: destructive ? AppColors.danger : AppColors.ink,
                ),
              ),
            ),
            if (!destructive)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.slate400,
              ),
          ],
        ),
      ),
    );
  }
}
