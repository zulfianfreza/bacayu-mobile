import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../cubit/onboarding_state.dart';
import '../../../../core/theme/build_context_extension.dart';

/// How far along the flow is: one pill per step, the current one stretched and
/// filled. The rest are slate rather than the warm hairline — a white page
/// wants a cool neutral.
class OnboardingProgressDots extends StatelessWidget {
  const OnboardingProgressDots({super.key, required this.step});

  final OnboardingStep step;

  static const _height = 8.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final s in OnboardingStep.values) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: s == step ? 28 : 8,
            height: _height,
            decoration: BoxDecoration(
              color: s == step ? AppColors.tangerine : context.colors.hairline,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          if (s != OnboardingStep.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
