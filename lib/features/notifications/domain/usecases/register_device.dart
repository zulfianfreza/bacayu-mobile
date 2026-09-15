import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../repositories/notification_repository.dart';

@injectable
class RegisterDevice {
  RegisterDevice(this._repository);

  final NotificationRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String token,
    required String platform,
  }) =>
      _repository.registerDevice(token: token, platform: platform);
}
