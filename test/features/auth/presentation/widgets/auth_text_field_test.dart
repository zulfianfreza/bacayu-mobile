import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_text_field.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    required TextEditingController controller,
    String? icon,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthTextField(
            label: 'Email',
            controller: controller,
            icon: icon,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('carries its own label, visible at rest', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpField(tester, controller: controller);

    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('the glyph comes from an asset, not an IconData', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpField(
      tester,
      controller: controller,
      icon: 'assets/icons/mail-stroke.png',
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, 'assets/icons/mail-stroke.png');
    expect(find.byType(Icon), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a field with no glyph renders none', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpField(tester, controller: controller);

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('the glyph stays a small inset, not a full-height block', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpField(
      tester,
      controller: controller,
      icon: 'assets/icons/mail-stroke.png',
    );

    final glyph = tester.getSize(find.byType(Image));
    expect(glyph.width, 20);
    expect(glyph.height, 20);
    // And it must stay well clear of the field's own height.
    expect(glyph.height, lessThan(tester.getSize(find.byType(TextField)).height));
  });
}
