import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<Either<Failure, Unit>> registerDevice({
    required String token,
    required String platform,
  }) async {
    try {
      await _remote.registerDevice(token: token, platform: platform);
      return const Right(unit);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }
}
