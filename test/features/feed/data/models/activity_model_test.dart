import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/feed/data/models/activity_model.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';

/// The nested author every feed item carries.
const _userJson = {
  'id': 'user-1',
  'name': 'Julian',
  'avatar_url': 'https://example.com/avatar.jpg',
};

void main() {
  group('ActivityModel.fromJson', () {
    test(
      'activity_type "reading_session" parses into SessionActivityPayload',
      () {
        final json = {
          'id': 'act-1',
          'user': _userJson,
          'activity_type': 'reading_session',
          'reference_id': 'session-1',
          'occurred_at': '2026-01-10T09:30:00Z',
          'payload': {
            'book_title': 'Atomic Habits',
            'book_cover_url': 'https://example.com/cover.jpg',
            'pages_read': 25,
            'speed_ppm': 1.5,
            'active_duration_seconds': 900,
          },
        };

        final activity = ActivityModel.fromJson(json);

        expect(activity.id, 'act-1');
        expect(activity.occurredAt, DateTime.parse('2026-01-10T09:30:00Z'));
        expect(activity.payload, isA<SessionActivityPayload>());

        final payload = activity.payload as SessionActivityPayload;
        expect(payload.bookTitle, 'Atomic Habits');
        expect(payload.bookCoverUrl, 'https://example.com/cover.jpg');
        expect(payload.pagesRead, 25);
        expect(payload.speedPpm, 1.5);
        expect(payload.activeDurationSeconds, 900);
      },
    );

    test('activity_type "badge_unlocked" parses into BadgeActivityPayload', () {
      final json = {
        'id': 'act-2',
        'user': _userJson,
        'activity_type': 'badge_unlocked',
        'reference_id': 'user-badge-1',
        'occurred_at': '2026-01-10T10:00:00Z',
        'payload': {
          'badge_name': 'First Step',
          'badge_icon': '🎉',
          'badge_description': 'Finish your first session',
        },
      };

      final activity = ActivityModel.fromJson(json);

      expect(activity.payload, isA<BadgeActivityPayload>());

      final payload = activity.payload as BadgeActivityPayload;
      expect(payload.badgeName, 'First Step');
      expect(payload.badgeIcon, '🎉');
      expect(payload.badgeDescription, 'Finish your first session');
    });

    test('the nested user becomes the activity author', () {
      final json = {
        'id': 'act-5',
        'user': _userJson,
        'activity_type': 'badge_unlocked',
        'reference_id': 'user-badge-1',
        'occurred_at': '2026-01-10T10:00:00Z',
        'payload': <String, dynamic>{},
      };

      final activity = ActivityModel.fromJson(json);

      expect(activity.author.id, 'user-1');
      expect(activity.author.name, 'Julian');
      expect(activity.author.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('a null avatar_url parses to null, not an empty string', () {
      final json = {
        'id': 'act-6',
        'user': const {'id': 'user-2', 'name': 'Anon', 'avatar_url': null},
        'activity_type': 'badge_unlocked',
        'reference_id': 'ref',
        'occurred_at': '2026-01-10T10:00:00Z',
        'payload': <String, dynamic>{},
      };

      expect(ActivityModel.fromJson(json).author.avatarUrl, isNull);
    });

    test(
      'reading_session payload never gets parsed as BadgeActivityPayload',
      () {
        final json = {
          'id': 'act-3',
          'user': _userJson,
          'activity_type': 'reading_session',
          'reference_id': 'session-2',
          'occurred_at': '2026-01-10T09:30:00Z',
          'payload': {
            'book_title': 'Deep Work',
            'book_cover_url': null,
            'pages_read': 10,
            'speed_ppm': 0.8,
            'active_duration_seconds': 600,
          },
        };

        final activity = ActivityModel.fromJson(json);

        expect(activity.payload, isNot(isA<BadgeActivityPayload>()));
      },
    );

    test('an unknown activity_type throws rather than silently misparsing', () {
      final json = {
        'id': 'act-4',
        'user': _userJson,
        'activity_type': 'something_new',
        'reference_id': 'ref-1',
        'occurred_at': '2026-01-10T09:30:00Z',
        'payload': <String, dynamic>{},
      };

      expect(() => ActivityModel.fromJson(json), throwsArgumentError);
    });
  });
}
