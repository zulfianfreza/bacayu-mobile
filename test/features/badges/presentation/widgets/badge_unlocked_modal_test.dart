import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/badges/presentation/widgets/badge_artwork.dart';
import 'package:mobile/features/badges/presentation/widgets/badge_unlocked_modal.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('renders the badge content and plays its pop-in animation',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        const BadgeUnlockedModal(
          name: 'First Step',
          description: 'You started your first session',
        ),
      ),
    );

    expect(find.text('First Step'), findsOneWidget);
    // Badge art is an image now — the bundled placeholder stands in until the
    // backend sends `image_url`.
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                BadgeArtwork.placeholderAsset,
      ),
      findsOneWidget,
    );
    expect(find.text('You started your first session'), findsOneWidget);

    // Right after the first frame, the pop-in animation (easeOutBack,
    // 400ms) hasn't reached rest yet. Scoped to a descendant of our widget
    // specifically — MaterialApp's default route transition also uses a
    // ScaleTransition of its own.
    final scaleTransition = tester.widget<ScaleTransition>(
      find.descendant(
        of: find.byType(BadgeUnlockedModal),
        matching: find.byType(ScaleTransition),
      ),
    );
    expect(scaleTransition.scale.value, lessThan(1.0));

    await tester.pumpAndSettle();

    // Same Animation object, now settled at its end value.
    expect(scaleTransition.scale.value, closeTo(1.0, 0.01));
  });

  testWidgets('show() displays the modal, and the dismiss button closes it',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => BadgeUnlockedModal.show(
              context,
              name: 'Bookworm',
              description: 'Finish 10 books',
            ),
            child: const Text('trigger'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    expect(find.text('Bookworm'), findsOneWidget);

    await tester.tap(find.text('Awesome!'));
    await tester.pumpAndSettle();

    expect(find.text('Bookworm'), findsNothing);
  });
}
