import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/activity_visibility.dart';
import '../repositories/social_repository.dart';

@injectable
class UpdateActivityVisibility {
  UpdateActivityVisibility(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String activityId,
    required ActivityVisibility visibility,
  }) {
    return _repository.updateActivityVisibility(
      activityId: activityId,
      visibility: visibility,
    );
  }
}
