import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/feed/data/models/activity_detail_model.dart';

/// `GET /feed/:activityId` for a reading session: the feed item's fields
/// inline, plus `visibility` and the `session` detail.
Map<String, dynamic> _sessionJson({
  List<Map<String, dynamic>> badges = const [],
}) => {
  'id': 'act-1',
  'user': const {'id': 'u1', 'name': 'Julian', 'avatar_url': null},
  'activity_type': 'reading_session',
  'reference_id': 'sess-1',
  'occurred_at': '2026-01-10T09:30:00Z',
  'like_count': 2,
  'comment_count': 1,
  'is_liked': false,
  'visibility': 'followers',
  'payload': {
    'book_title': 'Atomic Habits',
    'book_cover_url': null,
    'pages_read': 20,
    'speed_ppm': 1.2,
    'active_duration_seconds': 600,
  },
  'session': {
    'id': 'sess-1',
    'pause_count': 2,
    'pause_intervals': [
      {'paused_at': '2026-01-10T09:35:00Z', 'resumed_at': '2026-01-10T09:40:00Z'},
      {'paused_at': '2026-01-10T09:50:00Z', 'resumed_at': '2026-01-10T09:53:00Z'},
    ],
    'badges': badges,
  },
  'badge': null,
};

Map<String, dynamic> _badgeActivityJson({String? imageUrl}) => {
  'id': 'act-2',
  'user': const {'id': 'u1', 'name': 'Julian', 'avatar_url': null},
  'activity_type': 'badge_unlocked',
  'reference_id': 'ub-1',
  'occurred_at': '2026-01-10T10:00:00Z',
  'like_count': 0,
  'comment_count': 0,
  'is_liked': false,
  'visibility': 'public',
  'payload': {
    'badge_name': 'First Step',
    'badge_icon': '🎉',
    'badge_description': 'Finish your first session',
  },
  'session': null,
  'badge': {
    'user_badge_id': 'ub-1',
    'badge_id': 'b-1',
    'name': 'First Step',
    'slug': 'first_step',
    'description': 'Finish your first session',
    'icon': '🎉',
    'image_url': imageUrl,
    'category': 'reading',
    'unlocked_at': '2026-01-10T10:00:00Z',
    'trigger_session_id': 'sess-1',
  },
};

void main() {
  group('ActivityDetailModel.fromJson', () {
    test('reads the activity, its visibility and its pauses', () {
      final detail = ActivityDetailModel.fromJson(_sessionJson());

      // The item is inlined in this response, so it parses through the same
      // model the feed list uses.
      expect(detail.activity.id, 'act-1');
      expect(detail.activity.author.name, 'Julian');
      expect(detail.visibility, 'followers');
      expect(detail.badge, isNull);

      final session = detail.session!;
      expect(session.pauseCount, 2);
      expect(session.pauses, hasLength(2));
      expect(
        session.pauses.first.pausedAt,
        DateTime.parse('2026-01-10T09:35:00Z'),
      );
      // 5 minutes + 3 minutes.
      expect(session.pausedFor, const Duration(minutes: 8));
    });

    test('reads the badges the session unlocked', () {
      final detail = ActivityDetailModel.fromJson(
        _sessionJson(
          badges: [
            {
              'badge_id': 'b-1',
              'name': 'Bookworm',
              'description': 'Finish 10 books',
              'image_url': 'https://cdn.example.com/bookworm.png',
            },
            {
              'badge_id': 'b-2',
              'name': 'Night Owl',
              'description': 'Read past midnight',
              'image_url': null,
            },
          ],
        ),
      );

      final badges = detail.session!.badges;
      expect(badges, hasLength(2));
      expect(badges.first.badgeId, 'b-1');
      expect(badges.first.name, 'Bookworm');
      expect(badges.first.imageUrl, 'https://cdn.example.com/bookworm.png');
      expect(badges.last.imageUrl, isNull);
    });

    test('a badge unlock carries its own artwork', () {
      final detail = ActivityDetailModel.fromJson(
        _badgeActivityJson(imageUrl: 'https://cdn.example.com/first.png'),
      );

      expect(detail.session, isNull);
      expect(detail.badge!.badgeId, 'b-1');
      expect(detail.badge!.name, 'First Step');
      expect(detail.badge!.imageUrl, 'https://cdn.example.com/first.png');
    });

    test('a badge with no artwork parses to null, not an empty string', () {
      final detail = ActivityDetailModel.fromJson(_badgeActivityJson());

      expect(detail.badge!.imageUrl, isNull);
    });
  });
}
