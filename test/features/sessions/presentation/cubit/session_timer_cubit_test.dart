import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/sessions/domain/repositories/session_repository.dart';
import 'package:mobile/features/sessions/domain/usecases/submit_session.dart';
import 'package:mobile/features/sessions/presentation/cubit/session_timer_cubit.dart';
import 'package:mobile/features/sessions/presentation/cubit/session_timer_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionTimerCubit cubit;
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 1, 1, 10, 0, 0);
    cubit = SessionTimerCubit(SubmitSession(_MockSessionRepository()));
    cubit.debugUseClock(() => now);
  });

  tearDown(() => cubit.close());

  test(
      'idle -> running -> paused -> running -> stopped records pause '
      'intervals and active duration correctly', () {
    expect(cubit.state, const SessionTimerIdle());

    cubit.start(userBookId: 'ub-1');
    expect(cubit.state, isA<SessionTimerRunning>());

    now = now.add(const Duration(minutes: 5));
    cubit.pause();
    expect(
      cubit.state,
      const SessionTimerPaused(elapsed: Duration(minutes: 5), pauseCount: 0),
    );

    now = now.add(const Duration(minutes: 2));
    cubit.resume();
    // The 2 paused minutes must NOT count toward elapsed.
    expect(
      cubit.state,
      const SessionTimerRunning(elapsed: Duration(minutes: 5), pauseCount: 1),
    );

    now = now.add(const Duration(minutes: 3));
    cubit.stop();
    final stopped = cubit.state as SessionTimerStopped;
    expect(stopped.activeDurationSeconds, const Duration(minutes: 8).inSeconds);
    expect(stopped.pauseCount, 1);
  });

  test('stopping while paused closes the trailing pause interval', () {
    cubit.start(userBookId: 'ub-1');
    now = now.add(const Duration(minutes: 4));
    cubit.pause();

    now = now.add(const Duration(minutes: 1));
    cubit.stop(); // stopped directly from paused, never resumed

    final stopped = cubit.state as SessionTimerStopped;
    expect(stopped.activeDurationSeconds, const Duration(minutes: 4).inSeconds);
    expect(stopped.pauseCount, 1);
  });

  test(
      'app backgrounded then resumed: active duration reflects real elapsed '
      'time even though the UI ticker was stopped, and no pause_interval '
      'is created for it', () {
    cubit.start(userBookId: 'ub-1');

    now = now.add(const Duration(minutes: 1));
    cubit.didChangeAppLifecycleState(AppLifecycleState.paused); // backgrounded

    // 10 minutes pass while "in the background" — the ticker would have
    // been stopped for all of this, a counter-based implementation would
    // have missed it entirely.
    now = now.add(const Duration(minutes: 10));
    cubit.didChangeAppLifecycleState(AppLifecycleState.resumed);

    final running = cubit.state as SessionTimerRunning;
    expect(running.elapsed, const Duration(minutes: 11));
    expect(running.pauseCount, 0);

    now = now.add(const Duration(minutes: 1));
    cubit.stop();
    final stopped = cubit.state as SessionTimerStopped;
    expect(stopped.activeDurationSeconds, const Duration(minutes: 12).inSeconds);
    expect(stopped.pauseCount, 0);
  });

  test('backgrounding while already paused (user-paused) is a no-op', () {
    cubit.start(userBookId: 'ub-1');
    now = now.add(const Duration(minutes: 2));
    cubit.pause();

    // App goes to background while the user had already paused manually.
    cubit.didChangeAppLifecycleState(AppLifecycleState.paused);
    now = now.add(const Duration(minutes: 30));
    cubit.didChangeAppLifecycleState(AppLifecycleState.resumed);

    // Still paused — lifecycle changes only affect the `running` state.
    expect(cubit.state, isA<SessionTimerPaused>());
  });
}
