import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/daily_stat.dart';
import '../../domain/entities/stats_summary.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_remote_datasource.dart';
import '../models/daily_stat_model.dart';
import '../models/stats_summary_model.dart';

@LazySingleton(as: StatsRepository)
class StatsRepositoryImpl implements StatsRepository {
  StatsRepositoryImpl(this._remote);

  final StatsRemoteDataSource _remote;

  @override
  Future<Either<Failure, StatsSummary>> getSummary(StatsRange range) async {
    try {
      final json = await _remote.getSummary(range.wireValue);
      return Right(StatsSummaryModel.fromJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, List<DailyStat>>> getHeatmap(int year) async {
    try {
      final json = await _remote.getHeatmap(year);
      final stats = json
          .cast<Map<String, dynamic>>()
          .map(DailyStatModel.fromJson)
          .toList();
      return Right(stats);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }
}
