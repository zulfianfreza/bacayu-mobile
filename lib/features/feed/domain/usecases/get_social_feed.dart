import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/activity_page.dart';
import '../repositories/feed_repository.dart';

/// `GET /feed/social` — what Home shows: everyone the user follows, filtered
/// server-side to `followers`/`public` visibility.
@injectable
class GetSocialFeed {
  GetSocialFeed(this._repository);

  final FeedRepository _repository;

  Future<Either<Failure, ActivityPage>> call({String? cursor}) =>
      _repository.getSocialFeed(cursor: cursor);
}
