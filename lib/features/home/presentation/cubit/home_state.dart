import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../feed/domain/entities/activity.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../../../stats/domain/entities/daily_stat.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.userName,
    required this.avatarUrl,
    required this.currentStreak,
    required this.longestStreak,
    required this.last7Days,
    required this.continueReading,
    required this.recentActivity,
    required this.isEmptyState,
  });

  final String userName;
  final String avatarUrl;
  final int currentStreak;
  final int longestStreak;

  /// Exactly 7 entries, oldest first, zero-filled for days with no stat row.
  final List<DailyStat> last7Days;
  final List<UserBook> continueReading;

  /// Already trimmed to the small preview count shown on Home.
  final List<Activity> recentActivity;

  /// True only when the user has never submitted a session at all
  /// (feed is empty AND current_streak is 0) — both conditions, not either.
  final bool isEmptyState;

  @override
  List<Object?> get props => [
        userName,
        avatarUrl,
        currentStreak,
        longestStreak,
        last7Days,
        continueReading,
        recentActivity,
        isEmptyState,
      ];
}

class HomeError extends HomeState {
  const HomeError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
