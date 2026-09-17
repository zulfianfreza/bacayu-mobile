import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Compact "when" for a feed item — "Just now", "5m ago", "2h ago", "3d ago".
///
/// Past a week it falls back to a plain date: "312d ago" tells the reader
/// nothing they can use.
///
/// [now] is injectable so the branches can be tested without waiting.
String formatRelativeTime({
  required AppLocalizations l10n,
  required String locale,
  required DateTime occurredAt,
  DateTime? now,
}) {
  final elapsed = (now ?? DateTime.now()).difference(occurredAt);

  if (elapsed.inMinutes < 1) return l10n.timeJustNow;
  if (elapsed.inHours < 1) return l10n.timeMinutesAgo(elapsed.inMinutes);
  if (elapsed.inDays < 1) return l10n.timeHoursAgo(elapsed.inHours);
  if (elapsed.inDays < 7) return l10n.timeDaysAgo(elapsed.inDays);

  return DateFormat.yMMMd(locale).format(occurredAt);
}
