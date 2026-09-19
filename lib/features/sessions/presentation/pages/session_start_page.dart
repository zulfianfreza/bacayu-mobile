import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../widgets/session_book_header.dart';
import 'manual_session_page.dart';
import 'session_timer_page.dart';

/// Shown right after a book is picked: log this session live with the timer, or
/// enter it by hand. Both paths replace this page, so backing out of either
/// returns to where the flow started rather than here.
class SessionStartPage extends StatelessWidget {
  const SessionStartPage({super.key, required this.userBook});

  final UserBook userBook;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionModeTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SessionBookHeader(userBook: userBook),
            const SizedBox(height: 24),
            Text(l10n.chooseSessionMode, style: AppTypography.displaySm),
            const SizedBox(height: 20),
            ChunkyButton(
              label: l10n.startTimerOption,
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => SessionTimerPage(initialUserBook: userBook),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startTimerOptionBody,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ChunkyButton(
              label: l10n.addManually,
              variant: ChunkyButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ManualSessionPage(userBook: userBook),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addManualOptionBody,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
