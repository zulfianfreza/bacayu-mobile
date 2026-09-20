import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../domain/entities/activity_page.dart';
import '../../domain/usecases/get_feed.dart';
import '../../domain/usecases/get_social_feed.dart';
import 'feed_state.dart';

/// One page of activities for a cursor. The only thing that differs between the
/// social feed and the reader's own activity list.
typedef ActivityPageLoader =
    Future<Either<Failure, ActivityPage>> Function({String? cursor});

/// Paging for a feed, whichever feed it is: both endpoints hand back a page and
/// an explicit `next_cursor`, so the walking lives here once instead of once
/// per endpoint. Construct it through [SocialFeedCubit] or [MyActivityCubit].
class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._load, this._getCurrentUser) : super(const FeedInitial());

  final ActivityPageLoader _load;
  final GetCurrentUser _getCurrentUser;

  Future<void> refresh() async {
    emit(const FeedLoading());

    // The viewer rides along with the first page: every card has to know
    // whether it is looking at the viewer's own activity, and that is a
    // comparison against this id.
    final results = await Future.wait<dynamic>([
      _load(),
      _getCurrentUser(),
    ]);

    final pageResult = results[0] as Either<Failure, ActivityPage>;
    final userResult = results[1] as Either<Failure, User>;

    Failure? firstFailure;
    ActivityPage? page;
    User? user;
    pageResult.fold((f) => firstFailure ??= f, (v) => page = v);
    userResult.fold((f) => firstFailure ??= f, (v) => user = v);

    final failure = firstFailure;
    if (failure != null) {
      emit(FeedError(failure));
      return;
    }

    emit(
      FeedLoaded(
        activities: page!.items,
        hasMore: page!.nextCursor != null,
        isLoadingMore: false,
        cursor: page!.nextCursor,
        viewerId: user!.id,
      ),
    );
  }

  /// Appends to the existing list — never replaces it.
  Future<void> loadMore() async {
    final current = state;
    if (current is! FeedLoaded || current.isLoadingMore || !current.hasMore) {
      return;
    }
    final cursor = current.cursor;
    if (cursor == null) return;

    emit(current.copyWith(isLoadingMore: true));
    final result = await _load(cursor: cursor);
    result.fold(
      // A failed "load more" just stops the spinner — the list already on
      // screen stays intact, and hasMore stays true so scrolling retries it.
      (failure) => emit(current.copyWith(isLoadingMore: false)),
      (page) => emit(
        current.copyWith(
          activities: [...current.activities, ...page.items],
          hasMore: page.nextCursor != null,
          isLoadingMore: false,
          cursor: page.nextCursor,
        ),
      ),
    );
  }
}

/// Home's feed: everyone the reader follows.
@injectable
class SocialFeedCubit extends FeedCubit {
  SocialFeedCubit(GetSocialFeed feed, GetCurrentUser getCurrentUser)
    : super(feed.call, getCurrentUser);
}

/// The reader's own activity, newest first — what the Profile tab lists.
@injectable
class MyActivityCubit extends FeedCubit {
  MyActivityCubit(GetFeed feed, GetCurrentUser getCurrentUser)
    : super(feed.call, getCurrentUser);
}
