import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'raised_box.dart';

/// A minus / value / plus row, built as one chunky control.
///
/// The onboarding goal step and the reading-goals page are the same control in
/// different clothes, so it lives here rather than being written twice.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  /// The number as it should read — already formatted with its unit.
  final String value;

  /// `null` at the floor: the minus tile goes flat instead of disappearing, so
  /// the row keeps its shape as the value changes.
  final VoidCallback? onDecrement;

  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepTile(icon: Icons.remove_rounded, onTap: onDecrement),
        Expanded(
          child: Text(
            value,
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
        ),
        _StepTile(icon: Icons.add_rounded, onTap: onIncrement),
      ],
    );
  }
}

/// One end of the stepper: a pressable tile on its own edge, flat and
/// unpressable when [onTap] is null.
class _StepTile extends StatelessWidget {
  const _StepTile({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: onTap,
        child: RaisedBox(
          color: enabled ? AppColors.tangerine : AppColors.line,
          radius: AppRadius.md,
          edgeHeight: 3,
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 22,
            color: enabled ? Colors.white : AppColors.inkFaint,
          ),
        ),
      ),
    );
  }
}
