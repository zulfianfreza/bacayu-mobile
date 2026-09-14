import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateProfile {
  UpdateProfile(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call({
    List<String>? favoriteGenres,
    int? yearlyGoalBooks,
    int? dailyGoalMinutes,
    String? timezone,
  }) {
    return _repository.updateProfile(
      favoriteGenres: favoriteGenres,
      yearlyGoalBooks: yearlyGoalBooks,
      dailyGoalMinutes: dailyGoalMinutes,
      timezone: timezone,
    );
  }
}
