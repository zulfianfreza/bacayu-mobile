import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarUrl,
    required this.timezone,
    required this.favoriteGenres,
    required this.yearlyGoalBooks,
    required this.dailyGoalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastReadDate,
    required this.privacyDefault,
    required this.onboardingCompletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String name;
  final String avatarUrl;
  final String timezone;
  final List<String> favoriteGenres;
  final int? yearlyGoalBooks;
  final int? dailyGoalMinutes;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadDate;
  final String privacyDefault;
  final DateTime? onboardingCompletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Set via `POST /users/me/complete-onboarding` at the end of the
  /// onboarding flow (PRD Section 3.1).
  bool get hasOnboarded => onboardingCompletedAt != null;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        timezone,
        favoriteGenres,
        yearlyGoalBooks,
        dailyGoalMinutes,
        currentStreak,
        longestStreak,
        lastReadDate,
        privacyDefault,
        onboardingCompletedAt,
        createdAt,
        updatedAt,
      ];
}
