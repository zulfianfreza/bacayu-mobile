import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/badge.dart';
import '../repositories/badge_repository.dart';

@injectable
class GetAllBadges {
  GetAllBadges(this._repository);

  final BadgeRepository _repository;

  Future<Either<Failure, List<Badge>>> call() => _repository.getAllBadges();
}
