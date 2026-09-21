import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'bordered_card.dart';
import '../theme/build_context_extension.dart';

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
          color: selected ? context.colors.tangerineTint : context.colors.surface,
          borderColor: selected ? AppColors.tangerine300 : context.colors.hairline,
          radius: AppRadius.md,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyStrong.copyWith(
                    color: selected ? context.colors.tangerineAccent : context.colors.ink,
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
