import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_feed.dart';
import 'feed_state.dart';

/// Matches the backend's default page size (`FeedQuery.Limit` default 20)
/// — used to infer `hasMore` since the backend doesn't return a total.
const _pageSize = 20;

@injectable
class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._getFeed) : super(const FeedInitial());

  final GetFeed _getFeed;

  Future<void> refresh() async {
    emit(const FeedLoading());
    final result = await _getFeed();
    result.fold(
      (failure) => emit(FeedError(failure)),
      (activities) => emit(FeedLoaded(
        activities: activities,
        hasMore: activities.length >= _pageSize,
        isLoadingMore: false,
        cursor: activities.isEmpty
            ? null
            : activities.last.occurredAt.toIso8601String(),
      )),
    );
  }

  /// Appends to the existing list — never replaces it.
  Future<void> loadMore() async {
    final current = state;
    if (current is! FeedLoaded || current.isLoadingMore || !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    final result = await _getFeed(cursor: current.cursor);
    result.fold(
      // A failed "load more" just stops the spinner — the list already on
      // screen stays intact, and hasMore stays true so scrolling retries it.
      (failure) => emit(current.copyWith(isLoadingMore: false)),
      (activities) => emit(current.copyWith(
        activities: [...current.activities, ...activities],
        hasMore: activities.length >= _pageSize,
        isLoadingMore: false,
        cursor: activities.isEmpty
            ? current.cursor
            : activities.last.occurredAt.toIso8601String(),
      )),
    );
  }
}
