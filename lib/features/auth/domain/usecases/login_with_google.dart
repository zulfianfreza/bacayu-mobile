import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginWithGoogle {
  LoginWithGoogle(this._repository);

  final AuthRepository _repository;

  /// `Right(null)` means the user cancelled the native Google sign-in
  /// sheet — not a [Failure].
  Future<Either<Failure, User?>> call() => _repository.loginWithGoogle();
}
