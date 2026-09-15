import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../repositories/social_repository.dart';

@injectable
class LikeActivity {
  LikeActivity(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, Unit>> call(String activityId) =>
      _repository.likeActivity(activityId);
}
