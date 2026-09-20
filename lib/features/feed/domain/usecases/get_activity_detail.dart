import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/activity_detail.dart';
import '../repositories/feed_repository.dart';

/// `GET /feed/:activityId` — one activity with the detail behind it: a reading
/// session's pauses and unlocked badges, or a badge unlock's own artwork.
@injectable
class GetActivityDetail {
  GetActivityDetail(this._repository);

  final FeedRepository _repository;

  Future<Either<Failure, ActivityDetail>> call(String activityId) =>
      _repository.getActivityDetail(activityId);
}
