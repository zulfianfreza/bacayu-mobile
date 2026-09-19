import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';
import 'package:mobile/features/feed/domain/entities/activity_page.dart';
import 'package:mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:mobile/features/feed/domain/usecases/get_social_feed.dart';
import 'package:mobile/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile/features/feed/presentation/cubit/feed_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockFeedRepository extends Mock implements FeedRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

User _user() => User(
  id: 'viewer',
  email: 'reader@bacayu.app',
  name: 'Julian',
  avatarUrl: '',
  timezone: 'UTC',
  favoriteGenres: const [],
  yearlyGoalBooks: null,
  dailyGoalMinutes: null,
  currentStreak: 0,
  longestStreak: 0,
  lastReadDate: null,
  privacyDefault: 'private',
  onboardingCompletedAt: DateTime(2026, 1, 1),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

Activity _activity(String id, DateTime occurredAt) => Activity(
  id: id,
  author: const ActivityAuthor(
    id: 'someone-else',
    name: 'Someone Else',
    avatarUrl: null,
  ),
  occurredAt: occurredAt,
  payload: const BadgeActivityPayload(
    badgeName: 'First Step',
    badgeIcon: '🎉',
    badgeDescription: 'Finish your first session',
  ),
  likeCount: 0,
  commentCount: 0,
  isLiked: false,
);

List<Activity> _items(int count, DateTime start) => [
  for (var i = 0; i < count; i++)
    _activity('a$i', start.subtract(Duration(minutes: i))),
];

void main() {
  late _MockFeedRepository repository;
  late _MockAuthRepository authRepository;
  late FeedCubit cubit;

  setUp(() {
    repository = _MockFeedRepository();
    authRepository = _MockAuthRepository();
    when(
      () => authRepository.getCurrentUser(),
    ).thenAnswer((_) async => Right(_user()));
    cubit = FeedCubit(
      GetSocialFeed(repository),
      GetCurrentUser(authRepository),
    );
  });

  tearDown(() => cubit.close());

  test('refresh() loads the first page with cursor: null', () async {
    final page1 = _items(20, DateTime(2026, 1, 10));
    when(() => repository.getSocialFeed(cursor: null)).thenAnswer(
      (_) async => Right(ActivityPage(items: page1, nextCursor: 'c1')),
    );

    await cubit.refresh();

    verify(() => repository.getSocialFeed(cursor: null)).called(1);
    final state = cubit.state as FeedLoaded;
    expect(state.activities, page1);
    // hasMore comes from the server's next_cursor, not from item count.
    expect(state.hasMore, isTrue);
    expect(state.cursor, 'c1');
    expect(state.viewerId, 'viewer');
  });

  test('a null next_cursor means there is no further page', () async {
    final page1 = _items(3, DateTime(2026, 1, 10));
    when(() => repository.getSocialFeed(cursor: null)).thenAnswer(
      (_) async => Right(ActivityPage(items: page1, nextCursor: null)),
    );

    await cubit.refresh();

    final state = cubit.state as FeedLoaded;
    expect(state.hasMore, isFalse);
    expect(state.cursor, isNull);
  });

  test(
    'loadMore() appends to the existing list, using the server cursor',
    () async {
      final page1 = _items(20, DateTime(2026, 1, 10));
      final page2 = _items(5, DateTime(2026, 1, 9));

      when(() => repository.getSocialFeed(cursor: null)).thenAnswer(
        (_) async => Right(ActivityPage(items: page1, nextCursor: 'c1')),
      );
      when(() => repository.getSocialFeed(cursor: 'c1')).thenAnswer(
        (_) async => Right(ActivityPage(items: page2, nextCursor: null)),
      );

      await cubit.refresh();
      await cubit.loadMore();

      verify(() => repository.getSocialFeed(cursor: 'c1')).called(1);
      final state = cubit.state as FeedLoaded;
      expect(state.activities, [...page1, ...page2]);
      expect(state.hasMore, isFalse);
    },
  );

  test(
    'refresh() after loadMore() resets back to just the first page',
    () async {
      final page1 = _items(20, DateTime(2026, 1, 10));
      final page2 = _items(5, DateTime(2026, 1, 9));

      when(() => repository.getSocialFeed(cursor: null)).thenAnswer(
        (_) async => Right(ActivityPage(items: page1, nextCursor: 'c1')),
      );
      when(() => repository.getSocialFeed(cursor: 'c1')).thenAnswer(
        (_) async => Right(ActivityPage(items: page2, nextCursor: null)),
      );

      await cubit.refresh();
      await cubit.loadMore();
      expect((cubit.state as FeedLoaded).activities, hasLength(25));

      await cubit.refresh();

      final state = cubit.state as FeedLoaded;
      expect(state.activities, page1);
    },
  );

  test('loadMore() does nothing once there is no next cursor', () async {
    final shortPage = _items(3, DateTime(2026, 1, 10));
    when(() => repository.getSocialFeed(cursor: null)).thenAnswer(
      (_) async => Right(ActivityPage(items: shortPage, nextCursor: null)),
    );

    await cubit.refresh();
    expect((cubit.state as FeedLoaded).hasMore, isFalse);

    await cubit.loadMore();

    verifyNever(
      () => repository.getSocialFeed(
        cursor: any(named: 'cursor', that: isNotNull),
      ),
    );
    expect((cubit.state as FeedLoaded).activities, shortPage);
  });
}
