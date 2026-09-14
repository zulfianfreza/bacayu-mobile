import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../auth/domain/usecases/complete_onboarding.dart';
import '../../../auth/domain/usecases/update_profile.dart';
import 'onboarding_state.dart';

/// Onboarding has no domain/data of its own — it's presentation-only
/// orchestration over `auth` (UpdateProfile, CompleteOnboarding). Adding a
/// book (step 3) composes `books`/`shelf` usecases directly in the widgets,
/// not through this cubit — see `OnboardingAddFirstBookStep`.
@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._updateProfile, this._completeOnboarding)
      : super(const OnboardingIdle(OnboardingStep.welcome));

  final UpdateProfile _updateProfile;
  final CompleteOnboarding _completeOnboarding;

  void goToPreferences() => emit(const OnboardingIdle(OnboardingStep.preferences));

  Future<void> submitPreferences({
    required List<String> favoriteGenres,
    required int yearlyGoalBooks,
  }) async {
    emit(const OnboardingSaving(OnboardingStep.preferences));
    final result = await _updateProfile(
      favoriteGenres: favoriteGenres,
      yearlyGoalBooks: yearlyGoalBooks,
    );
    result.fold(
      (failure) => emit(OnboardingError(OnboardingStep.preferences, failure)),
      (_) => emit(const OnboardingIdle(OnboardingStep.addFirstBook)),
    );
  }

  /// Called after a book was added (or the user skipped) — either way,
  /// step 3 is done.
  Future<void> finish() async {
    emit(const OnboardingSaving(OnboardingStep.addFirstBook));
    final result = await _completeOnboarding();
    result.fold(
      (failure) => emit(OnboardingError(OnboardingStep.addFirstBook, failure)),
      (_) => emit(const OnboardingFinished()),
    );
  }
}
