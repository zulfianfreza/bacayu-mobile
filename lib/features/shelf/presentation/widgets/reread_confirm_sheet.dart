import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/build_context_extension.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/sheet_header.dart';

/// Confirmation before a reread actually starts.
///
/// Separate from the status picker on purpose: a reread is not a status change,
/// it opens a *new* read and keeps the finished one as history, so it gets its
/// own explicit confirm. [show] returns `true` only when the user confirmed —
/// the caller must not call `StartReread` on a dismissal.
class RereadConfirmSheet extends StatelessWidget {
  const RereadConfirmSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const RereadConfirmSheet(),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(title: l10n.rereadConfirmTitle),
            const SizedBox(height: 16),
            Text(
              l10n.rereadConfirmBody,
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
            const SizedBox(height: 24),
            ChunkyButton(
              label: l10n.rereadStart,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 8),
            ChunkyButton(
              label: l10n.cancel,
              variant: ChunkyButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
