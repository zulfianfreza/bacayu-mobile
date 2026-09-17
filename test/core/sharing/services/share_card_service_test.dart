import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/sharing/services/share_card_service.dart';

void main() {
  const service = ShareCardService();

  test('captureCard throws a StateError when the boundary is not mounted',
      () async {
    await expectLater(
      service.captureCard(GlobalKey()),
      throwsA(isA<StateError>()),
    );
  });

  testWidgets('captureCard rasterizes the boundary into PNG bytes',
      (tester) async {
    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: Container(
              width: 100,
              height: 50,
              color: const Color(0xFFFF6A3D),
            ),
          ),
        ),
      ),
    );

    // toImage() needs the real engine's rasterizer, not the test's fake clock.
    final bytes = await tester.runAsync(() => service.captureCard(key));

    expect(bytes, isNotNull);
    expect(
      bytes!.sublist(0, 8),
      [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
      reason: 'expected a real PNG payload',
    );

    // 3x the logical size of the boundary — the exported card has to survive
    // being scaled up by Instagram/WhatsApp.
    final decoded = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    });
    expect(decoded!.width, 300);
    expect(decoded.height, 150);
  });
}
