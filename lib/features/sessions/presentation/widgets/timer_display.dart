import 'package:flutter/material.dart';
import '../../../../core/theme/session_timer_theme.dart';
import '../../../../core/utils/duration_formatter.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key, required this.elapsed});
  final Duration elapsed;

  @override
  Widget build(BuildContext context) => Text(
    formatSessionDuration(elapsed),
    style: SessionTimerTheme.timer,
    textAlign: TextAlign.center,
  );
}
