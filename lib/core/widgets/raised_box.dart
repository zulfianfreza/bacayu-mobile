import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

/// A box with a solid slab underneath it.
///
/// A flat filled rectangle reads as decoration; a darker edge under the body
/// makes the tile read as a physical object you could press. The edge is
/// derived from [color] — same hue, one step darker — so a caller only ever
/// passes one palette colour.
///
/// The body clips, so a cover image can bleed to its rounded corners.
class RaisedBox extends StatelessWidget {
  const RaisedBox({
    super.key,
    required this.color,
    required this.child,
    this.radius = AppRadius.md,
    this.edgeHeight = 4,
    this.padding = EdgeInsets.zero,
    this.sink = 0,
  });

  /// The body colour. The edge is [edgeShadeOf] this.
  final Color color;

  final Widget child;
  final double radius;

  /// How far the edge sticks out under the body.
  final double edgeHeight;

  final EdgeInsetsGeometry padding;

  /// Pushes the body down over its own edge, for a pressed state.
  ///
  /// It moves the body rather than shrinking the box: the footprint has to stay
  /// put, or everything below the button jumps by [sink] on every tap.
  final double sink;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);

    return Container(
      decoration: BoxDecoration(color: edgeShadeOf(color), borderRadius: shape),
      // Reveals the edge: the outer colour only shows below the body.
      padding: EdgeInsets.only(bottom: edgeHeight),
      child: Transform.translate(
        offset: Offset(0, sink),
        child: ClipRRect(
          borderRadius: shape,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(color: color, borderRadius: shape),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A darker sibling of [color], same hue — the slab under a [RaisedBox].
Color edgeShadeOf(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - 0.16).clamp(0.0, 1.0)).toColor();
}
