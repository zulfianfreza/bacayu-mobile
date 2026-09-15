import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/followed_user.dart';
import '../repositories/social_repository.dart';

@injectable
class ListFollowing {
  ListFollowing(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, List<FollowedUser>>> call() => _repository.listFollowing();
}
