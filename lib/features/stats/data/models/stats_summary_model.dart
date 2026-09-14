import '../../domain/entities/stats_summary.dart';

extension StatsRangeWire on StatsRange {
  String get wireValue => switch (this) {
        StatsRange.week => 'week',
        StatsRange.month => 'month',
        StatsRange.year => 'year',
        StatsRange.all => 'all',
      };
}

/// Mirrors `SummaryResponse` — `genre_distribution` is a `{genre: count}`
/// JSON object on the wire, turned into a sorted (descending by count)
/// list here since that's how it's always displayed.
class StatsSummaryModel extends StatsSummary {
  const StatsSummaryModel({
    required super.booksFinished,
    required super.totalPages,
    required super.totalMinutes,
    required super.avgSpeedPpm,
    required super.genreDistribution,
  });

  factory StatsSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['genre_distribution'] as Map<String, dynamic>? ?? {};
    final genres = [
      for (final entry in rawGenres.entries)
        GenreCount(genre: entry.key, count: entry.value as int),
    ]..sort((a, b) => b.count.compareTo(a.count));

    return StatsSummaryModel(
      booksFinished: json['total_books_finished'] as int? ?? 0,
      totalPages: json['total_pages_read'] as int? ?? 0,
      totalMinutes: json['total_minutes_read'] as int? ?? 0,
      avgSpeedPpm: (json['average_speed_ppm'] as num?)?.toDouble() ?? 0,
      genreDistribution: genres,
    );
  }
}
