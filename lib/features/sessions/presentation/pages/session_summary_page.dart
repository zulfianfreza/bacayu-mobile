import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/duration_formatter.dart';
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
    context.read<SessionTimerCubit>().submit(startPage: startPage, endPage: endPage);
  }

  Future<void> _showNewBadges(BuildContext context, SessionTimerSubmitted state) async {
    for (final badge in state.badgesUnlocked) {
      if (!_shownBadgeIds.add(badge.badgeId)) continue;
      if (!context.mounted) return;
      await BadgeUnlockedModal.show(
        context,
        name: badge.name,
        icon: badge.icon,
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
            if (state is SessionTimerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.localizedMessage(context))),
              );
            } else if (state is SessionTimerSubmitted && state.badgesUnlocked.isNotEmpty) {
              _showNewBadges(context, state);
            }
          },
          builder: (context, state) {
            final activeDurationSeconds = switch (state) {
              SessionTimerStopped(:final activeDurationSeconds) =>
                activeDurationSeconds,
              _ => 0,
            };
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
                            Duration(seconds: activeDurationSeconds),
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
              ],
            );
          },
        ),
      ),
    );
  }
}
