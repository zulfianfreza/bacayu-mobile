import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'bordered_card.dart';

/// One choice in a picker sheet: a chunky border row that tints itself, and
/// shows its own tick, when it is the selected one.
///
/// The language and privacy sheets are the same control in different clothes —
/// this is that control, so the two cannot drift apart. The picked row borders
/// from its own ramp rather than the neutral hairline: on a tinted surface the
/// warm grey edge reads as a mistake.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;

  /// `null` disables the row — e.g. while a save is already in flight.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: BorderedCard(
          color: selected ? AppColors.tangerine100 : AppColors.surface,
          borderColor: selected ? AppColors.tangerine300 : AppColors.slate200,
          radius: AppRadius.md,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyStrong.copyWith(
                    color: selected ? AppColors.tangerine700 : AppColors.ink,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: AppColors.tangerine500,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
