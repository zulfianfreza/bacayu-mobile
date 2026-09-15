import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/leaderboard_entry.dart';

sealed class LeaderboardState extends Equatable {
  const LeaderboardState({required this.range});

  final LeaderboardRange range;

  @override
  List<Object?> get props => [range];
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial({required super.range});
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading({required super.range});
}

class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded({
    required this.entries,
    required this.currentUser,
    required super.range,
  });

  final List<LeaderboardEntry> entries;

  /// The requester's own entry — present even when they're not in
  /// [entries] (outside the top N).
  final LeaderboardEntry? currentUser;

  @override
  List<Object?> get props => [range, entries, currentUser];
}

class LeaderboardError extends LeaderboardState {
  const LeaderboardError(this.failure, {required super.range});

  final Failure failure;

  @override
  List<Object?> get props => [range, failure];
}
