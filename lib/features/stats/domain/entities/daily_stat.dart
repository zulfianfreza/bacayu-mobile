import 'package:equatable/equatable.dart';

/// One heatmap cell — mirrors `HeatmapEntryResponse` in
/// `api/internal/features/stats/delivery/http/response.go`.
class DailyStat extends Equatable {
  const DailyStat({
    required this.date,
    required this.totalMinutes,
    required this.totalPages,
    required this.sessionCount,
  });

  final DateTime date;
  final int totalMinutes;
  final int totalPages;
  final int sessionCount;

  @override
  List<Object?> get props => [date, totalMinutes, totalPages, sessionCount];
}
