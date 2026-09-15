import 'package:equatable/equatable.dart';

/// `GET /social/leaderboard?range=` — `week`/`month`, default `week`.
enum LeaderboardRange { week, month }

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.totalPages,
    required this.totalMinutes,
    required this.rank,
  });

  final String userId;
  final String name;
  final String? avatarUrl;
  final int totalPages;
  final int totalMinutes;
  final int rank;

  @override
  List<Object?> get props =>
      [userId, name, avatarUrl, totalPages, totalMinutes, rank];
}

/// `currentUser` is the requester's own entry — present even when they
/// don't make the top-N `entries` list, so the UI can still show "your
/// position" (CLAUDE.md: "highlight posisi user sendiri walau di luar top N").
class LeaderboardResult extends Equatable {
  const LeaderboardResult({required this.entries, required this.currentUser});

  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUser;

  @override
  List<Object?> get props => [entries, currentUser];
}
