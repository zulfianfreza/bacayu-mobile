import 'package:equatable/equatable.dart';

class DailyGoalProgress extends Equatable {
  const DailyGoalProgress({
    required this.date,
    required this.timezone,
    required this.goalMinutes,
    required this.totalSeconds,
    required this.totalMinutes,
    required this.remainingMinutes,
    required this.progressPercent,
    required this.achieved,
  });

  final String date;
  final String timezone;
  final int? goalMinutes;
  final int totalSeconds;
  final int totalMinutes;
  final int remainingMinutes;
  final double progressPercent;
  final bool achieved;

  @override
  List<Object?> get props => [
    date,
    timezone,
    goalMinutes,
    totalSeconds,
    totalMinutes,
    remainingMinutes,
    progressPercent,
    achieved,
  ];
}
