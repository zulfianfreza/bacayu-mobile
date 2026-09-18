import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'raised_box.dart';

enum ChunkyButtonVariant {
  /// The one action a screen is for.
  primary,

  /// Everything else that is still a button.
  secondary,
}

/// A chunky, pressable tile — the app's action surface, built the way Duolingo
/// builds its buttons.
///
/// It sits on a solid edge and sinks onto it while held, which is what makes
/// the tap feel physical. The body moves; the button's footprint never does, so
/// nothing below it shifts when a finger lands.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ChunkyButtonVariant.primary,
    this.isLoading = false,
  });

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;

  final Widget? icon;
  final ChunkyButtonVariant variant;

  /// Swaps the label for a spinner without changing the button's size.
  final bool isLoading;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  static const _edge = 4.0;

  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final (fill, foreground) = switch (widget.variant) {
      ChunkyButtonVariant.primary => (AppColors.tangerine, Colors.white),
      ChunkyButtonVariant.secondary => (AppColors.surface, AppColors.ink),
    };
    // Disabled keeps the shape but drops the colour, so a form never reflows
    // the moment its submit starts.
    final (body, label) = _enabled
        ? (fill, foreground)
        : (AppColors.line, AppColors.inkFaint);

    return GestureDetector(
      onTap: _enabled ? widget.onPressed : null,
      onTapDown: _enabled ? (_) => _setPressed(true) : null,
      onTapUp: _enabled ? (_) => _setPressed(false) : null,
      onTapCancel: _enabled ? () => _setPressed(false) : null,
      child: RaisedBox(
        color: body,
        radius: AppRadius.md,
        edgeHeight: _edge,
        // The whole 4px edge while held would leave nothing to sink into, so
        // the body covers all but 1px of it.
        sink: _pressed ? _edge - 1 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: label),
              )
            else ...[
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: AppTypography.button.copyWith(color: label),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
