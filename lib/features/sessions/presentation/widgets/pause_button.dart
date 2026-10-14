import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/session_timer_theme.dart';

class PauseButton extends StatelessWidget {
  const PauseButton({
    super.key,
    required this.paused,
    required this.label,
    required this.onPressed,
  });
  final bool paused;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    tooltip: label,
    style: IconButton.styleFrom(
      backgroundColor: SessionTimerTheme.white,
      foregroundColor: SessionTimerTheme.background,
      fixedSize: const Size.square(SessionTimerTheme.pauseSize),
    ),
    iconSize: SessionTimerTheme.iconSize,
    icon: Icon(paused ? Icons.play_arrow : Icons.pause),
    onPressed: () {
      HapticFeedback.lightImpact();
      onPressed();
    },
  );
}
