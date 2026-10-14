import '../../domain/entities/daily_goal_progress.dart';

class DailyGoalProgressModel extends DailyGoalProgress {
  DailyGoalProgressModel.fromJson(Map<String, dynamic> json)
    : super(
        date: json['date'] as String,
        timezone: json['timezone'] as String,
        goalMinutes: json['goal_minutes'] as int?,
        totalSeconds: json['total_seconds'] as int,
        totalMinutes: json['total_minutes'] as int,
        remainingMinutes: json['remaining_minutes'] as int,
        progressPercent: (json['progress_percent'] as num).toDouble(),
        achieved: json['achieved'] as bool,
      );
}
