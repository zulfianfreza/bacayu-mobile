import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final SecureTokenStorage _tokenStorage;

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _remote.register(email: email, password: password, name: name);
      // /auth/register doesn't mint a token (see datasource docstring) — log
      // straight in with the same credentials so a successful registration
      // always leaves the caller authenticated, same as a successful login.
      return _loginAndPersistToken(email: email, password: password);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _loginAndPersistToken(email: email, password: password);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  Future<Either<Failure, User>> _loginAndPersistToken({
    required String email,
    required String password,
  }) async {
    final json = await _remote.login(email: email, password: password);
    final token = json['access_token'] as String;
    final user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    await _tokenStorage.saveToken(token);
    return Right(user);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final json = await _remote.getMe();
      return Right(UserModel.fromJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    List<String>? favoriteGenres,
    int? yearlyGoalBooks,
    int? dailyGoalMinutes,
    String? timezone,
  }) async {
    try {
      final json = await _remote.updateProfile(
        favoriteGenres: favoriteGenres,
        yearlyGoalBooks: yearlyGoalBooks,
        dailyGoalMinutes: dailyGoalMinutes,
        timezone: timezone,
      );
      return Right(UserModel.fromJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, User>> completeOnboarding() async {
    try {
      final json = await _remote.completeOnboarding();
      return Right(UserModel.fromJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    // No server-side session to invalidate (stateless JWT, no logout
    // endpoint) — clearing the local token is the whole operation.
    await _tokenStorage.clearToken();
    return const Right(unit);
  }
}
