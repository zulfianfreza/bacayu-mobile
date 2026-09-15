import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/social/domain/entities/followed_user.dart';
import 'package:mobile/features/social/domain/repositories/social_repository.dart';
import 'package:mobile/features/social/domain/usecases/follow_user.dart';
import 'package:mobile/features/social/domain/usecases/list_followers.dart';
import 'package:mobile/features/social/domain/usecases/list_following.dart';
import 'package:mobile/features/social/domain/usecases/unfollow_user.dart';
import 'package:mobile/features/social/presentation/cubit/follow_cubit.dart';
import 'package:mobile/features/social/presentation/cubit/follow_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSocialRepository extends Mock implements SocialRepository {}

void main() {
  late _MockSocialRepository repository;
  late FollowCubit cubit;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    repository = _MockSocialRepository();
    cubit = FollowCubit(
      ListFollowers(repository),
      ListFollowing(repository),
      FollowUser(repository),
      UnfollowUser(repository),
    );
  });

  tearDown(() => cubit.close());

  test(
      'a self-follow attempt is rejected at the usecase layer, and the '
      "backend's CANNOT_FOLLOW_SELF error maps through to the cubit's state "
      'unchanged', () async {
    // The backend itself refuses this (400/422 CANNOT_FOLLOW_SELF) — the
    // repository mock stands in for that rejection reaching the usecase.
    const failure = ServerFailure(
      code: 'CANNOT_FOLLOW_SELF',
      message: 'cannot follow yourself',
    );
    const me = FollowedUser(id: 'me', name: 'Me', avatarUrl: null, isFollowing: false);

    when(() => repository.listFollowers()).thenAnswer((_) async => const Right([me]));
    when(() => repository.followUser(any())).thenAnswer((_) async => const Left(failure));

    await cubit.loadFollowers();
    await cubit.toggleFollow(me);

    final state = cubit.state as FollowActionError;
    expect(state.failure, failure);
    expect((state.failure as ServerFailure).code, 'CANNOT_FOLLOW_SELF');
    // The list itself is untouched — still not-following, no ghost update.
    expect(state.users.single.isFollowing, isFalse);
    expect(state.pendingUserIds, isEmpty);
  });

  test('toggling still works right after a previous toggle failed (not stuck)',
      () async {
    const other =
        FollowedUser(id: 'u2', name: 'Other', avatarUrl: null, isFollowing: false);

    when(() => repository.listFollowers())
        .thenAnswer((_) async => const Right([other]));
    when(() => repository.followUser(any())).thenAnswer(
      (_) async => const Left(ServerFailure(code: 'CANNOT_FOLLOW_SELF', message: 'x')),
    );

    await cubit.loadFollowers();
    await cubit.toggleFollow(other); // fails, -> FollowActionError
    expect(cubit.state, isA<FollowActionError>());

    when(() => repository.followUser(any())).thenAnswer((_) async => const Right(unit));
    await cubit.toggleFollow(other); // should still work, not blocked

    final state = cubit.state as FollowLoaded;
    expect(state.users.single.isFollowing, isTrue);
  });
}
