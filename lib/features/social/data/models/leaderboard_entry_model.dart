import '../../domain/entities/leaderboard_entry.dart';

extension LeaderboardRangeWire on LeaderboardRange {
  String get wireValue => switch (this) {
        LeaderboardRange.week => 'week',
        LeaderboardRange.month => 'month',
      };
}

class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.userId,
    required super.name,
    required super.avatarUrl,
    required super.totalPages,
    required super.totalMinutes,
    required super.rank,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return LeaderboardEntryModel(
      userId: user['id'] as String,
      name: user['name'] as String,
      avatarUrl: user['avatar_url'] as String?,
      totalPages: json['total_pages'] as int? ?? 0,
      totalMinutes: json['total_minutes'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
    );
  }
}

class LeaderboardResultModel extends LeaderboardResult {
  const LeaderboardResultModel({required super.entries, required super.currentUser});

  factory LeaderboardResultModel.fromJson(Map<String, dynamic> json) {
    final entries = (json['entries'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(LeaderboardEntryModel.fromJson)
        .toList();
    final currentUserJson = json['current_user'] as Map<String, dynamic>?;

    return LeaderboardResultModel(
      entries: entries,
      currentUser:
          currentUserJson == null ? null : LeaderboardEntryModel.fromJson(currentUserJson),
    );
  }
}
