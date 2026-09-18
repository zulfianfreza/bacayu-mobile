import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/raised_box.dart';

/// One stat, built the way Duolingo builds its tiles: a chunky body with a
/// solid slab peeking out underneath, a big bold number, and a quiet label.
///
/// The slab is what does the work. A flat tinted rectangle reads as
/// decoration; the darker edge makes the tile read as a physical object you
/// could press, which is the whole character of that style.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.tint,
    this.icon,
  });

  /// Height one card needs at the default text size, edge included.
  ///
  /// Sized for a label that wraps to two lines: "Rata-rata kecepatan" already
  /// does, and translations only get longer. A one-line label simply gets more
  /// air above it.
  static const height = 128.0;

  /// [height] scaled with the user's font size.
  ///
  /// The card carries type, so a plain fixed box would clip it the moment
  /// someone sets a larger type size — size the grid through this, never with
  /// the raw constant.
  static double heightFor(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(height);

  final String value;
  final String label;

  /// The card body. Its own darker shade becomes the edge, so a card only ever
  /// needs one colour from the palette.
  final Color tint;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return RaisedBox(
      color: tint,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Icon pinned to the top, number and label to the bottom, so every
        // tile in the grid lines up whatever its content.
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (icon != null) Icon(icon, size: 20, color: AppColors.ink),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.displaySm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(color: AppColors.ink),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
