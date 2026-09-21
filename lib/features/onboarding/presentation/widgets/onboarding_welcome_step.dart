import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/theme/build_context_extension.dart';

/// Screen 1: the promise, the illustration, and one way forward.
class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({super.key, required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 216,
                height: 216,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.tangerineTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  size: 96,
                  color: AppColors.tangerine500,
                ),
              ),
            ),
          ),
          Text(
            l10n.onboardingWelcomeHeadline,
            style: AppTypography.displaySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingWelcomeBody,
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ChunkyButton(label: l10n.getStarted, onPressed: onGetStarted),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
