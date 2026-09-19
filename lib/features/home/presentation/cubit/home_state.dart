import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
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
  });

  final String userName;
  final String avatarUrl;
  final int currentStreak;
  final int longestStreak;

  /// Exactly 7 entries, oldest first, zero-filled for days with no stat row.
  final List<DailyStat> last7Days;
  final List<UserBook> continueReading;

  @override
  List<Object?> get props => [
    userName,
    avatarUrl,
    currentStreak,
    longestStreak,
    last7Days,
    continueReading,
  ];
}

class HomeError extends HomeState {
  const HomeError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
