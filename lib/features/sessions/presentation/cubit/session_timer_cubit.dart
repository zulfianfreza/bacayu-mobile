import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/reading_session.dart';
import '../../domain/usecases/submit_session.dart';
import 'session_timer_state.dart';

/// Offline-first, timestamp-based session timer — CLAUDE.md Section 6.
///
/// `active_duration_seconds` is always derived from timestamp differences
/// (`_startTime`, closed `_pauseIntervals`, an open `_currentPauseStart`,
/// and "now"), never from a `Timer.periodic` counter — that would drift
/// once the app backgrounds and OS-suspends timers (Section 6.1). The
/// `Timer.periodic` here (`_ticker`) exists ONLY to refresh the UI's MM:SS
/// display; it's stopped/restarted around backgrounding, but that never
/// touches the timestamp data itself.
///
/// If the app is killed while `running`/`paused` (before `Stop`), that's an
/// accepted reset — this Cubit starts fresh at `idle` next launch. No
/// recovery mechanism for that case, by design (Section 6 "Tahap A").
@injectable
class SessionTimerCubit extends Cubit<SessionTimerState>
    with WidgetsBindingObserver {
  SessionTimerCubit(this._submitSession) : super(const SessionTimerIdle()) {
    WidgetsBinding.instance.addObserver(this);
  }

  final SubmitSession _submitSession;

  DateTime Function() _clock = DateTime.now;

  /// Lets tests control "now" without waiting on real wall-clock time.
  @visibleForTesting
  void debugUseClock(DateTime Function() clock) => _clock = clock;

  Timer? _ticker;
  String? _clientId;
  String? _userBookId;
  DateTime? _startTime;
  DateTime? _endTime;
  DateTime? _currentPauseStart;
  final List<PauseInterval> _pauseIntervals = [];

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    return super.close();
  }

  void start({required String userBookId}) {
    _clientId = const Uuid().v4();
    _userBookId = userBookId;
    _startTime = _clock();
    _endTime = null;
    _currentPauseStart = null;
    _pauseIntervals.clear();
    _startTicker();
    emit(SessionTimerRunning(elapsed: Duration.zero, pauseCount: 0));
  }

  void pause() {
    if (state is! SessionTimerRunning) return;
    final now = _clock();
    _currentPauseStart = now;
    _stopTicker();
    emit(SessionTimerPaused(
      elapsed: _elapsedAt(now),
      pauseCount: _pauseIntervals.length,
    ));
  }

  void resume() {
    if (state is! SessionTimerPaused) return;
    final now = _clock();
    _pauseIntervals.add(PauseInterval(pausedAt: _currentPauseStart!, resumedAt: now));
    _currentPauseStart = null;
    _startTicker();
    emit(SessionTimerRunning(
      elapsed: _elapsedAt(now),
      pauseCount: _pauseIntervals.length,
    ));
  }

  void stop() {
    if (state is! SessionTimerRunning && state is! SessionTimerPaused) return;
    final now = _clock();
    _stopTicker();

    // Stopped while paused — close the trailing interval. The backend
    // requires every pause_interval to have a resumedAt (see
    // api/internal/features/sessions/domain/entity.go).
    if (_currentPauseStart != null) {
      _pauseIntervals.add(PauseInterval(pausedAt: _currentPauseStart!, resumedAt: now));
      _currentPauseStart = null;
    }

    _endTime = now;
    emit(SessionTimerStopped(
      activeDurationSeconds: _elapsedAt(now).inSeconds,
      pauseCount: _pauseIntervals.length,
    ));
  }

  Future<void> submit({required int startPage, required int endPage}) async {
    if (state is! SessionTimerStopped) return;
    final stopped = state as SessionTimerStopped;
    emit(const SessionTimerSubmitting());

    final session = ReadingSession(
      clientId: _clientId!,
      userBookId: _userBookId!,
      inputMode: 'timer',
      startTime: _startTime!,
      endTime: _endTime!,
      activeDurationSeconds: stopped.activeDurationSeconds,
      pauseIntervals: List.unmodifiable(_pauseIntervals),
      startPage: startPage,
      endPage: endPage,
    );

    final result = await _submitSession(
      session,
      onSyncedWithBadges: (badges) {
        if (isClosed) return;
        if (state is SessionTimerSubmitted) {
          emit(SessionTimerSubmitted(badgesUnlocked: badges));
        }
      },
    );

    result.fold(
      (failure) => emit(SessionTimerError(failure)),
      (_) => emit(const SessionTimerSubmitted(badgesUnlocked: [])),
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current is SessionTimerRunning) {
        emit(SessionTimerRunning(
          elapsed: _elapsedAt(_clock()),
          pauseCount: current.pauseCount,
        ));
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Duration _elapsedAt(DateTime now) {
    final total = now.difference(_startTime!);
    final closedPauses = _pauseIntervals.fold<Duration>(
      Duration.zero,
      (sum, p) => sum + p.resumedAt.difference(p.pausedAt),
    );
    final openPause = _currentPauseStart != null
        ? now.difference(_currentPauseStart!)
        : Duration.zero;
    return total - closedPauses - openPause;
  }

  // `state` would shadow Cubit's own `state` getter, which this method
  // needs to read.
  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    // Only the ticker cares about lifecycle — background is NOT a pause
    // (product decision: people lock their phone mid-read), so this never
    // touches _pauseIntervals/_currentPauseStart.
    final current = state;
    if (current is! SessionTimerRunning) return;

    switch (lifecycleState) {
      case AppLifecycleState.resumed:
        emit(SessionTimerRunning(
          elapsed: _elapsedAt(_clock()),
          pauseCount: current.pauseCount,
        ));
        _startTicker();
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _stopTicker();
      case AppLifecycleState.detached:
        break;
    }
  }
}
