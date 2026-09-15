import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

abstract class NotificationRepository {
  Future<Either<Failure, Unit>> registerDevice({
    required String token,
    required String platform,
  });
}
