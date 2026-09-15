import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/activity_comment.dart';
import '../repositories/social_repository.dart';

@injectable
class AddComment {
  AddComment(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, ActivityComment>> call({
    required String activityId,
    required String body,
  }) {
    return _repository.addComment(activityId: activityId, body: body);
  }
}
