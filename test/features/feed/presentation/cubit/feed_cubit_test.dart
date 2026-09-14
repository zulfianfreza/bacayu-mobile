import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';
import 'package:mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:mobile/features/feed/domain/usecases/get_feed.dart';
import 'package:mobile/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile/features/feed/presentation/cubit/feed_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockFeedRepository extends Mock implements FeedRepository {}

// Mirrors FeedCubit's private page-size constant.
const _pageSize = 20;

Activity _activity(String id, DateTime occurredAt) => Activity(
      id: id,
      occurredAt: occurredAt,
      payload: const BadgeActivityPayload(
        badgeName: 'First Step',
        badgeIcon: '🎉',
        badgeDescription: 'Finish your first session',
      ),
    );

List<Activity> _page(int count, DateTime start) => [
      for (var i = 0; i < count; i++) _activity('a$i', start.subtract(Duration(minutes: i))),
    ];

void main() {
  late _MockFeedRepository repository;
  late FeedCubit cubit;

  setUp(() {
    repository = _MockFeedRepository();
    cubit = FeedCubit(GetFeed(repository));
  });

  tearDown(() => cubit.close());

  test('refresh() loads the first page with cursor: null', () async {
    final page1 = _page(_pageSize, DateTime(2026, 1, 10));
    when(() => repository.getFeed(cursor: null)).thenAnswer((_) async => Right(page1));

    await cubit.refresh();

    verify(() => repository.getFeed(cursor: null)).called(1);
    final state = cubit.state as FeedLoaded;
    expect(state.activities, page1);
    expect(state.hasMore, isTrue); // a full page — assume there's more
  });

  test('loadMore() appends to the existing list instead of replacing it',
      () async {
    final page1 = _page(_pageSize, DateTime(2026, 1, 10));
    final page2 = _page(5, DateTime(2026, 1, 9));
    final expectedCursor = page1.last.occurredAt.toIso8601String();

    when(() => repository.getFeed(cursor: null)).thenAnswer((_) async => Right(page1));
    when(() => repository.getFeed(cursor: expectedCursor))
        .thenAnswer((_) async => Right(page2));

    await cubit.refresh();
    await cubit.loadMore();

    verify(() => repository.getFeed(cursor: expectedCursor)).called(1);
    final state = cubit.state as FeedLoaded;
    expect(state.activities, [...page1, ...page2]);
    expect(state.activities.length, _pageSize + 5);
    // page2 is smaller than a full page — no more after this.
    expect(state.hasMore, isFalse);
  });

  test('refresh() after loadMore() resets back to just the first page',
      () async {
    final page1 = _page(_pageSize, DateTime(2026, 1, 10));
    final page2 = _page(5, DateTime(2026, 1, 9));
    final expectedCursor = page1.last.occurredAt.toIso8601String();

    when(() => repository.getFeed(cursor: null)).thenAnswer((_) async => Right(page1));
    when(() => repository.getFeed(cursor: expectedCursor))
        .thenAnswer((_) async => Right(page2));

    await cubit.refresh();
    await cubit.loadMore();
    expect((cubit.state as FeedLoaded).activities.length, _pageSize + 5);

    await cubit.refresh();

    final state = cubit.state as FeedLoaded;
    expect(state.activities, page1);
    expect(state.activities.length, _pageSize);
  });

  test('loadMore() does nothing once hasMore is false', () async {
    final shortPage = _page(3, DateTime(2026, 1, 10));
    when(() => repository.getFeed(cursor: null)).thenAnswer((_) async => Right(shortPage));

    await cubit.refresh();
    expect((cubit.state as FeedLoaded).hasMore, isFalse);

    await cubit.loadMore();

    verifyNever(() => repository.getFeed(cursor: any(named: 'cursor', that: isNotNull)));
    expect((cubit.state as FeedLoaded).activities, shortPage);
  });
}
