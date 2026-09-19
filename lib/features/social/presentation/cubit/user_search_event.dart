import 'package:equatable/equatable.dart';

import '../../domain/entities/followed_user.dart';

sealed class UserSearchEvent extends Equatable {
  const UserSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Debounced: a keystroke burst only searches once, for the last query.
class UserSearchQueryChanged extends UserSearchEvent {
  const UserSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Scrolled near the end of the results — asks for the next page.
class UserSearchLoadMore extends UserSearchEvent {
  const UserSearchLoadMore();
}

/// Follow / unfollow tapped on one result row.
class UserSearchFollowToggled extends UserSearchEvent {
  const UserSearchFollowToggled(this.user);

  final FollowedUser user;

  @override
  List<Object?> get props => [user];
}
