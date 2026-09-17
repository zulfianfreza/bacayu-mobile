import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Google Sign-In doubles as register-or-login — the backend does a
  /// find-or-create on the verified Google account, so there's no separate
  /// "register with Google". Returns `Right(null)` (not a [Failure]) when
  /// the user cancels the native sign-in sheet — that's not an error.
  Future<Either<Failure, User?>> loginWithGoogle();

  Future<Either<Failure, User>> getCurrentUser();

  /// Any parameter left `null` is left unchanged server-side — an explicit
  /// empty list is a real "clear this field", not "no change".
  Future<Either<Failure, User>> updateProfile({
    List<String>? favoriteGenres,
    int? yearlyGoalBooks,
    int? dailyGoalMinutes,
    String? timezone,
    String? privacyDefault,
  });

  /// Marks onboarding done (`onboarding_completed_at`) — see
  /// `POST /users/me/complete-onboarding`.
  Future<Either<Failure, User>> completeOnboarding();

  Future<Either<Failure, Unit>> logout();
}
