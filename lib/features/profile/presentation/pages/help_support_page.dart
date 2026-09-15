import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';

/// Static placeholder — no support ticketing system exists yet, just a
/// contact point.
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpAndSupport)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(l10n.helpAndSupportBody, style: AppTypography.body),
      ),
    );
  }
}
