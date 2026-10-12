import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:mobile/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:mobile/features/feed/domain/entities/activity_page.dart';
import 'package:mocktail/mocktail.dart';

class _Remote extends Mock implements FeedRemoteDataSource {}

Map<String, dynamic> _activity(String id, String type) => {
  'id': id,
  'activity_type': type,
  'user': {'id': 'user-1', 'name': 'Reader'},
  'occurred_at': '2026-10-10T10:00:00Z',
  'payload': <String, dynamic>{},
};

void main() {
  for (final social in [false, true]) {
    for (final onlyRereads in [false, true]) {
      test(
        '${social ? 'social' : 'personal'} feed skips rereads and preserves cursor '
        'when ${onlyRereads ? 'all' : 'some'} items are rereads',
        () async {
          final remote = _Remote();
          final page = (
            items: <dynamic>[
              if (!onlyRereads) _activity('session', 'reading_session'),
              _activity('reread', 'reread_started'),
              if (!onlyRereads) _activity('badge', 'badge_unlocked'),
            ],
            nextCursor: 'next-page',
          );
          if (social) {
            when(
              () => remote.getSocialFeed(cursor: 'previous-page'),
            ).thenAnswer((_) async => page);
          } else {
            when(
              () => remote.getFeed(cursor: 'previous-page'),
            ).thenAnswer((_) async => page);
          }
          final repository = FeedRepositoryImpl(remote);
          final result = social
              ? await repository.getSocialFeed(cursor: 'previous-page')
              : await repository.getFeed(cursor: 'previous-page');

          final parsed = result.fold(
            (failure) => fail('Unexpected failure: $failure'),
            (page) => page,
          );
          expect(parsed, isA<ActivityPage>());
          expect(
            parsed.items.map((activity) => activity.id),
            onlyRereads ? isEmpty : orderedEquals(['session', 'badge']),
          );
          expect(parsed.nextCursor, 'next-page');
        },
      );
    }
  }
}
