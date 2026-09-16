import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/user_book.dart';

/// Bottom sheet listing the 4 [ShelfStatus] options — the current status is
/// highlighted and disabled (already selected, nothing to do). Picking a
/// different option pops the sheet with that [ShelfStatus]; the caller
/// (`ShelfBookCard`) is responsible for calling `ShelfCubit.updateStatus`.
class StatusPickerBottomSheet extends StatelessWidget {
  const StatusPickerBottomSheet({super.key, required this.currentStatus});

  final ShelfStatus currentStatus;

  static Future<ShelfStatus?> show(
    BuildContext context, {
    required ShelfStatus currentStatus,
  }) {
    return showModalBottomSheet<ShelfStatus>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => StatusPickerBottomSheet(currentStatus: currentStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(l10n.changeStatus, style: AppTypography.heading),
            ),
            const SizedBox(height: 8),
            _StatusOption(
              label: l10n.statusWantToRead,
              status: ShelfStatus.wantToRead,
              selected: currentStatus == ShelfStatus.wantToRead,
            ),
            _StatusOption(
              label: l10n.statusReading,
              status: ShelfStatus.reading,
              selected: currentStatus == ShelfStatus.reading,
            ),
            _StatusOption(
              label: l10n.statusFinished,
              status: ShelfStatus.finished,
              selected: currentStatus == ShelfStatus.finished,
            ),
            _StatusOption(
              label: l10n.statusDnf,
              status: ShelfStatus.dnf,
              selected: currentStatus == ShelfStatus.dnf,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.label,
    required this.status,
    required this.selected,
  });

  final String label;
  final ShelfStatus status;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: selected
            ? AppTypography.bodyStrong.copyWith(color: AppColors.tangerine500)
            : AppTypography.bodyStrong,
      ),
      trailing: selected ? const Icon(Icons.check, color: AppColors.tangerine500) : null,
      enabled: !selected,
      onTap: selected ? null : () => Navigator.of(context).pop(status),
    );
  }
}
