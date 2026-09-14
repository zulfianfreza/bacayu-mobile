import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/activity.dart';

abstract class FeedRepository {
  /// [cursor] is the `occurred_at` (ISO-8601) of the last activity from the
  /// previous page — the backend has no server-returned "next cursor" to
  /// hand back (its `FeedMeta.next_cursor` field exists in the DTO but the
  /// handler never populates it), so the caller derives it from the last
  /// item it already has.
  Future<Either<Failure, List<Activity>>> getFeed({String? cursor});
}
