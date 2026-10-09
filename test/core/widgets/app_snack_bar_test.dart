import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_radius.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_snack_bar.dart';

void main() {
  Widget wrap({ThemeData? theme}) => MaterialApp(
    theme: theme ?? AppTheme.light,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.showAppSnackBar('Saved'),
            child: const Text('Show'),
          ),
        ),
      ),
    ),
  );

  testWidgets('is top-center, rounded, and dismisses automatically', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    final snack = find.byType(Dismissible);
    final rect = tester.getRect(snack);
    expect(rect.top, 12);
    expect(rect.center.dx, 400);
    expect(rect.width, lessThanOrEqualTo(480));
    final material = tester.widget<Material>(
      find.descendant(of: snack, matching: find.byType(Material)),
    );
    expect(material.borderRadius, BorderRadius.circular(AppRadius.md));

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('replaces the current message and can be swiped away', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(theme: AppTheme.dark));
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    await tester.fling(find.byType(Dismissible), const Offset(0, -200), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('respects the safe area on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    final rect = tester.getRect(find.byType(Dismissible));
    expect(rect.top, 56);
    expect(rect.center.dx, 180);
    expect(rect.left, greaterThanOrEqualTo(16));
    expect(rect.right, lessThanOrEqualTo(344));
  });

  testWidgets('cleans up its timer when the app is removed', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });
}
