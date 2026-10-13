import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../repositories/social_repository.dart';

@injectable
class GetFollowingCount {
  GetFollowingCount(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, int>> call() => _repository.getFollowingCount();
}
