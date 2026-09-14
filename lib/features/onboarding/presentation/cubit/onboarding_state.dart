import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';

enum OnboardingStep { welcome, preferences, addFirstBook }

sealed class OnboardingState extends Equatable {
  const OnboardingState(this.step);

  final OnboardingStep step;

  @override
  List<Object?> get props => [step];
}

class OnboardingIdle extends OnboardingState {
  const OnboardingIdle(super.step);
}

/// Awaiting `UpdateProfile` (preferences step) or `CompleteOnboarding`
/// (add-first-book step).
class OnboardingSaving extends OnboardingState {
  const OnboardingSaving(super.step);
}

class OnboardingError extends OnboardingState {
  const OnboardingError(super.step, this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [step, failure];
}

/// Onboarding is done (`onboarding_completed_at` set) — the page listens
/// for this and navigates to home.
class OnboardingFinished extends OnboardingState {
  const OnboardingFinished() : super(OnboardingStep.addFirstBook);
}
