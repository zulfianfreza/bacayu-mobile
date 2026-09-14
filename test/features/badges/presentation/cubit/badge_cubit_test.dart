import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/badges/domain/entities/badge.dart';
import 'package:mobile/features/badges/domain/repositories/badge_repository.dart';
import 'package:mobile/features/badges/domain/usecases/get_all_badges.dart';
import 'package:mobile/features/badges/presentation/cubit/badge_cubit.dart';
import 'package:mobile/features/badges/presentation/cubit/badge_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockBadgeRepository extends Mock implements BadgeRepository {}

List<Badge> _badges() => [
      Badge(
        id: 'b1',
        name: 'First Step',
        icon: '🎉',
        description: 'Finish your first session',
        imageUrl: null,
        unlocked: true,
        unlockedAt: DateTime(2026, 1, 1),
      ),
      const Badge(
        id: 'b2',
        name: 'Bookworm',
        icon: '📚',
        description: 'Finish 10 books',
        imageUrl: null,
        unlocked: false,
        unlockedAt: null,
      ),
    ];

void main() {
  late _MockBadgeRepository repository;
  late BadgeCubit cubit;

  setUp(() {
    repository = _MockBadgeRepository();
    cubit = BadgeCubit(GetAllBadges(repository));
  });

  tearDown(() => cubit.close());

  test('emits [loading, loaded] with all badges on success', () async {
    final badges = _badges();
    when(() => repository.getAllBadges()).thenAnswer((_) async => Right(badges));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const BadgeLoading(),
        BadgeLoaded(badges),
      ]),
    );

    await cubit.load();
    await expectation;
  });

  test('emits [loading, error] when the repository fails', () async {
    when(() => repository.getAllBadges())
        .thenAnswer((_) async => const Left(NetworkFailure()));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const BadgeLoading(),
        const BadgeError(NetworkFailure()),
      ]),
    );

    await cubit.load();
    await expectation;
  });
}
