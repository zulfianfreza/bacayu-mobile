import 'package:flutter/material.dart';

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
    required this.accent,
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

  /// The card body — a step-100 tint, so the grid reads soft rather than
  /// saturated. Its own darker shade becomes the slab underneath.
  final Color tint;

  /// The colour of [icon], from the same family's 700 step: at this tint the
  /// body is too pale to carry the tile's identity on its own.
  final Color accent;

  /// Asset path, drawn in [accent]. The app's icons are files rather than
  /// [IconData], so the artwork can be swapped without touching this widget.
  final String? icon;

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
          if (icon != null) Image.asset(icon!, width: 24, height: 24, color: accent),
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
                style: AppTypography.caption,
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
