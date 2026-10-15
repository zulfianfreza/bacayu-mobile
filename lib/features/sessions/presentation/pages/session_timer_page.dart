import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/session_timer_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/build_context_extension.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/sheet_header.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../cubit/session_timer_cubit.dart';
import '../cubit/session_timer_state.dart';
import '../session_live_activity.dart';
import '../widgets/book_picker_bottom_sheet.dart';
import '../widgets/pause_button.dart';
import '../widgets/pulsing_circles.dart';
import '../widgets/timer_display.dart';
import 'session_summary_page.dart';

class SessionTimerPage extends StatelessWidget {
  const SessionTimerPage({super.key, this.initialUserBook});
  final UserBook? initialUserBook;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<SessionTimerCubit>(),
    child: _SessionTimerView(initialUserBook: initialUserBook),
  );
}

class _SessionTimerView extends StatefulWidget {
  const _SessionTimerView({this.initialUserBook});
  final UserBook? initialUserBook;
  @override
  State<_SessionTimerView> createState() => _SessionTimerViewState();
}

class _SessionTimerViewState extends State<_SessionTimerView>
    with WidgetsBindingObserver {
  UserBook? _selectedBook;
  bool _showSummary = false;
  bool _discardConfirmed = false;
  bool _confirmingDiscard = false;
  final _liveActivity = SessionLiveActivity();
  bool _applyingNative = false;
  Future<void> _nativeSync = Future.value();

  Future<void> _syncNative() {
    return _nativeSync = _nativeSync.then((_) async {
      if (!mounted) return;
      final cubit = context.read<SessionTimerCubit>();
      _applyingNative = true;
      try {
        await _liveActivity.consumeEvents((paused, at) {
          if (!mounted || cubit.isClosed) return;
          paused ? cubit.pause(at: at) : cubit.resume(at: at);
        });
      } finally {
        _applyingNative = false;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _syncNative();
  }

  void _updateActivity(SessionTimerState state) {
    if (_applyingNative) return;
    final (elapsed, paused) = switch (state) {
      SessionTimerRunning(:final elapsed) => (elapsed, false),
      SessionTimerPaused(:final elapsed) => (elapsed, true),
      _ => (null, false),
    };
    if (elapsed == null) {
      _liveActivity.end();
      return;
    }
    _liveActivity.update(
      title: _selectedBook!.book.title,
      status: paused ? context.l10n.timerPaused : context.l10n.timerRunning,
      elapsed: elapsed,
      paused: paused,
      tint: SessionTimerTheme.background.toARGB32(),
      runningLabel: context.l10n.timerRunning,
      pausedLabel: context.l10n.timerPaused,
      pauseLabel: context.l10n.timerPause,
      resumeLabel: context.l10n.timerResume,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SessionLiveActivity.channel.setMethodCallHandler(null);
    _liveActivity.end();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SessionLiveActivity.channel.setMethodCallHandler((call) async {
      if (call.method == 'changed') await _syncNative();
    });
    _selectedBook = widget.initialUserBook;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_selectedBook == null) {
        _selectedBook = await showModalBottomSheet<UserBook>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (_) => const BookPickerBottomSheet(),
        );
        if (!mounted) return;
        if (_selectedBook == null) {
          Navigator.of(context).pop();
          return;
        }
        setState(() {});
      }
      context.read<SessionTimerCubit>().start(userBookId: _selectedBook!.id);
      _updateActivity(context.read<SessionTimerCubit>().state);
    });
  }

  Future<void> _confirmDiscard() async {
    if (_confirmingDiscard) return;
    _confirmingDiscard = true;
    final l10n = context.l10n;
    final discard = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SessionTimerTheme.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetHeader(title: l10n.timerClose),
              const SizedBox(height: SessionTimerTheme.gap),
              Text(
                l10n.timerDiscardMessage,
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
              const SizedBox(height: SessionTimerTheme.padding),
              Semantics(
                button: true,
                child: ChunkyButton(
                  label: l10n.timerKeepReading,
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(height: SessionTimerTheme.gap),
              Semantics(
                button: true,
                child: ChunkyButton(
                  label: l10n.timerDiscard,
                  variant: ChunkyButtonVariant.secondary,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    _confirmingDiscard = false;
    if (!mounted || discard != true) return;
    setState(() => _discardConfirmed = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = _selectedBook;
    if (book == null) return const Scaffold(body: SizedBox.shrink());
    // Keep the provider alive so stopping can hand the session to the summary.
    if (_showSummary) return SessionSummaryPage(userBook: book);
    final l10n = context.l10n;
    return PopScope(
      canPop: _discardConfirmed,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: SessionTimerTheme.background,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: SessionTimerTheme.gradient,
              ),
            ),
            child: SafeArea(
              child: BlocConsumer<SessionTimerCubit, SessionTimerState>(
                listenWhen: (previous, current) =>
                    previous is! SessionTimerIdle &&
                    previous.runtimeType != current.runtimeType,
                listener: (context, state) {
                  _updateActivity(state);
                  if (state is SessionTimerStopped) {
                    setState(() => _showSummary = true);
                  }
                },
                builder: (context, state) {
                  final (elapsed, paused) = switch (state) {
                    SessionTimerRunning(:final elapsed) => (elapsed, false),
                    SessionTimerPaused(:final elapsed) => (elapsed, true),
                    _ => (Duration.zero, false),
                  };
                  return LayoutBuilder(
                    builder: (context, constraints) => Padding(
                      padding: const EdgeInsets.all(SessionTimerTheme.padding),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: SessionTimerTheme.maxWidth,
                            minHeight:
                                (constraints.maxHeight -
                                        SessionTimerTheme.padding * 2)
                                    .clamp(0, double.infinity),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    tooltip: l10n.timerClose,
                                    color: SessionTimerTheme.white.withValues(
                                      alpha: 0.8,
                                    ),
                                    icon: const Icon(Icons.close),
                                    onPressed: _confirmDiscard,
                                  ),
                                ],
                              ),
                              const SizedBox(height: SessionTimerTheme.padding),
                              Container(
                                padding: const EdgeInsets.all(
                                  SessionTimerTheme.gap,
                                ),
                                decoration: BoxDecoration(
                                  color: SessionTimerTheme.white.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                      child: SizedBox(
                                        width: SessionTimerTheme.touchSize,
                                        height:
                                            SessionTimerTheme.touchSize * 1.5,
                                        child: book.book.coverUrl == null
                                            ? const Icon(
                                                Icons.menu_book_rounded,
                                                color: SessionTimerTheme.white,
                                              )
                                            : Image.network(
                                                book.book.coverUrl!,
                                                fit: BoxFit.cover,
                                                excludeFromSemantics: true,
                                                errorBuilder:
                                                    (
                                                      _,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.menu_book_rounded,
                                                      color: SessionTimerTheme
                                                          .white,
                                                    ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: SessionTimerTheme.gap,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.book.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.subheading
                                                .copyWith(
                                                  color:
                                                      SessionTimerTheme.white,
                                                ),
                                          ),
                                          if (book.book.authors.isNotEmpty)
                                            Text(
                                              l10n.byAuthor(
                                                book.book.authors.join(', '),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color:
                                                        SessionTimerTheme.white,
                                                  ),
                                            ),
                                          if (book.book.totalPages != null &&
                                              book.book.totalPages! > 0)
                                            Text(
                                              l10n.pageProgress(
                                                book.currentPage,
                                                book.book.totalPages!,
                                              ),
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color:
                                                        SessionTimerTheme.white,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: SessionTimerTheme.gap),
                              Expanded(
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: SessionTimerTheme.circleSize,
                                    ),
                                    child: PulsingCircles(
                                      paused: paused,
                                      label: paused
                                          ? l10n.timerPaused
                                          : l10n.timerRunning,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: SessionTimerTheme.padding),
                              TimerDisplay(elapsed: elapsed),
                              const SizedBox(height: SessionTimerTheme.padding),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PauseButton(
                                    paused: paused,
                                    label: paused
                                        ? l10n.timerResume
                                        : l10n.timerPause,
                                    onPressed: () async {
                                      final cubit = context
                                          .read<SessionTimerCubit>();
                                      await _syncNative();
                                      if (!mounted) return;
                                      cubit.state is SessionTimerPaused
                                          ? cubit.resume()
                                          : cubit.pause();
                                    },
                                  ),
                                  const SizedBox(width: SessionTimerTheme.gap),
                                  IconButton(
                                    tooltip: l10n.timerStop,
                                    style: IconButton.styleFrom(
                                      foregroundColor: SessionTimerTheme.white,
                                      minimumSize: const Size(
                                        0,
                                        SessionTimerTheme.touchSize,
                                      ),
                                    ),
                                    icon: const Icon(Icons.stop),
                                    onPressed: () async {
                                      final cubit = context
                                          .read<SessionTimerCubit>();
                                      await _syncNative();
                                      if (!mounted) return;
                                      await _liveActivity.end();
                                      await _syncNative();
                                      if (mounted) cubit.stop();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
