import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/duration_formatter.dart';

void main() {
  group('formatSessionDuration', () {
    test('runs as a clock, padded', () {
      expect(formatSessionDuration(const Duration(seconds: 7)), '00:07');
      expect(formatSessionDuration(const Duration(minutes: 5, seconds: 3)),
          '05:03');
      expect(formatSessionDuration(const Duration(minutes: 46)), '46:00');
      expect(
        formatSessionDuration(const Duration(hours: 1, minutes: 46, seconds: 7)),
        '01:46:07',
      );
    });
  });

  group('formatSessionDurationWords', () {
    test('names every unit the duration reaches', () {
      expect(formatSessionDurationWords(const Duration(seconds: 7)), '7s');
      expect(
        formatSessionDurationWords(const Duration(minutes: 1, seconds: 8)),
        '1m 8s',
      );
      expect(
        formatSessionDurationWords(const Duration(minutes: 46, seconds: 7)),
        '46m 7s',
      );
      expect(
        formatSessionDurationWords(
          const Duration(hours: 1, minutes: 46, seconds: 7),
        ),
        '1h 46m 7s',
      );
      expect(
        formatSessionDurationWords(const Duration(hours: 2, minutes: 5)),
        '2h 5m',
      );
    });

    test('drops trailing zero seconds rather than saying them', () {
      expect(formatSessionDurationWords(const Duration(seconds: 30)), '30s');
      expect(formatSessionDurationWords(const Duration(minutes: 30)), '30m');
      expect(formatSessionDurationWords(const Duration(hours: 2)), '2h 0m');
    });

    test('never skips a unit between hours and seconds', () {
      // "1h 7s" would read as minutes at a glance.
      expect(
        formatSessionDurationWords(const Duration(hours: 1, seconds: 7)),
        '1h 0m 7s',
      );
    });

    test('a zero-length session still prints something', () {
      expect(formatSessionDurationWords(Duration.zero), '0s');
    });
  });
}
