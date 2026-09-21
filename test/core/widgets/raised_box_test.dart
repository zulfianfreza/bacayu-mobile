import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/raised_box.dart';

/// The box is two nested `Container`s: the outer one is the edge (or, in
/// outline mode, the whole outline), the inner one is the body.
void main() {
  Future<void> pump(WidgetTester tester, RaisedBox box) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: box))),
      );

  List<Container> containersOf(WidgetTester tester) => tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(RaisedBox),
          matching: find.byType(Container),
        ),
      )
      .toList();

  BoxDecoration decorationOf(Container container) =>
      container.decoration! as BoxDecoration;

  testWidgets('without an outline the edge is a shade of the body', (
    tester,
  ) async {
    const body = Color(0xFFFF6A3D);
    await pump(tester, const RaisedBox(color: body, child: Text('x')));

    final (outer, inner) = (containersOf(tester)[0], containersOf(tester)[1]);

    expect(decorationOf(outer).color, edgeShadeOf(body));
    // The body carries no border at all: the slab is the whole edge.
    expect(decorationOf(inner).border, isNull);
  });

  testWidgets('an outline runs around the sides and top at the hairline '
      'width, and the base stays the edge height', (tester) async {
    const outline = Color(0xFFE2E8F0);
    await pump(
      tester,
      const RaisedBox(
        color: Colors.white,
        outlineColor: outline,
        child: Text('x'),
      ),
    );

    final (outer, inner) = (containersOf(tester)[0], containersOf(tester)[1]);
    final border = decorationOf(inner).border! as Border;

    // The base is the outer colour showing under the body, so the body's own
    // border must stop at the sides — no bottom line doubling it up.
    expect(decorationOf(outer).color, outline);
    expect(border.top.width, RaisedBox.outlineWidth);
    expect(border.left.width, RaisedBox.outlineWidth);
    expect(border.right.width, RaisedBox.outlineWidth);
    expect(border.bottom.width, 0);
    expect(border.top.color, outline);
  });

  testWidgets('the edge height is what the outline base shows', (tester) async {
    await pump(
      tester,
      const RaisedBox(
        color: Colors.white,
        outlineColor: Color(0xFFE2E8F0),
        edgeHeight: 6,
        child: Text('x'),
      ),
    );

    final outer = containersOf(tester)[0];
    expect(outer.padding, const EdgeInsets.only(bottom: 6));
  });
}
