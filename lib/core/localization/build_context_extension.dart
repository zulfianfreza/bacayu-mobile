import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// `context.l10n.retry` instead of `AppLocalizations.of(context)!.retry` —
/// use this everywhere a widget needs a user-facing string.
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
