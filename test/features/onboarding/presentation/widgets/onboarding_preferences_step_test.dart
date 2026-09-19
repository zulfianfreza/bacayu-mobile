import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/chunky_button.dart';
import 'package:mobile/features/onboarding/presentation/widgets/onboarding_preferences_step.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Future<void> pumpStep(
    WidgetTester tester, {
    required void Function(List<String>, int) onSubmit,
    bool isSaving = false,
  }) async {
    // Wider than a phone: the test font is far wider than Nunito, and the
    // genre wrap would otherwise be the thing overflowing.
    tester.view.physicalSize = const Size(700 * 2, 1600 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        // Pinned to the app's primary locale so the assertions below can name
        // the strings it actually ships with.
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: OnboardingPreferencesStep(
            onSubmit: onSubmit,
            isSaving: isSaving,
          ),
        ),
      ),
    );
    // A saving step shows a spinner, which never settles — so that case gets a
    // single pump instead of pumpAndSettle.
    if (isSaving) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  testWidgets('picked genres and a raised goal are what gets submitted', (
    tester,
  ) async {
    List<String>? genres;
    int? goal;
    await pumpStep(
      tester,
      onSubmit: (g, y) {
        genres = g;
        goal = y;
      },
    );

    expect(find.text('Kamu suka baca apa?'), findsOneWidget);
    expect(find.text('12 buku/tahun'), findsOneWidget);

    await tester.tap(find.text('Fiksi'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(find.text('13 buku/tahun'), findsOneWidget);

    await tester.tap(find.text('Lanjut'));
    await tester.pump();

    expect(genres, ['fiction']);
    expect(goal, 13);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a picked genre again removes it', (tester) async {
    List<String>? genres;
    await pumpStep(tester, onSubmit: (g, _) => genres = g);

    await tester.tap(find.text('Fiksi'));
    await tester.pump();
    await tester.tap(find.text('Fiksi'));
    await tester.pump();
    await tester.tap(find.text('Lanjut'));
    await tester.pump();

    expect(genres, isEmpty);
  });

  testWidgets('while saving, the continue button is disabled', (tester) async {
    var submitted = false;
    await pumpStep(
      tester,
      isSaving: true,
      onSubmit: (_, _) => submitted = true,
    );

    // Saving swaps the label for a spinner, so the button is found by type.
    await tester.tap(find.byType(ChunkyButton));
    await tester.pump();

    expect(submitted, isFalse);
  });
}
