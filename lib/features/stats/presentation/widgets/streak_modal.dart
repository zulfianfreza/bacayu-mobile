import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/build_context_extension.dart';
import '../../../../core/widgets/chunky_button.dart';

class StreakModal extends StatefulWidget {
  const StreakModal({super.key, required this.current, required this.longest});

  final int current;
  final int longest;

  static Future<void> show(
    BuildContext context, {
    required int current,
    required int longest,
  }) => showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, _, _) => StreakModal(current: current, longest: longest),
    transitionBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );

  @override
  State<StreakModal> createState() => _StreakModalState();
}

class _StreakModalState extends State<StreakModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _scale = Tween(
    begin: 0.7,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _scale,
                          child: Image.asset(
                            'assets/images/state-streak.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.streakExtendedTitle,
                          style: AppTypography.heading,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.current}',
                          style: AppTypography.displayLg,
                        ),
                        Text(l10n.dayStreak, style: context.captionStyle),
                        const SizedBox(height: 12),
                        Text(
                          l10n.longestStreakDays(widget.longest),
                          style: context.captionStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: l10n.awesome,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
