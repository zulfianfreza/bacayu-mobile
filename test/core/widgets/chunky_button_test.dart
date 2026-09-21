import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/chunky_button.dart';
import 'package:mobile/core/widgets/raised_box.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('tapping fires the callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(ChunkyButton(label: 'Log in', onPressed: () => taps++)),
    );

    await tester.tap(find.text('Log in'));
    expect(taps, 1);
  });

  testWidgets('a null onPressed disables it', (tester) async {
    await tester.pumpWidget(
      wrap(const ChunkyButton(label: 'Log in', onPressed: null)),
    );

    await tester.tap(find.text('Log in'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('while loading it shows a spinner and swallows taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        ChunkyButton(label: 'Log in', onPressed: () => taps++, isLoading: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Log in'), findsNothing);

    await tester.tap(find.byType(ChunkyButton));
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('pressing sinks the body onto its edge without moving anything '
      'around it', (tester) async {
    await tester.pumpWidget(
      wrap(ChunkyButton(label: 'Log in', onPressed: () {})),
    );
    final resting = tester.getRect(find.byType(ChunkyButton));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Log in')),
    );
    await tester.pump();
    final pressed = tester.getRect(find.byType(ChunkyButton));

    // The box keeps its footprint; only the body inside it moves down.
    expect(pressed, resting);

    await gesture.up();
    await tester.pump();
    expect(tester.getRect(find.byType(ChunkyButton)), resting);
  });

  testWidgets('the secondary variant is outlined, not slabbed', (tester) async {
    await tester.pumpWidget(
      wrap(
        ChunkyButton(
          label: 'Download',
          variant: ChunkyButtonVariant.secondary,
          onPressed: () {},
        ),
      ),
    );

    final border = (tester
            .widget<Container>(
              find
                  .descendant(
                    of: find.byType(RaisedBox),
                    matching: find.byType(Container),
                  )
                  .last,
            )
            .decoration! as BoxDecoration)
        .border! as Border;

    // A neutral body on a same-coloured surface needs all sides drawn, or it
    // reads as a stray line under a label.
    expect(border.top.width, RaisedBox.outlineWidth);
    expect(border.left.width, RaisedBox.outlineWidth);
    expect(border.right.width, RaisedBox.outlineWidth);
  });

  testWidgets('the primary variant keeps its solid slab', (tester) async {
    await tester.pumpWidget(
      wrap(ChunkyButton(label: 'Share', onPressed: () {})),
    );

    final body = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(RaisedBox),
            matching: find.byType(Container),
          )
          .last,
    );

    expect((body.decoration! as BoxDecoration).border, isNull);
  });
}
