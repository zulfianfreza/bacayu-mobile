import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/activity.dart';
import '../repositories/feed_repository.dart';

@injectable
class GetFeed {
  GetFeed(this._repository);

  final FeedRepository _repository;

  Future<Either<Failure, List<Activity>>> call({String? cursor}) =>
      _repository.getFeed(cursor: cursor);
}
