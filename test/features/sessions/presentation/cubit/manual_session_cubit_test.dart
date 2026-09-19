import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/sessions/domain/entities/reading_session.dart';
import 'package:mobile/features/sessions/domain/entities/unlocked_badge.dart';
import 'package:mobile/features/sessions/domain/usecases/submit_session.dart';
import 'package:mobile/features/sessions/presentation/cubit/manual_session_cubit.dart';
import 'package:mobile/features/sessions/presentation/cubit/manual_session_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSubmitSession extends Mock implements SubmitSession {}

const _badge = UnlockedBadge(
  badgeId: 'badge-1',
  name: 'First Step',
  icon: '🎉',
  description: 'Finish your first session',
);

void main() {
  late _MockSubmitSession submitSession;
  late ManualSessionCubit cubit;

  setUpAll(() {
    registerFallbackValue(
      ReadingSession(
        clientId: 'fallback',
        userBookId: 'fallback',
        inputMode: 'manual',
        startTime: DateTime(2026),
        endTime: DateTime(2026),
        activeDurationSeconds: 0,
        pauseIntervals: const [],
        startPage: 0,
        endPage: 1,
      ),
    );
  });

  setUp(() {
    submitSession = _MockSubmitSession();
    when(
      () => submitSession.call(
        any(),
        onSyncedWithBadges: any(named: 'onSyncedWithBadges'),
      ),
    ).thenAnswer((_) async => const Right(unit));
    cubit = ManualSessionCubit(submitSession);
  });

  tearDown(() => cubit.close());

  ReadingSession submitted() =>
      verify(
            () => submitSession.call(
              captureAny(),
              onSyncedWithBadges: any(named: 'onSyncedWithBadges'),
            ),
          ).captured.single
          as ReadingSession;

  test('a manual session carries the manual input mode and no pauses', () async {
    cubit.debugUseClock(() => DateTime(2026, 1, 10, 14, 30));

    await cubit.submit(
      userBookId: 'ub-1',
      date: DateTime(2026, 1, 10),
      durationMinutes: 30,
      startPage: 50,
      endPage: 80,
    );

    final session = submitted();
    expect(session.userBookId, 'ub-1');
    expect(session.inputMode, 'manual');
    // The backend denormalizes pause_count from this, so manual must be empty.
    expect(session.pauseIntervals, isEmpty);
    expect(session.activeDurationSeconds, 30 * 60);
    expect(session.startPage, 50);
    expect(session.endPage, 80);
    // A client_id is generated per submit for the backend's idempotency key.
    expect(session.clientId, isNotEmpty);
  });

  test('logging today anchors the session to now', () async {
    cubit.debugUseClock(() => DateTime(2026, 1, 10, 14, 30));

    await cubit.submit(
      userBookId: 'ub-1',
      date: DateTime(2026, 1, 10),
      durationMinutes: 60,
      startPage: 1,
      endPage: 50,
    );

    final session = submitted();
    expect(session.endTime, DateTime(2026, 1, 10, 14, 30));
    expect(session.startTime, DateTime(2026, 1, 10, 13, 30));
  });

  test('logging an earlier day keeps the same time of day', () async {
    cubit.debugUseClock(() => DateTime(2026, 1, 10, 14, 30));

    await cubit.submit(
      userBookId: 'ub-1',
      date: DateTime(2026, 1, 5),
      durationMinutes: 45,
      startPage: 1,
      endPage: 20,
    );

    final session = submitted();
    expect(session.endTime, DateTime(2026, 1, 5, 14, 30));
    expect(session.startTime, DateTime(2026, 1, 5, 13, 45));
  });

  test('a long session near midnight never spills onto the previous day', () async {
    // 00:30 minus 120 minutes would land on the 9th; the backend reads
    // session_date off start_time, so it has to stay on the day the reader
    // picked.
    cubit.debugUseClock(() => DateTime(2026, 1, 10, 0, 30));

    await cubit.submit(
      userBookId: 'ub-1',
      date: DateTime(2026, 1, 10),
      durationMinutes: 120,
      startPage: 1,
      endPage: 20,
    );

    final session = submitted();
    expect(session.startTime, DateTime(2026, 1, 10));
    expect(session.endTime, DateTime(2026, 1, 10, 0, 30));
    // The entered duration is what gets reported either way.
    expect(session.activeDurationSeconds, 120 * 60);
  });

  test('emits Submitted once the local save lands', () async {
    await cubit.submit(
      userBookId: 'ub-1',
      date: DateTime(2026, 1, 10),
      durationMinutes: 30,
      startPage: 1,
      endPage: 20,
    );

    expect(cubit.state, isA<ManualSessionSubmitted>());
  });

  test('badges from the background send reach the caller callback', () async {
    when(
      () => submitSession.call(
        any(),
        onSyncedWithBadges: any(named: 'onSyncedWithBadges'),
      ),
    ).thenAnswer((invocation) async {
      final onBadges =
          invocation.namedArguments[#onSyncedWithBadges]
              as void Function(List<UnlockedBadge>)?;
      onBadges?.call(const [_badge]);
      return const Right(unit);
    });

    List<UnlockedBadge>? celebrated;
    await cubit.submit(
      userBookId: 'ub-1',
      date: DateTime(2026, 1, 10),
      durationMinutes: 30,
      startPage: 1,
      endPage: 20,
      onBadges: (badges) => celebrated = badges,
    );

    expect(celebrated, const [_badge]);
  });

  test('a failed save surfaces as ManualSessionError', () async {
    when(
      () => submitSession.call(
        any(),
        onSyncedWithBadges: any(named: 'onSyncedWithBadges'),
      ),
    ).thenAnswer((_) async => const Left(CacheFailure()));

    await cubit.submit(
      userBookId: 'ub-1',
      date: DateTime(2026, 1, 10),
      durationMinutes: 30,
      startPage: 1,
      endPage: 20,
    );

    expect(cubit.state, isA<ManualSessionError>());
  });
}
