import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/reading_session.dart';
import '../entities/unlocked_badge.dart';
import '../repositories/session_repository.dart';

@injectable
class SubmitSession {
  SubmitSession(this._repository);

  final SessionRepository _repository;

  Future<Either<Failure, Unit>> call(
    ReadingSession session, {
    void Function(List<UnlockedBadge> badges)? onSyncedWithBadges,
  }) {
    return _repository.submitSession(
      session,
      onSyncedWithBadges: onSyncedWithBadges,
    );
  }
}
