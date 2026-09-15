import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:mobile/features/auth/domain/usecases/login.dart';
import 'package:mobile/features/auth/domain/usecases/logout.dart';
import 'package:mobile/features/auth/domain/usecases/register.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:mobile/features/notifications/data/services/push_notification_service.dart';
import 'package:mocktail/mocktail.dart';

// bloc_test's dependency chain (test -> analyzer/matcher) conflicts with
// drift_dev's analyzer pin + flutter_test's matcher pin in this project, so
// state-order assertions here use plain flutter_test `emitsInOrder` instead
// — same guarantee (assert the emitted sequence, not just the final state).

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockPushNotificationService extends Mock implements PushNotificationService {}

void main() {
  late _MockAuthRepository repository;
  late _MockPushNotificationService pushNotificationService;
  late AuthCubit cubit;

  final user = User(
    id: 'u1',
    email: 'reader@bacayu.app',
    name: 'Reader',
    avatarUrl: '',
    timezone: 'UTC',
    favoriteGenres: const [],
    yearlyGoalBooks: null,
    dailyGoalMinutes: null,
    currentStreak: 0,
    longestStreak: 0,
    lastReadDate: null,
    privacyDefault: 'private',
    onboardingCompletedAt: null,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repository = _MockAuthRepository();
    pushNotificationService = _MockPushNotificationService();
    when(() => pushNotificationService.registerAfterLogin())
        .thenAnswer((_) async {});
    cubit = AuthCubit(
      Login(repository),
      Register(repository),
      GetCurrentUser(repository),
      Logout(repository),
      pushNotificationService,
    );
  });

  tearDown(() => cubit.close());

  group('AuthCubit.login', () {
    test('emits [loading, authenticated] when login succeeds', () async {
      when(() => repository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(user));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const AuthLoading(),
          AuthAuthenticated(user),
        ]),
      );

      await cubit.login(email: 'reader@bacayu.app', password: 'password1');
      await expectation;
    });

    test('emits [loading, error(ServerFailure)] on wrong credentials',
        () async {
      when(() => repository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
        (_) async => const Left(
          ServerFailure(
            code: 'INVALID_CREDENTIALS',
            message: 'invalid email or password',
          ),
        ),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const AuthLoading(),
          const AuthError(
            ServerFailure(
              code: 'INVALID_CREDENTIALS',
              message: 'invalid email or password',
            ),
          ),
        ]),
      );

      await cubit.login(email: 'reader@bacayu.app', password: 'wrong');
      await expectation;
    });

    test('emits [loading, error(NetworkFailure)] when offline', () async {
      when(() => repository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(NetworkFailure()));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const AuthLoading(),
          const AuthError(NetworkFailure()),
        ]),
      );

      await cubit.login(email: 'reader@bacayu.app', password: 'password1');
      await expectation;
    });
  });
}
