import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';

/// Bottom sheet to switch the app's active locale — reads/writes
/// [LocaleCubit] directly (already provided at the app root in `app.dart`).
class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const LanguageBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentCode = context.watch<LocaleCubit>().state?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(l10n.language, style: AppTypography.heading),
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              label: l10n.languageEnglish,
              code: 'en',
              selected: currentCode == 'en',
            ),
            _LanguageOption(
              label: l10n.languageIndonesian,
              code: 'id',
              selected: currentCode == 'id',
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.code,
    required this.selected,
  });

  final String label;
  final String code;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: AppTypography.bodyStrong),
      trailing: selected ? const Icon(Icons.check, color: AppColors.tangerine500) : null,
      onTap: () {
        context.read<LocaleCubit>().setLocale(Locale(code));
        Navigator.of(context).pop();
      },
    );
  }
}
