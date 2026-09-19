import 'package:equatable/equatable.dart';

import 'followed_user.dart';

/// One page of user-search hits, plus where it sits in the result set.
///
/// Named "results", not "page", so it cannot be confused with the screen that
/// shows them. Search pages by index (`page`/`total_pages`), unlike the feed's
/// cursor — the backend returns a total here.
class UserSearchResults extends Equatable {
  const UserSearchResults({
    required this.users,
    required this.page,
    required this.totalPages,
  });

  final List<FollowedUser> users;

  /// 1-based, matching what the endpoint takes.
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [users, page, totalPages];
}
