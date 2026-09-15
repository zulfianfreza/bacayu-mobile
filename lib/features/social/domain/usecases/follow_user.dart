import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../repositories/social_repository.dart';

@injectable
class FollowUser {
  FollowUser(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, Unit>> call(String userId) => _repository.followUser(userId);
}
