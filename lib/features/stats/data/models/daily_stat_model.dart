import '../../domain/entities/daily_stat.dart';

class DailyStatModel extends DailyStat {
  const DailyStatModel({
    required super.date,
    required super.totalMinutes,
    required super.totalPages,
    required super.sessionCount,
  });

  factory DailyStatModel.fromJson(Map<String, dynamic> json) {
    return DailyStatModel(
      date: DateTime.parse(json['date'] as String),
      totalMinutes: json['total_minutes'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      sessionCount: json['session_count'] as int? ?? 0,
    );
  }
}
