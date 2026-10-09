import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/chunky_button.dart';
import 'package:mobile/features/stats/presentation/widgets/streak_modal.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  testWidgets('uses the primary button to dismiss the streak modal', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  StreakModal.show(context, current: 3, longest: 5),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(StreakModal), findsOneWidget);
    expect(find.byType(ChunkyButton), findsOneWidget);

    await tester.tap(find.text('Awesome!'));
    await tester.pumpAndSettle();

    expect(find.byType(StreakModal), findsNothing);
  });
}
