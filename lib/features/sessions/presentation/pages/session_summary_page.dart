import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/sharing/models/session_share_data.dart';
import '../../../../core/sharing/widgets/share_card_preview_sheet.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../badges/presentation/widgets/badge_unlocked_modal.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../cubit/session_timer_cubit.dart';
import '../cubit/session_timer_state.dart';

/// Expects a `SessionTimerCubit` already provided by the caller (same
/// instance as `SessionTimerPage`, passed via `BlocProvider.value`) — this
/// page never creates its own.
class SessionSummaryPage extends StatefulWidget {
  const SessionSummaryPage({super.key, required this.userBook});

  final UserBook userBook;

  @override
  State<SessionSummaryPage> createState() => _SessionSummaryPageState();
}

class _SessionSummaryPageState extends State<SessionSummaryPage> {
  late final _startPageController =
      TextEditingController(text: widget.userBook.currentPage.toString());
  final _endPageController = TextEditingController();

  // A late `onSyncedWithBadges` callback can re-emit `SessionTimerSubmitted`
  // after the badges already showed once — track which ones we've already
  // popped the modal for so it never shows twice.
  final Set<String> _shownBadgeIds = {};

  // The duration lives in the (transient) `SessionTimerStopped` state, but the
  // page is still on screen after `submit()` moved the Cubit to
  // `SessionTimerSubmitted` — kept here so the final duration stays readable
  // (and shareable) once the session is saved.
  int _activeDurationSeconds = 0;
  int? _submittedStartPage;
  int? _submittedEndPage;

  @override
  void initState() {
    super.initState();
    final state = context.read<SessionTimerCubit>().state;
    if (state is SessionTimerStopped) {
      _activeDurationSeconds = state.activeDurationSeconds;
    }
  }

  @override
  void dispose() {
    _startPageController.dispose();
    _endPageController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final startPage =
        int.tryParse(_startPageController.text) ?? widget.userBook.currentPage;
    final endPage = int.tryParse(_endPageController.text) ?? startPage;
    _submittedStartPage = startPage;
    _submittedEndPage = endPage;
    context.read<SessionTimerCubit>().submit(startPage: startPage, endPage: endPage);
  }

  int get _pagesRead {
    final start = _submittedStartPage;
    final end = _submittedEndPage;
    if (start == null || end == null) return 0;
    return end > start ? end - start : 0;
  }

  double _speedPpm(int pagesRead) {
    if (_activeDurationSeconds <= 0) return 0;
    return pagesRead / (_activeDurationSeconds / 60);
  }

  /// Re-fetched (not read off `AuthCubit`'s cached user) right before opening
  /// the sheet: `current_streak` is updated by an ASYNC stats→auth path after
  /// a session is recorded, so a stale cached user would show yesterday's
  /// streak. A failed fetch just drops the badge — never blocks sharing.
  Future<int?> _freshStreakDays() async {
    final result = await getIt<GetCurrentUser>().call();
    return result.fold((_) => null, (user) {
      return user.currentStreak > 0 ? user.currentStreak : null;
    });
  }

  Future<void> _shareSession(BuildContext context) async {
    final pagesRead = _pagesRead;
    final streakDays = await _freshStreakDays();

    if (!context.mounted) return;

    await ShareCardPreviewSheet.show(
      context,
      data: SessionShareData(
        bookTitle: widget.userBook.book.title,
        bookAuthors: widget.userBook.book.authors,
        bookCoverUrl: widget.userBook.book.coverUrl,
        pagesRead: pagesRead,
        durationSeconds: _activeDurationSeconds,
        speedPpm: _speedPpm(pagesRead),
        sessionDate: DateTime.now(),
        streakDays: streakDays,
      ),
    );
  }

  Future<void> _showNewBadges(BuildContext context, SessionTimerSubmitted state) async {
    for (final badge in state.badgesUnlocked) {
      if (!_shownBadgeIds.add(badge.badgeId)) continue;
      if (!context.mounted) return;
      await BadgeUnlockedModal.show(
        context,
        name: badge.name,
        description: badge.description,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionSummary)),
      body: SafeArea(
        child: BlocConsumer<SessionTimerCubit, SessionTimerState>(
          listener: (context, state) {
            if (state is SessionTimerStopped) {
              _activeDurationSeconds = state.activeDurationSeconds;
            } else if (state is SessionTimerError) {
              context.showFailureSnackBar(state.failure);
            } else if (state is SessionTimerSubmitted && state.badgesUnlocked.isNotEmpty) {
              _showNewBadges(context, state);
            }
          },
          builder: (context, state) {
            final isSubmitting = state is SessionTimerSubmitting;
            final submitted = state is SessionTimerSubmitted ? state : null;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.totalDuration, style: AppTypography.caption),
                        const SizedBox(height: 4),
                        Text(
                          formatSessionDuration(
                            Duration(seconds: _activeDurationSeconds),
                          ),
                          style: AppTypography.displaySm,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startPageController,
                        enabled: submitted == null,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.startPage),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _endPageController,
                        enabled: submitted == null,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.endPage),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (submitted != null || isSubmitting)
                      ? null
                      : () => _submit(context),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(submitted != null ? l10n.sessionSaved : l10n.saveSession),
                ),
                if (submitted != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _shareSession(context),
                    icon: const Icon(Icons.ios_share, size: 18),
                    label: Text(l10n.share),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
