import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

/// A box with a solid slab underneath it.
///
/// A flat filled rectangle reads as decoration; a darker edge under the body
/// makes the tile read as a physical object you could press. The edge is
/// derived from [color] — same hue, one step darker — so a caller only ever
/// passes one palette colour.
///
/// That recipe needs the body to contrast with what it sits on. When it does
/// not — a white body on a white sheet — pass [outlineColor] instead: the box
/// is then drawn as an outlined surface, the same recipe as `BorderedCard`
/// (hairline on top and sides, a thicker base), which is what keeps the sides
/// from disappearing while keeping the pressable base.
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
    this.outlineColor,
  });

  /// The body colour. The edge is [edgeShadeOf] this — unless [outlineColor]
  /// is set, in which case that colour is the whole edge.
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

  /// Optional outline colour. When set, the box is drawn as an outlined
  /// surface — top and sides at [outlineWidth], base at [edgeHeight], all in
  /// this colour — instead of a slab derived from [color].
  ///
  /// For a body that would otherwise blend into its backing (the secondary
  /// button on a white sheet, either mode's neutral button on a matching
  /// surface).
  final Color? outlineColor;

  /// Hairline around the sides and top in outline mode. Matches
  /// `BorderedCard.sideWidth` so the two read as one family.
  static const outlineWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    final outline = outlineColor;

    return Container(
      // The edge: the whole outline colour in outline mode (only its bottom
      // strip stays visible), a shade of the body otherwise.
      decoration: BoxDecoration(
        color: outline ?? edgeShadeOf(color),
        borderRadius: shape,
      ),
      // Reveals the edge: the outer colour only shows below the body.
      padding: EdgeInsets.only(bottom: edgeHeight),
      child: Transform.translate(
        offset: Offset(0, sink),
        child: ClipRRect(
          borderRadius: shape,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: shape,
              // Sides and top only: the base is the strip the outer colour
              // shows through, and drawing it twice would double the line.
              border: outline == null
                  ? null
                  : Border(
                      top: BorderSide(color: outline, width: outlineWidth),
                      left: BorderSide(color: outline, width: outlineWidth),
                      right: BorderSide(color: outline, width: outlineWidth),
                    ),
            ),
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
