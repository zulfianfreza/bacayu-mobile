import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widget/streak_widget_service.dart';

void main() {
  test('state priority and time boundaries', () {
    expect(
      resolveWidgetState(
        readToday: true,
        currentStreak: 0,
        now: DateTime(2026),
      ),
      WidgetStreakState.repair,
    );
    expect(
      resolveWidgetState(
        readToday: false,
        currentStreak: 2,
        streakFrozen: true,
        now: DateTime(2026),
      ),
      WidgetStreakState.frozenSafe,
    );
    expect(
      resolveWidgetState(
        readToday: false,
        currentStreak: 2,
        now: DateTime(2026, 1, 1, 9, 59),
      ),
      WidgetStreakState.calm,
    );
    expect(
      resolveWidgetState(
        readToday: false,
        currentStreak: 2,
        now: DateTime(2026, 1, 1, 22, 0),
      ),
      WidgetStreakState.reminder,
    );
    expect(
      resolveWidgetState(
        readToday: false,
        currentStreak: 2,
        now: DateTime(2026, 1, 1, 23, 30),
      ),
      WidgetStreakState.urgent,
    );
    expect(
      resolveWidgetState(
        readToday: false,
        currentStreak: 2,
        now: DateTime(2026, 1, 1, 23, 31),
      ),
      WidgetStreakState.critical,
    );
  });
}
