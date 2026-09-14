import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';
import '../models/activity_model.dart';

@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._remote);

  final FeedRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Activity>>> getFeed({String? cursor}) async {
    try {
      final json = await _remote.getFeed(cursor: cursor);
      final activities =
          json.cast<Map<String, dynamic>>().map(ActivityModel.fromJson).toList();
      return Right(activities);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }
}
