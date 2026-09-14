import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/badge.dart';
import '../../domain/repositories/badge_repository.dart';
import '../datasources/badge_remote_datasource.dart';
import '../models/badge_model.dart';

@LazySingleton(as: BadgeRepository)
class BadgeRepositoryImpl implements BadgeRepository {
  BadgeRepositoryImpl(this._remote);

  final BadgeRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Badge>>> getAllBadges() async {
    try {
      final json = await _remote.getAllBadges();
      final badges = json.cast<Map<String, dynamic>>().map(BadgeModel.fromJson).toList();
      return Right(badges);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }
}
