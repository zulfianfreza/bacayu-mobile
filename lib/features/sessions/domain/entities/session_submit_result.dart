import 'unlocked_badge.dart';
import 'session_streak.dart';

class SessionSubmitResult {
  const SessionSubmitResult({required this.badgesUnlocked, this.streak});

  final List<UnlockedBadge> badgesUnlocked;
  final SessionStreak? streak;
}
