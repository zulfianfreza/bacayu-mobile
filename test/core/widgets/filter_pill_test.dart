import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/filter_pill.dart';
import 'package:mobile/core/widgets/raised_box.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('tapping fires the callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(FilterPill(label: 'Semua', isActive: false, onTap: () => taps++)),
    );

    await tester.tap(find.text('Semua'));
    expect(taps, 1);
  });

  testWidgets('the active pill is filled in with the brand colour', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(FilterPill(label: 'Semua', isActive: true, onTap: () {})),
    );

    expect(
      tester.widget<RaisedBox>(find.byType(RaisedBox)).color,
      AppColors.tangerine,
    );
  });

  testWidgets('an expanded pill shares the row and shrinks its label', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        Row(
          children: [
            Expanded(
              child: FilterPill(
                label: 'Minggu',
                isActive: false,
                onTap: () {},
                expand: true,
              ),
            ),
          ],
        ),
      ),
    );

    // The label is scaled down to the width it was given, never clipped.
    expect(find.byType(FittedBox), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
