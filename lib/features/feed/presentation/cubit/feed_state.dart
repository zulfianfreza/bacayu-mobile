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
    required this.viewerId,
  });

  final List<Activity> activities;

  /// Whether the backend handed back a `next_cursor` — i.e. there is another
  /// page to ask for. Read from the server, never inferred from item count.
  final bool hasMore;

  final bool isLoadingMore;

  /// The `meta.next_cursor` from the last page — what `loadMore()` sends back
  /// as `cursor`. `null` on the last page.
  final String? cursor;

  /// The signed-in user's id. Cards compare it against an activity's author to
  /// decide whether the item is the viewer's own (and so may show the
  /// visibility menu).
  final String viewerId;

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
      viewerId: viewerId,
    );
  }

  @override
  List<Object?> get props => [
    activities,
    hasMore,
    isLoadingMore,
    cursor,
    viewerId,
  ];
}

class FeedError extends FeedState {
  const FeedError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
