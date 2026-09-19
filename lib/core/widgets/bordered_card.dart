import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// A card whose sides and top are a hairline, and whose bottom is thicker.
///
/// The sibling of `RaisedBox`: same idea — a surface with a base under it — but
/// drawn as one rounded box instead of a slab underneath. Reach for this one
/// when the card is large enough that a full edge would read as a second card,
/// or when the surface is tinted and an edge in a different hue would look
/// bolted on.
class BorderedCard extends StatelessWidget {
  const BorderedCard({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.borderColor = AppColors.slate200,
    this.radius = AppRadius.lg,
    this.padding = const EdgeInsets.all(16),
  });

  /// Sides and top: just enough to hold the card together.
  static const sideWidth = 2.0;

  /// The base. "Slightly thicker" is the whole point — any more and it stops
  /// reading as the same card.
  static const baseWidth = 4.0;

  final Widget child;
  final Color color;

  /// Slate by default, not the warm `line` the rest of the app borders with:
  /// against a white body the warm hairline goes muddy, and slate is the
  /// palette's neutral for chrome that should not read as warm.
  final Color borderColor;

  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border(
          top: BorderSide(color: borderColor, width: sideWidth),
          left: BorderSide(color: borderColor, width: sideWidth),
          right: BorderSide(color: borderColor, width: sideWidth),
          bottom: BorderSide(color: borderColor, width: baseWidth),
        ),
      ),
      child: child,
    );
  }
}
