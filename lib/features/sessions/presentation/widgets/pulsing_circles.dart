import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/session_timer_theme.dart';

class PulsingCircles extends StatefulWidget {
  const PulsingCircles({super.key, required this.paused, required this.label});
  final bool paused;
  final String label;

  @override
  State<PulsingCircles> createState() => _PulsingCirclesState();
}

class _PulsingCirclesState extends State<PulsingCircles>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: SessionTimerTheme.pulse,
  );
  bool get _reduceMotion =>
      MediaQuery.disableAnimationsOf(context) ||
      MediaQuery.accessibleNavigationOf(context);

  void _sync() {
    if (widget.paused || _reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant PulsingCircles oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: _CirclesPainter(_reduceMotion ? 0 : _controller.value),
        child: child,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SessionTimerTheme.padding),
          child: AnimatedSwitcher(
            duration: _reduceMotion ? Duration.zero : SessionTimerTheme.fade,
            child: Text(
              widget.label,
              key: ValueKey(widget.label),
              textAlign: TextAlign.center,
              style: SessionTimerTheme.status,
            ),
          ),
        ),
      ),
    ),
  );
}

class _CirclesPainter extends CustomPainter {
  const _CirclesPainter(this.phase);
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (var layer = 0; layer < SessionTimerTheme.layers.length; layer++) {
      final wave = (1 - math.cos((phase - layer * 0.12) * math.pi * 2)) / 2;
      final pulse = Curves.easeInOut.transform(wave);
      final radius =
          size.shortestSide * (0.44 - layer * 0.055) * (1 + 0.08 * pulse);
      final path = Path();
      for (var step = 0; step <= 120; step++) {
        final angle = step / 120 * math.pi * 2;
        final organicRadius =
            radius * (1 + 0.025 * math.sin(angle * 3 + layer * 0.7));
        final point =
            center + Offset(math.cos(angle), math.sin(angle)) * organicRadius;
        if (step == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(
        path..close(),
        Paint()
          ..color = SessionTimerTheme.layers[layer].withValues(
            alpha: 0.88 + pulse * 0.12,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CirclesPainter oldDelegate) =>
      phase != oldDelegate.phase;
}
