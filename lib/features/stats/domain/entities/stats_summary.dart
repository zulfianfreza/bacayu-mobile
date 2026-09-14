import 'package:equatable/equatable.dart';

class GenreCount extends Equatable {
  const GenreCount({required this.genre, required this.count});

  final String genre;
  final int count;

  @override
  List<Object?> get props => [genre, count];
}

/// Mirrors `SummaryResponse` in
/// `api/internal/features/stats/delivery/http/response.go`.
class StatsSummary extends Equatable {
  const StatsSummary({
    required this.booksFinished,
    required this.totalPages,
    required this.totalMinutes,
    required this.avgSpeedPpm,
    required this.genreDistribution,
  });

  final int booksFinished;
  final int totalPages;
  final int totalMinutes;
  final double avgSpeedPpm;
  final List<GenreCount> genreDistribution;

  @override
  List<Object?> get props => [
        booksFinished,
        totalPages,
        totalMinutes,
        avgSpeedPpm,
        genreDistribution,
      ];
}

/// `GET /stats/summary?range=` — matches `SummaryQuery.Range` on the
/// backend (`week`/`month`/`year`/`all`, default `week`).
enum StatsRange { week, month, year, all }
