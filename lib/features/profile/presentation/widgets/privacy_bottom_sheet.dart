import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/usecases/update_profile.dart';

const _options = ['private', 'followers', 'public'];

/// Bottom sheet to change the default activity visibility
/// (`User.privacyDefault`) — calls `UpdateProfile` directly, same
/// compose-usecases-in-the-widget pattern `onboarding` already uses for
/// small one-shot mutations that don't need a dedicated cubit.
class PrivacyBottomSheet extends StatefulWidget {
  const PrivacyBottomSheet({super.key, required this.currentValue});

  final String currentValue;

  /// Returns `true` if the value was changed, so the caller can refresh.
  static Future<bool?> show(BuildContext context, {required String currentValue}) {
    return showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => PrivacyBottomSheet(currentValue: currentValue),
    );
  }

  @override
  State<PrivacyBottomSheet> createState() => _PrivacyBottomSheetState();
}

class _PrivacyBottomSheetState extends State<PrivacyBottomSheet> {
  bool _isSaving = false;

  String _label(String value) {
    final l10n = context.l10n;
    return switch (value) {
      'private' => l10n.visibilityPrivate,
      'followers' => l10n.visibilityFollowers,
      'public' => l10n.visibilityPublic,
      _ => value,
    };
  }

  Future<void> _select(String value) async {
    if (_isSaving || value == widget.currentValue) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() => _isSaving = true);
    final result = await getIt<UpdateProfile>().call(privacyDefault: value);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _isSaving = false),
      (_) => Navigator.of(context).pop(true),
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
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(l10n.privacy, style: AppTypography.heading),
            ),
            const SizedBox(height: 8),
            for (final value in _options)
              ListTile(
                title: Text(_label(value), style: AppTypography.bodyStrong),
                trailing: value == widget.currentValue
                    ? const Icon(Icons.check, color: AppColors.tangerine500)
                    : null,
                onTap: _isSaving ? null : () => _select(value),
              ),
          ],
        ),
      ),
    );
  }
}
