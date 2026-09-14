import '../../domain/entities/badge.dart';

class BadgeModel extends Badge {
  const BadgeModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.description,
    required super.imageUrl,
    required super.unlocked,
    required super.unlockedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] == null
          ? null
          : DateTime.parse(json['unlocked_at'] as String),
    );
  }
}
