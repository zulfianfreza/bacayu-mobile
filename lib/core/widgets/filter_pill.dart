import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/build_context_extension.dart';
import 'raised_box.dart';

/// One option in a rail/row of pressable filters — the shelf's status tabs and
/// the stats range control are the same object, so they share this one shape
/// (pill, own edge, filled when active) instead of drifting apart again.
///
/// Without [expand] the pill sizes to its label, for a scrolling rail. With
/// [expand] it shares the row's width and shrinks the label to fit, for a
/// fixed row where every option is equal.
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.expand = false,
    this.compact = false,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: (compact ? AppTypography.caption : AppTypography.button).copyWith(
        color: isActive ? Colors.white : context.colors.textSecondary,
      ),
    );

    return Semantics(
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Align(
            widthFactor: 1,
            heightFactor: 1,
            child: RaisedBox(
              color: isActive ? AppColors.tangerine : context.colors.surface,
              radius: AppRadius.pill,
              edgeHeight: compact ? 2 : 3,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 16,
                vertical: compact ? 7 : 10,
              ),
              child: expand
                  ? SizedBox(
                      width: double.infinity,
                      // Four labels share one row in every language, and "Minggu" is
                      // already tight in Indonesian — shrink rather than truncate.
                      child: FittedBox(fit: BoxFit.scaleDown, child: text),
                    )
                  : text,
            ),
          ),
        ),
      ),
    );
  }
}
