import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/bordered_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  Border borderOf(WidgetTester tester) {
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(BorderedCard),
            matching: find.byType(Container),
          )
          .first,
    );
    return (container.decoration! as BoxDecoration).border! as Border;
  }

  testWidgets('the base is thicker than the other three sides', (tester) async {
    await tester.pumpWidget(wrap(const BorderedCard(child: Text('x'))));

    final border = borderOf(tester);
    expect(border.top.width, BorderedCard.sideWidth);
    expect(border.left.width, BorderedCard.sideWidth);
    expect(border.right.width, BorderedCard.sideWidth);
    expect(border.bottom.width, BorderedCard.baseWidth);
    expect(border.bottom.width, greaterThan(border.top.width));
  });

  testWidgets('borders in slate by default, not the warm neutral', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const BorderedCard(child: Text('x'))));

    expect(borderOf(tester).top.color, AppColors.slate200);
  });

  testWidgets('a tinted card can pass its own border colour', (tester) async {
    await tester.pumpWidget(
      wrap(
        const BorderedCard(
          color: AppColors.sunshine100,
          borderColor: AppColors.sunshine300,
          child: Text('x'),
        ),
      ),
    );

    expect(borderOf(tester).bottom.color, AppColors.sunshine300);
  });
}
