import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/activity_page.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';
import '../models/activity_model.dart';

@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._remote);

  final FeedRemoteDataSource _remote;

  @override
  Future<Either<Failure, ActivityPage>> getFeed({String? cursor}) {
    return _fetch((cursor) => _remote.getFeed(cursor: cursor), cursor);
  }

  @override
  Future<Either<Failure, ActivityPage>> getSocialFeed({String? cursor}) {
    return _fetch((cursor) => _remote.getSocialFeed(cursor: cursor), cursor);
  }

  /// Both endpoints share one page shape, so they share one mapper — and one
  /// `DioException` → `Failure` boundary.
  Future<Either<Failure, ActivityPage>> _fetch(
    Future<({List<dynamic> items, String? nextCursor})> Function(String?)
    request,
    String? cursor,
  ) async {
    try {
      final page = await request(cursor);
      final activities = page.items
          .cast<Map<String, dynamic>>()
          .map(ActivityModel.fromJson)
          .toList();
      return Right(
        ActivityPage(items: activities, nextCursor: page.nextCursor),
      );
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }
}
