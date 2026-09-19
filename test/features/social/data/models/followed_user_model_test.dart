import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/social/data/models/followed_user_model.dart';

void main() {
  group('FollowedUserModel.fromJson', () {
    test('reads the listed user out of the nested object', () {
      final user = FollowedUserModel.fromJson({
        'user': const {
          'id': 'u2',
          'name': 'Maya',
          'avatar_url': 'https://example.com/a.jpg',
        },
        'created_at': '2026-01-01T00:00:00Z',
        'is_following': true,
        'is_followed_by': false,
      });

      expect(user.id, 'u2');
      expect(user.name, 'Maya');
      expect(user.avatarUrl, 'https://example.com/a.jpg');
    });

    test('reads the relationship flags that sit beside the user object', () {
      final user = FollowedUserModel.fromJson({
        'user': const {'id': 'u2', 'name': 'Maya', 'avatar_url': null},
        'created_at': '2026-01-01T00:00:00Z',
        // The follow button's state, and "follows you back" — siblings of
        // `user`, not fields inside it.
        'is_following': true,
        'is_followed_by': false,
      });

      expect(user.isFollowing, isTrue);
      expect(user.isFollowedBy, isFalse);
    });

    test('a mutual follow comes back with both flags set', () {
      final user = FollowedUserModel.fromJson({
        'user': const {'id': 'u3', 'name': 'Budi', 'avatar_url': null},
        'created_at': '2026-01-01T00:00:00Z',
        'is_following': true,
        'is_followed_by': true,
      });

      expect(user.isFollowing, isTrue);
      expect(user.isFollowedBy, isTrue);
    });

    test('missing flags fall back to false rather than throwing', () {
      final user = FollowedUserModel.fromJson({
        'user': const {'id': 'u4', 'name': 'Anon', 'avatar_url': null},
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(user.isFollowing, isFalse);
      expect(user.isFollowedBy, isFalse);
    });
  });
}
