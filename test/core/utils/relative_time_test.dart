import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile/core/utils/relative_time.dart';
import 'package:mobile/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 3, 14, 12);

  setUpAll(() async {
    // In the app the localization delegates do this; a pure unit test has to
    // ask for the date symbols itself.
    await initializeDateFormatting('en');
  });

  String at(Duration ago) => formatRelativeTime(
    l10n: l10n,
    locale: 'en',
    occurredAt: now.subtract(ago),
    now: now,
  );

  test('anything under a minute reads as just now', () {
    expect(at(Duration.zero), 'Just now');
    expect(at(const Duration(seconds: 59)), 'Just now');
  });

  test('minutes, hours and days each get their own unit', () {
    expect(at(const Duration(minutes: 1)), '1m ago');
    expect(at(const Duration(minutes: 59)), '59m ago');
    expect(at(const Duration(hours: 1)), '1h ago');
    expect(at(const Duration(hours: 23)), '23h ago');
    expect(at(const Duration(days: 1)), '1d ago');
    expect(at(const Duration(days: 6)), '6d ago');
  });

  test('past a week it is a date, not a growing day count', () {
    final week = at(const Duration(days: 7));
    expect(week, isNot(contains('ago')));

    final month = at(const Duration(days: 30));
    expect(month, isNot(contains('ago')));
    expect(month, contains('2026'));
  });
}
