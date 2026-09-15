import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/activity_comment.dart';
import '../repositories/social_repository.dart';

@injectable
class ListComments {
  ListComments(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, List<ActivityComment>>> call(String activityId) =>
      _repository.listComments(activityId);
}
