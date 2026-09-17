import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/error_listener.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_add_first_book_step.dart';
import '../widgets/onboarding_preferences_step.dart';
import '../widgets/onboarding_progress_dots.dart';
import '../widgets/onboarding_welcome_step.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OnboardingCubit, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingFinished) {
              context.go(AppRoutes.home);
            } else if (state is OnboardingError) {
              context.showFailureSnackBar(state.failure);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 16),
                OnboardingProgressDots(step: state.step),
                const SizedBox(height: 8),
                Expanded(
                  child: switch (state.step) {
                    OnboardingStep.welcome => OnboardingWelcomeStep(
                        onGetStarted: () =>
                            context.read<OnboardingCubit>().goToPreferences(),
                      ),
                    OnboardingStep.preferences => OnboardingPreferencesStep(
                        isSaving: state is OnboardingSaving,
                        onSubmit: (genres, yearlyGoal) => context
                            .read<OnboardingCubit>()
                            .submitPreferences(
                              favoriteGenres: genres,
                              yearlyGoalBooks: yearlyGoal,
                            ),
                      ),
                    OnboardingStep.addFirstBook => OnboardingAddFirstBookStep(
                        onDone: () => context.read<OnboardingCubit>().finish(),
                        onSkip: () => context.read<OnboardingCubit>().finish(),
                      ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
