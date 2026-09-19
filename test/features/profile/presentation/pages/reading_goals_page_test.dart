import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/profile/presentation/pages/reading_goals_page.dart';
import 'package:mobile/l10n/app_localizations.dart';

User _user({int? yearlyGoalBooks, int? dailyGoalMinutes}) => User(
  id: 'u1',
  email: 'reader@bacayu.app',
  name: 'Julian',
  avatarUrl: '',
  timezone: 'UTC',
  favoriteGenres: const [],
  yearlyGoalBooks: yearlyGoalBooks,
  dailyGoalMinutes: dailyGoalMinutes,
  currentStreak: 3,
  longestStreak: 5,
  lastReadDate: null,
  privacyDefault: 'private',
  onboardingCompletedAt: DateTime(2026, 1, 1),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  Future<void> pumpGoals(WidgetTester tester, User user) async {
    // Wider than a phone: the test font is far wider than Nunito, and the
    // stepper row would otherwise be the thing overflowing.
    tester.view.physicalSize = const Size(700 * 2, 1200 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        // Pinned to the app's primary locale so the assertions below can name
        // the strings it actually ships with.
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ReadingGoalsPage(user: user),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows both goals with the user\'s saved values', (tester) async {
    await pumpGoals(tester, _user(yearlyGoalBooks: 12, dailyGoalMinutes: 20));

    expect(find.text('Target baca setahun'), findsOneWidget);
    expect(find.text('12 buku/tahun'), findsOneWidget);
    expect(find.text('Target membaca harian'), findsOneWidget);
    expect(find.text('20 menit/hari'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the plus tile raises the goal it belongs to', (tester) async {
    await pumpGoals(tester, _user(yearlyGoalBooks: 12, dailyGoalMinutes: 20));

    // Yearly is the first card, so its controls come first.
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pump();

    expect(find.text('13 buku/tahun'), findsOneWidget);
    // The other goal is untouched.
    expect(find.text('20 menit/hari'), findsOneWidget);
  });

  testWidgets('the minus tile goes flat at the goal\'s floor', (tester) async {
    await pumpGoals(tester, _user(yearlyGoalBooks: 1, dailyGoalMinutes: 5));

    await tester.tap(find.byIcon(Icons.remove_rounded).first);
    await tester.pump();

    expect(find.text('1 buku/tahun'), findsOneWidget);
    expect(find.text('5 menit/hari'), findsOneWidget);
  });
}
