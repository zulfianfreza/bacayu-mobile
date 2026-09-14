import '../../domain/entities/unlocked_badge.dart';

class UnlockedBadgeModel extends UnlockedBadge {
  const UnlockedBadgeModel({
    required super.badgeId,
    required super.name,
    required super.icon,
    required super.description,
  });

  factory UnlockedBadgeModel.fromJson(Map<String, dynamic> json) {
    return UnlockedBadgeModel(
      badgeId: json['badge_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
    );
  }
}
