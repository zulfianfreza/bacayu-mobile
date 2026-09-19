import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/social/domain/entities/followed_user.dart';
import 'package:mobile/features/social/domain/entities/user_search_results.dart';
import 'package:mobile/features/social/domain/repositories/social_repository.dart';
import 'package:mobile/features/social/domain/usecases/follow_user.dart';
import 'package:mobile/features/social/domain/usecases/search_users.dart';
import 'package:mobile/features/social/domain/usecases/unfollow_user.dart';
import 'package:mobile/features/social/presentation/cubit/user_search_bloc.dart';
import 'package:mobile/features/social/presentation/cubit/user_search_event.dart';
import 'package:mobile/features/social/presentation/cubit/user_search_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSocialRepository extends Mock implements SocialRepository {}

const _failure = ServerFailure(code: 'BOOM', message: 'boom');

FollowedUser _user({
  String id = 'u1',
  String name = 'Maya',
  bool isFollowing = false,
}) => FollowedUser(
  id: id,
  name: name,
  avatarUrl: null,
  isFollowing: isFollowing,
  isFollowedBy: false,
);

UserSearchResults _page(
  List<FollowedUser> users, {
  int page = 1,
  int totalPages = 1,
}) => UserSearchResults(users: users, page: page, totalPages: totalPages);

void main() {
  late _MockSocialRepository repository;
  late UserSearchBloc bloc;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    repository = _MockSocialRepository();
    bloc = UserSearchBloc(
      SearchUsers(repository),
      FollowUser(repository),
      UnfollowUser(repository),
    );
  });

  tearDown(() => bloc.close());

  /// Types [query] and waits out the bloc's debounce window.
  Future<void> search(String query) async {
    bloc.add(UserSearchQueryChanged(query));
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  test('a one-letter query never reaches the API', () async {
    await search('m');

    expect(bloc.state, isA<UserSearchInitial>());
    verifyNever(
      () => repository.searchUsers(
        query: any(named: 'query'),
        page: any(named: 'page'),
      ),
    );
  });

  test('rapid keystrokes search once, for the last query', () async {
    when(
      () => repository.searchUsers(
        query: any(named: 'query'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => Right(_page([_user()])));

    bloc
      ..add(const UserSearchQueryChanged('ma'))
      ..add(const UserSearchQueryChanged('may'))
      ..add(const UserSearchQueryChanged('maya'));

    await Future<void>.delayed(const Duration(milliseconds: 600));

    verify(() => repository.searchUsers(query: 'maya', page: 1)).called(1);
    verifyNever(() => repository.searchUsers(query: 'ma', page: 1));
  });

  test('results land as a page of users', () async {
    when(() => repository.searchUsers(query: 'maya', page: 1))
        .thenAnswer((_) async => Right(_page([_user()])));

    await search('maya');

    final state = bloc.state as UserSearchLoaded;
    expect(state.users.single.name, 'Maya');
    expect(state.page, 1);
    expect(state.hasMore, isFalse);
  });

  test('loadMore appends the next page, and stops at the last one', () async {
    when(() => repository.searchUsers(query: 'maya', page: 1)).thenAnswer(
      (_) async => Right(_page([_user(id: 'u1')], totalPages: 2)),
    );
    when(() => repository.searchUsers(query: 'maya', page: 2)).thenAnswer(
      (_) async => Right(_page([_user(id: 'u2')], page: 2, totalPages: 2)),
    );

    await search('maya');
    expect((bloc.state as UserSearchLoaded).hasMore, isTrue);

    bloc.add(const UserSearchLoadMore());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = bloc.state as UserSearchLoaded;
    expect(state.users.map((u) => u.id), ['u1', 'u2']);
    expect(state.hasMore, isFalse);

    bloc.add(const UserSearchLoadMore());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    verifyNever(() => repository.searchUsers(query: 'maya', page: 3));
  });

  test('following a result flips it, leaving the rest alone', () async {
    when(() => repository.searchUsers(query: 'maya', page: 1))
        .thenAnswer((_) async => Right(_page([_user()])));
    // Held open so the in-flight "pending" state can actually be observed.
    final followCall = Completer<Either<Failure, Unit>>();
    when(() => repository.followUser(any()))
        .thenAnswer((_) => followCall.future);

    await search('maya');
    bloc.add(
      UserSearchFollowToggled((bloc.state as UserSearchLoaded).users.single),
    );
    await Future<void>.delayed(Duration.zero);

    // Pending while the request is in flight, so only that row spins.
    expect((bloc.state as UserSearchLoaded).pendingUserIds, {'u1'});

    followCall.complete(const Right(unit));
    await Future<void>.delayed(Duration.zero);

    final state = bloc.state as UserSearchLoaded;
    expect(state.users.single.isFollowing, isTrue);
    expect(state.pendingUserIds, isEmpty);
    verify(() => repository.followUser('u1')).called(1);
  });

  test('an already-followed result calls unfollow', () async {
    when(() => repository.searchUsers(query: 'maya', page: 1))
        .thenAnswer((_) async => Right(_page([_user(isFollowing: true)])));
    when(() => repository.unfollowUser(any()))
        .thenAnswer((_) async => const Right(unit));

    await search('maya');
    bloc.add(UserSearchFollowToggled((bloc.state as UserSearchLoaded).users.single));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect((bloc.state as UserSearchLoaded).users.single.isFollowing, isFalse);
    verify(() => repository.unfollowUser('u1')).called(1);
    verifyNever(() => repository.followUser(any()));
  });

  test('a failed toggle keeps the row as it was and reports it', () async {
    when(() => repository.searchUsers(query: 'maya', page: 1))
        .thenAnswer((_) async => Right(_page([_user()])));
    when(() => repository.followUser(any()))
        .thenAnswer((_) async => const Left(_failure));

    await search('maya');
    bloc.add(UserSearchFollowToggled((bloc.state as UserSearchLoaded).users.single));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = bloc.state as UserSearchActionError;
    expect(state.failure, _failure);
    expect(state.users.single.isFollowing, isFalse);
    expect(state.pendingUserIds, isEmpty);
  });

  test('a failed search reports the failure instead of an empty list', () async {
    when(() => repository.searchUsers(query: 'maya', page: 1))
        .thenAnswer((_) async => const Left(_failure));

    await search('maya');

    expect(bloc.state, isA<UserSearchError>());
  });
}
