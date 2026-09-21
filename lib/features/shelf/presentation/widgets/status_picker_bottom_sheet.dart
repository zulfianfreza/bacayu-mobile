import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/option_tile.dart';
import '../../../../core/widgets/sheet_header.dart';
import '../../domain/entities/user_book.dart';
import '../../../../core/theme/build_context_extension.dart';

/// Bottom sheet listing the 4 [ShelfStatus] options — the current status is
/// highlighted and dead (already selected, nothing to do). Picking a different
/// option pops the sheet with that [ShelfStatus]; the caller (`ShelfBookCard`)
/// is responsible for calling `ShelfCubit.updateStatus`.
///
/// Same rows as the language and privacy pickers: one [OptionTile] per choice.
class StatusPickerBottomSheet extends StatelessWidget {
  const StatusPickerBottomSheet({super.key, required this.currentStatus});

  final ShelfStatus currentStatus;

  static Future<ShelfStatus?> show(
    BuildContext context, {
    required ShelfStatus currentStatus,
  }) {
    return showModalBottomSheet<ShelfStatus>(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => StatusPickerBottomSheet(currentStatus: currentStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = [
      (ShelfStatus.wantToRead, l10n.statusWantToRead),
      (ShelfStatus.reading, l10n.statusReading),
      (ShelfStatus.finished, l10n.statusFinished),
      (ShelfStatus.dnf, l10n.statusDnf),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(title: l10n.changeStatus),
            const SizedBox(height: 16),
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              OptionTile(
                label: options[i].$2,
                selected: options[i].$1 == currentStatus,
                // The current status is already set — tapping it is a no-op,
                // not a second way to close the sheet.
                onTap: options[i].$1 == currentStatus
                    ? null
                    : () => Navigator.of(context).pop(options[i].$1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
