import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/build_context_extension.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/option_tile.dart';
import '../../../../core/widgets/sheet_header.dart';

/// Bottom sheet to switch the app's appearance — reads/writes [ThemeCubit]
/// directly (already provided at the app root in `app.dart`).
///
/// Three choices, not a switch: "follow the system" is a real state a switch
/// cannot express, and it is the default.
class AppearanceBottomSheet extends StatelessWidget {
  const AppearanceBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      // The sheet chrome follows whichever mode is active — including while
      // the user is picking a different one.
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const AppearanceBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentMode = context.watch<ThemeCubit>().state;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(title: l10n.appearance),
            const SizedBox(height: 16),
            OptionTile(
              label: l10n.appearanceSystem,
              selected: currentMode == ThemeMode.system,
              onTap: () => _pick(context, ThemeMode.system),
            ),
            const SizedBox(height: 8),
            OptionTile(
              label: l10n.appearanceLight,
              selected: currentMode == ThemeMode.light,
              onTap: () => _pick(context, ThemeMode.light),
            ),
            const SizedBox(height: 8),
            OptionTile(
              label: l10n.appearanceDark,
              selected: currentMode == ThemeMode.dark,
              onTap: () => _pick(context, ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }

  void _pick(BuildContext context, ThemeMode mode) {
    context.read<ThemeCubit>().setMode(mode);
    Navigator.of(context).pop();
  }
}
