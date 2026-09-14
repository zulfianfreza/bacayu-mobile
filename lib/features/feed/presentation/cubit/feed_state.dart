import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/activity.dart';

sealed class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

/// First page loading (also used for pull-to-refresh).
class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedLoaded extends FeedState {
  const FeedLoaded({
    required this.activities,
    required this.hasMore,
    required this.isLoadingMore,
    required this.cursor,
  });

  final List<Activity> activities;
  final bool hasMore;
  final bool isLoadingMore;

  /// `occurred_at` of the last activity — what the next `loadMore()` call
  /// sends as `cursor`.
  final String? cursor;

  FeedLoaded copyWith({
    List<Activity>? activities,
    bool? hasMore,
    bool? isLoadingMore,
    String? cursor,
  }) {
    return FeedLoaded(
      activities: activities ?? this.activities,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      cursor: cursor ?? this.cursor,
    );
  }

  @override
  List<Object?> get props => [activities, hasMore, isLoadingMore, cursor];
}

class FeedError extends FeedState {
  const FeedError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
