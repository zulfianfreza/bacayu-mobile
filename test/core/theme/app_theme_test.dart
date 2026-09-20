import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Material 3 derives a whole set of container colours from the seed, and every
/// one of them comes out a shade of the app's tangerine. These are the surfaces
/// that have to stay white anyway, pinned here so a seed change or a dropped
/// override cannot quietly turn them warm again.
void main() {
  Future<void> pump(WidgetTester tester, Widget home) => tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: home),
      );

  /// The `Material` the app bar itself paints on, which is the one that carries
  /// the tint.
  Material appBarMaterial(WidgetTester tester) => tester.widget<Material>(
        find
            .descendant(of: find.byType(AppBar), matching: find.byType(Material))
            .first,
      );

  testWidgets('an app bar stays white while content scrolls under it', (
    tester,
  ) async {
    await pump(
      tester,
      Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: ListView.builder(
          itemCount: 40,
          itemBuilder: (_, index) => SizedBox(height: 40, child: Text('$index')),
        ),
      ),
    );

    expect(appBarMaterial(tester).color, AppColors.surface);

    // Scrolling is what flips the bar into its `scrolledUnder` state, and that
    // is the one state where Material 3 overlays `colorScheme.surfaceTint` —
    // seeded tangerine — on top of the background.
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    final bar = appBarMaterial(tester);
    expect(bar.color, AppColors.surface);
    expect(bar.surfaceTintColor, Colors.transparent);
    expect(bar.elevation, 0);
  });

  testWidgets('a modal sheet opens on white, not a seeded container', (
    tester,
  ) async {
    await pump(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => const SizedBox(
                  width: double.infinity,
                  height: 120,
                ),
              ),
              child: const Text('Buka'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();

    final sheet = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(sheet.color, AppColors.surface);
  });

  testWidgets('the date picker opens on white, header included', (tester) async {
    await pump(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showDatePicker(
                context: context,
                initialDate: DateTime(2026, 1, 15),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              ),
              child: const Text('Tanggal'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tanggal'));
    await tester.pumpAndSettle();

    final dialog = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(DatePickerDialog),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(dialog.color, AppColors.surface);
  });
}
