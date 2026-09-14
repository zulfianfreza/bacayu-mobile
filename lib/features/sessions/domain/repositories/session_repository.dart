import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/reading_session.dart';
import '../entities/unlocked_badge.dart';

abstract class SessionRepository {
  /// Enqueues [session] locally and returns success as soon as that local
  /// save completes — it does NOT wait on the network (CLAUDE.md Section
  /// 6.2). A remote send is attempted in the background; if it completes
  /// while the caller is still around, [onSyncedWithBadges] fires with the
  /// backend's fast-path badge result (may be empty). If it fails, the row
  /// stays unsynced for `SessionSyncWorker` to retry — never surfaced as a
  /// [Failure] here.
  Future<Either<Failure, Unit>> submitSession(
    ReadingSession session, {
    void Function(List<UnlockedBadge> badges)? onSyncedWithBadges,
  });

  Future<Either<Failure, List<ReadingSession>>> getHistory({int page = 1});
}
