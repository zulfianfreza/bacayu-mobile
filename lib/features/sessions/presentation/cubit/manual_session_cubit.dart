import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/reading_session.dart';
import '../../domain/entities/unlocked_badge.dart';
import '../../domain/usecases/submit_session.dart';
import 'manual_session_state.dart';

/// A session the reader logged by hand — no timer, no pauses: just a day, how
/// long it took, and the pages it covered.
///
/// The backend never receives a clock time from this screen (people don't
/// remember when they started), so the timestamps are derived here and only
/// have to satisfy two things: `session_date` (which the backend reads off
/// `start_time`) has to be the day the reader picked, and `occurred_at`
/// (the session's `end_time`) has to fall somewhere sensible in the feed.
@injectable
class ManualSessionCubit extends Cubit<ManualSessionState> {
  ManualSessionCubit(this._submitSession) : super(const ManualSessionIdle());

  final SubmitSession _submitSession;

  DateTime Function() _clock = DateTime.now;

  /// Lets tests control "now" without waiting on real wall-clock time.
  @visibleForTesting
  void debugUseClock(DateTime Function() clock) => _clock = clock;

  /// [date] is the day being logged, [durationMinutes] how long the reading
  /// took, and the pages are the range covered by it (`endPage` must be
  /// greater — the backend rejects an empty range).
  ///
  /// [onBadges] fires when the best-effort remote send reports newly unlocked
  /// badges. It is deliberately *not* tied to this cubit's lifetime: the local
  /// save is what completes [submit], so by the time the network answers, the
  /// page has usually closed and its state listener is gone.
  Future<void> submit({
    required String userBookId,
    required DateTime date,
    required int durationMinutes,
    required int startPage,
    required int endPage,
    void Function(List<UnlockedBadge> badges)? onBadges,
  }) async {
    emit(const ManualSessionSubmitting());

    final (startTime, endTime) = _timestampsFor(date, durationMinutes);

    final session = ReadingSession(
      clientId: const Uuid().v4(),
      userBookId: userBookId,
      inputMode: 'manual',
      startTime: startTime,
      endTime: endTime,
      activeDurationSeconds: durationMinutes * 60,
      pauseIntervals: const [],
      startPage: startPage,
      endPage: endPage,
    );

    final result = await _submitSession(
      session,
      onSyncedWithBadges: (badges) {
        onBadges?.call(badges);
        if (isClosed) return;
        if (state is ManualSessionSubmitted) {
          emit(ManualSessionSubmitted(badgesUnlocked: badges));
        }
      },
    );

    result.fold(
      (failure) => emit(ManualSessionError(failure)),
      (_) => emit(const ManualSessionSubmitted(badgesUnlocked: [])),
    );
  }

  /// Anchors the session to [date] without asking for a clock time.
  ///
  /// For today that means "just now"; for an earlier day it means the same
  /// time of day, so the feed's ordering stays plausible. `startTime` is then
  /// pulled back by the duration and clamped to midnight, which is what keeps
  /// `session_date` on the day the reader actually picked.
  (DateTime, DateTime) _timestampsFor(DateTime date, int durationMinutes) {
    final now = _clock();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final endTime = isToday
        ? now
        : DateTime(date.year, date.month, date.day, now.hour, now.minute);
    final anchoredStart = endTime.subtract(Duration(minutes: durationMinutes));
    final midnight = DateTime(date.year, date.month, date.day);

    return (
      anchoredStart.isBefore(midnight) ? midnight : anchoredStart,
      endTime,
    );
  }
}
