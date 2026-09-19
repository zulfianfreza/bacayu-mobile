import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/followed_user.dart';

/// The result set and its progress live on the base so the page can read
/// `users`/`pendingUserIds`/`hasMore` no matter which state it is in — the same
/// shape `FollowState` uses, for the same reason.
sealed class UserSearchState extends Equatable {
  const UserSearchState({
    required this.users,
    required this.pendingUserIds,
    required this.page,
    required this.totalPages,
    required this.isLoadingMore,
  });

  final List<FollowedUser> users;

  /// Rows currently mid follow/unfollow — only those show a spinner.
  final Set<String> pendingUserIds;

  /// 1-based page the results currently end at; 0 before the first search.
  final int page;
  final int totalPages;
  final bool isLoadingMore;

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [
        users,
        pendingUserIds,
        page,
        totalPages,
        isLoadingMore,
      ];
}

/// Nothing searched yet — the page shows its prompt rather than "no results".
class UserSearchInitial extends UserSearchState {
  const UserSearchInitial()
      : super(
          users: const [],
          pendingUserIds: const {},
          page: 0,
          totalPages: 0,
          isLoadingMore: false,
        );
}

class UserSearchLoading extends UserSearchState {
  const UserSearchLoading()
      : super(
          users: const [],
          pendingUserIds: const {},
          page: 0,
          totalPages: 0,
          isLoadingMore: false,
        );
}

class UserSearchLoaded extends UserSearchState {
  const UserSearchLoaded({
    required super.users,
    required super.pendingUserIds,
    required super.page,
    required super.totalPages,
    required super.isLoadingMore,
  });

  UserSearchLoaded copyWith({bool? isLoadingMore}) {
    return UserSearchLoaded(
      users: users,
      pendingUserIds: pendingUserIds,
      page: page,
      totalPages: totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// The search itself failed — nothing to show.
class UserSearchError extends UserSearchState {
  const UserSearchError(this.failure)
      : super(
          users: const [],
          pendingUserIds: const {},
          page: 0,
          totalPages: 0,
          isLoadingMore: false,
        );

  final Failure failure;

  @override
  List<Object?> get props => [...super.props, failure];
}

/// A follow/unfollow (or a "load more") failed — the results already on screen
/// stay, and the page shows [failure] once (a snackbar).
class UserSearchActionError extends UserSearchState {
  const UserSearchActionError({
    required super.users,
    required super.pendingUserIds,
    required super.page,
    required super.totalPages,
    required super.isLoadingMore,
    required this.failure,
  });

  final Failure failure;

  @override
  List<Object?> get props => [...super.props, failure];
}
