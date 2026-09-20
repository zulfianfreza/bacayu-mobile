import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// What every sheet in the app opens with: the drag indicator, and the title
/// centred under it.
///
/// Shared rather than repeated per sheet on purpose — the indicator is what
/// tells someone the surface can be dragged down, so a sheet without one reads
/// as a different kind of surface, and the centred title is what makes the
/// sheets look like one family instead of several.
class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key, this.title, this.subtitle});

  /// `null` only for a sheet whose content already names itself (the barcode
  /// scan result shows the book it found, so a title above it would just repeat
  /// the card below).
  final String? title;

  /// Optional second line, centred like the title.
  final String? subtitle;

  /// Wide enough to read as a grabber rather than as a divider.
  static const handleWidth = 40.0;
  static const handleHeight = 4.0;

  @override
  Widget build(BuildContext context) {
    // Full width regardless of how short the title is: the indicator centres
    // over the *sheet*, not over the text above it.
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: handleWidth,
            height: handleHeight,
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(height: 16),
          if (title != null)
            Text(
              title!,
              textAlign: TextAlign.center,
              style: AppTypography.heading,
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
          ],
        ],
      ),
    );
  }
}
