import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/badges/data/models/badge_model.dart';

void main() {
  final badgeJson = <String, dynamic>{
    'id': 'first',
    'name': 'First Step',
    'icon': 'book',
    'description': 'Read a book',
  };

  test('parses image_url from the badge API response', () {
    final badge = BadgeModel.fromJson({
      ...badgeJson,
      'image_url': 'https://cdn.example.com/badges/first.png',
    });

    expect(badge.imageUrl, 'https://cdn.example.com/badges/first.png');
  });

  test('allows badges without an image_url', () {
    expect(BadgeModel.fromJson(badgeJson).imageUrl, isNull);
    expect(
      BadgeModel.fromJson({...badgeJson, 'image_url': null}).imageUrl,
      isNull,
    );
  });
}
