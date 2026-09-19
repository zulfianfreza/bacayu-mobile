import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/debounce_event_transformer.dart';
import '../../domain/usecases/follow_user.dart';
import '../../domain/usecases/search_users.dart';
import '../../domain/usecases/unfollow_user.dart';
import 'user_search_event.dart';
import 'user_search_state.dart';

/// Search-as-you-type for people, plus the follow button on each hit — hence a
/// BLoC (the debounce transformer needs events) rather than a Cubit, the same
/// call `BookSearchBloc` makes.
@injectable
class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  UserSearchBloc(this._searchUsers, this._followUser, this._unfollowUser)
      : super(const UserSearchInitial()) {
    on<UserSearchQueryChanged>(
      _onQueryChanged,
      transformer: debounce(const Duration(milliseconds: 400)),
    );
    on<UserSearchLoadMore>(_onLoadMore);
    on<UserSearchFollowToggled>(_onFollowToggled);
  }

  /// The backend refuses anything shorter, and a 1-letter search matches
  /// almost everyone — so below this the page just shows its prompt.
  static const _minQueryLength = 2;

  final SearchUsers _searchUsers;
  final FollowUser _followUser;
  final UnfollowUser _unfollowUser;

  /// The query the results on screen belong to. An in-flight search that has
  /// been superseded by a newer one drops its result instead of overwriting it.
  String _query = '';

  Future<void> _onQueryChanged(
    UserSearchQueryChanged event,
    Emitter<UserSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.length < _minQueryLength) {
      _query = '';
      emit(const UserSearchInitial());
      return;
    }

    _query = query;
    emit(const UserSearchLoading());

    final result = await _searchUsers(query: query);
    if (_query != query) return;

    result.fold(
      (failure) => emit(UserSearchError(failure)),
      (page) => emit(
        UserSearchLoaded(
          users: page.users,
          pendingUserIds: const {},
          page: page.page,
          totalPages: page.totalPages,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    UserSearchLoadMore event,
    Emitter<UserSearchState> emit,
  ) async {
    final current = state;
    if (current is! UserSearchLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final result = await _searchUsers(query: _query, page: current.page + 1);

    final latest = state;
    if (latest is! UserSearchLoaded) return;

    result.fold(
      // Appends nothing, but says why — the results already on screen stay.
      (failure) => emit(
        UserSearchActionError(
          users: latest.users,
          pendingUserIds: latest.pendingUserIds,
          page: latest.page,
          totalPages: latest.totalPages,
          isLoadingMore: false,
          failure: failure,
        ),
      ),
      (page) => emit(
        UserSearchLoaded(
          users: [...latest.users, ...page.users],
          pendingUserIds: latest.pendingUserIds,
          page: page.page,
          totalPages: page.totalPages,
          isLoadingMore: false,
        ),
      ),
    );
  }

  /// Per-row, like `FollowCubit.toggleFollow`: only the tapped user goes into
  /// `pendingUserIds`, the rest of the results stay tappable, and a failure
  /// rolls the row back untouched.
  Future<void> _onFollowToggled(
    UserSearchFollowToggled event,
    Emitter<UserSearchState> emit,
  ) async {
    final current = state;
    if (current is! UserSearchLoaded) return;
    final user = event.user;
    if (current.pendingUserIds.contains(user.id)) return;

    emit(
      UserSearchLoaded(
        users: current.users,
        pendingUserIds: {...current.pendingUserIds, user.id},
        page: current.page,
        totalPages: current.totalPages,
        isLoadingMore: current.isLoadingMore,
      ),
    );

    final willFollow = !user.isFollowing;
    final result = willFollow
        ? await _followUser(user.id)
        : await _unfollowUser(user.id);

    final latest = state;
    if (latest is! UserSearchLoaded) return;

    final pending = {...latest.pendingUserIds}..remove(user.id);

    result.fold(
      (failure) => emit(
        UserSearchActionError(
          users: latest.users,
          pendingUserIds: pending,
          page: latest.page,
          totalPages: latest.totalPages,
          isLoadingMore: latest.isLoadingMore,
          failure: failure,
        ),
      ),
      (_) => emit(
        UserSearchLoaded(
          users: [
            for (final u in latest.users)
              if (u.id == user.id) u.copyWith(isFollowing: willFollow) else u,
          ],
          pendingUserIds: pending,
          page: latest.page,
          totalPages: latest.totalPages,
          isLoadingMore: latest.isLoadingMore,
        ),
      ),
    );
  }
}
