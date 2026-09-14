import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/onboarding_state.dart';

class OnboardingProgressDots extends StatelessWidget {
  const OnboardingProgressDots({super.key, required this.step});

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final s in OnboardingStep.values) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: s == step ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: s == step ? AppColors.tangerine500 : AppColors.line,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (s != OnboardingStep.values.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
