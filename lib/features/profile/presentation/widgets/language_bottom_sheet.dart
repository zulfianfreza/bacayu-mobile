import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/option_tile.dart';
import '../../../../core/widgets/sheet_header.dart';

/// Bottom sheet to switch the app's active locale — reads/writes
/// [LocaleCubit] directly (already provided at the app root in `app.dart`).
class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const LanguageBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentCode =
        context.watch<LocaleCubit>().state?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(title: l10n.language),
            const SizedBox(height: 16),
            OptionTile(
              label: l10n.languageEnglish,
              selected: currentCode == 'en',
              onTap: () => _pick(context, 'en'),
            ),
            const SizedBox(height: 8),
            OptionTile(
              label: l10n.languageIndonesian,
              selected: currentCode == 'id',
              onTap: () => _pick(context, 'id'),
            ),
          ],
        ),
      ),
    );
  }

  void _pick(BuildContext context, String code) {
    context.read<LocaleCubit>().setLocale(Locale(code));
    Navigator.of(context).pop();
  }
}
