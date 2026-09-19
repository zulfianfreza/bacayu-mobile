import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/activity_page.dart';

abstract class FeedRepository {
  /// `GET /feed` — the requester's OWN activities, newest first.
  ///
  /// [cursor] is the `meta.next_cursor` from the previous page (an opaque
  /// `occurred_at` token the backend formats); `null` starts from the top.
  Future<Either<Failure, ActivityPage>> getFeed({String? cursor});

  /// `GET /feed/social` — activities from the people the requester follows,
  /// restricted server-side to `visibility` `followers`/`public`, newest
  /// first. Same cursor contract as [getFeed].
  Future<Either<Failure, ActivityPage>> getSocialFeed({String? cursor});
}
