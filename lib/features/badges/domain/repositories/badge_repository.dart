import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/badge.dart';

abstract class BadgeRepository {
  /// GET /badges — every badge, `unlocked`/`unlockedAt` per this user.
  Future<Either<Failure, List<Badge>>> getAllBadges();
}
