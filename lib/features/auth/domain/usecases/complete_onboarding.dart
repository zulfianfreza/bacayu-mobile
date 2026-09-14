import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class CompleteOnboarding {
  CompleteOnboarding(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call() => _repository.completeOnboarding();
}
