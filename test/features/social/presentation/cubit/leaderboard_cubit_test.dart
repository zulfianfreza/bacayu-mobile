import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/social/domain/entities/leaderboard_entry.dart';
import 'package:mobile/features/social/domain/repositories/social_repository.dart';
import 'package:mobile/features/social/domain/usecases/get_leaderboard.dart';
import 'package:mobile/features/social/presentation/cubit/leaderboard_cubit.dart';
import 'package:mobile/features/social/presentation/cubit/leaderboard_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSocialRepository extends Mock implements SocialRepository {}

LeaderboardEntry _entry(String userId, int rank) => LeaderboardEntry(
      userId: userId,
      name: 'User $userId',
      avatarUrl: null,
      totalPages: 100 - rank,
      totalMinutes: 500 - rank * 10,
      rank: rank,
    );

void main() {
  late _MockSocialRepository repository;
  late LeaderboardCubit cubit;

  setUpAll(() {
    registerFallbackValue(LeaderboardRange.week);
  });

  setUp(() {
    repository = _MockSocialRepository();
    cubit = LeaderboardCubit(GetLeaderboard(repository));
  });

  tearDown(() => cubit.close());

  test(
      "the requester's own entry is kept in state even when it's outside "
      'the top-N entries the backend returned', () async {
    // Backend behavior: `entries` is capped to the requested top N, but
    // `current_user` is always populated separately — rank 47 here, well
    // outside a top-10 list.
    final topEntries = [for (var i = 1; i <= 10; i++) _entry('u$i', i)];
    final myEntry = _entry('me', 47);

    when(() => repository.getLeaderboard(any())).thenAnswer(
      (_) async => Right(LeaderboardResult(entries: topEntries, currentUser: myEntry)),
    );

    await cubit.load();

    final state = cubit.state as LeaderboardLoaded;
    expect(state.entries, topEntries);
    expect(state.entries.any((e) => e.userId == 'me'), isFalse);
    expect(state.currentUser, myEntry);
    expect(state.currentUser!.rank, 47);
  });

  test('current user is also reflected correctly when they ARE in the top N',
      () async {
    final topEntries = [for (var i = 1; i <= 5; i++) _entry('u$i', i)];
    final myEntry = topEntries[2]; // rank 3, inside the top N

    when(() => repository.getLeaderboard(any())).thenAnswer(
      (_) async => Right(LeaderboardResult(entries: topEntries, currentUser: myEntry)),
    );

    await cubit.load();

    final state = cubit.state as LeaderboardLoaded;
    expect(state.entries.any((e) => e.userId == myEntry.userId), isTrue);
    expect(state.currentUser, myEntry);
  });

  test('changeRange re-fetches with the new range', () async {
    when(() => repository.getLeaderboard(any())).thenAnswer(
      (_) async => const Right(LeaderboardResult(entries: [], currentUser: null)),
    );

    await cubit.changeRange(LeaderboardRange.month);

    verify(() => repository.getLeaderboard(LeaderboardRange.month)).called(1);
    expect(cubit.state.range, LeaderboardRange.month);
  });
}
