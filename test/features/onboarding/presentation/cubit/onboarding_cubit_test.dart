import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/complete_onboarding.dart';
import 'package:mobile/features/auth/domain/usecases/update_profile.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

User _user({DateTime? onboardingCompletedAt}) => User(
      id: 'u1',
      email: 'reader@bacayu.app',
      name: 'Reader',
      avatarUrl: '',
      timezone: 'UTC',
      favoriteGenres: const ['fiction'],
      yearlyGoalBooks: 12,
      dailyGoalMinutes: null,
      currentStreak: 0,
      longestStreak: 0,
      lastReadDate: null,
      privacyDefault: 'private',
      onboardingCompletedAt: onboardingCompletedAt,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  late _MockAuthRepository repository;
  late OnboardingCubit cubit;

  setUp(() {
    repository = _MockAuthRepository();
    cubit = OnboardingCubit(
      UpdateProfile(repository),
      CompleteOnboarding(repository),
    );
  });

  tearDown(() => cubit.close());

  test('submitPreferences success advances to the add-first-book step',
      () async {
    when(() => repository.updateProfile(
          favoriteGenres: any(named: 'favoriteGenres'),
          yearlyGoalBooks: any(named: 'yearlyGoalBooks'),
          dailyGoalMinutes: any(named: 'dailyGoalMinutes'),
          timezone: any(named: 'timezone'),
        )).thenAnswer((_) async => Right(_user()));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const OnboardingSaving(OnboardingStep.preferences),
        const OnboardingIdle(OnboardingStep.addFirstBook),
      ]),
    );

    await cubit.submitPreferences(
      favoriteGenres: const ['fiction'],
      yearlyGoalBooks: 12,
    );
    await expectation;
  });

  test('submitPreferences failure stays on the preferences step with an error',
      () async {
    when(() => repository.updateProfile(
          favoriteGenres: any(named: 'favoriteGenres'),
          yearlyGoalBooks: any(named: 'yearlyGoalBooks'),
          dailyGoalMinutes: any(named: 'dailyGoalMinutes'),
          timezone: any(named: 'timezone'),
        )).thenAnswer((_) async => const Left(NetworkFailure()));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const OnboardingSaving(OnboardingStep.preferences),
        const OnboardingError(OnboardingStep.preferences, NetworkFailure()),
      ]),
    );

    await cubit.submitPreferences(
      favoriteGenres: const ['fiction'],
      yearlyGoalBooks: 12,
    );
    await expectation;
  });

  test('finish success emits OnboardingFinished', () async {
    when(() => repository.completeOnboarding()).thenAnswer(
      (_) async => Right(_user(onboardingCompletedAt: DateTime(2026, 1, 2))),
    );

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const OnboardingSaving(OnboardingStep.addFirstBook),
        const OnboardingFinished(),
      ]),
    );

    await cubit.finish();
    await expectation;
  });
}
