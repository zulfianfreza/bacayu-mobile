import '../../domain/entities/user.dart';

/// Mirrors `UserResponse` in `api/internal/features/auth/delivery/http/response.go`
/// field-for-field.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.avatarUrl,
    required super.timezone,
    required super.favoriteGenres,
    required super.yearlyGoalBooks,
    required super.dailyGoalMinutes,
    required super.currentStreak,
    required super.longestStreak,
    required super.lastReadDate,
    required super.privacyDefault,
    required super.onboardingCompletedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      favoriteGenres: (json['favorite_genres'] as List<dynamic>? ?? [])
          .cast<String>(),
      yearlyGoalBooks: json['yearly_goal_books'] as int?,
      dailyGoalMinutes: json['daily_goal_minutes'] as int?,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastReadDate: json['last_read_date'] == null
          ? null
          : DateTime.parse(json['last_read_date'] as String),
      privacyDefault: json['privacy_default'] as String? ?? 'private',
      onboardingCompletedAt: json['onboarding_completed_at'] == null
          ? null
          : DateTime.parse(json['onboarding_completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
