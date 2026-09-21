import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/sharing/models/session_share_data.dart';
import 'package:mobile/core/sharing/services/share_card_service.dart';
import 'package:mobile/core/sharing/widgets/session_share_card.dart';
import 'package:mobile/core/sharing/widgets/share_card_preview_sheet.dart';
import 'package:mobile/core/widgets/chunky_button.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockShareCardService extends Mock implements ShareCardService {}

void main() {
  late _MockShareCardService service;
  late int captureCount;
  late List<Uint8List> shared;
  late List<Uint8List> downloaded;

  final data = SessionShareData(
    bookTitle: 'The Hobbit',
    bookAuthors: const [],
    bookCoverUrl: null,
    pagesRead: 24,
    durationSeconds: 1800,
    speedPpm: 0.8,
  );

  setUpAll(() {
    registerFallbackValue(GlobalKey());
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(Rect.zero);
  });

  setUp(() {
    service = _MockShareCardService();
    captureCount = 0;
    shared = [];
    downloaded = [];

    // Every capture returns different bytes, so an assertion can tell WHICH
    // page's image actually reached the share sheet / gallery.
    when(() => service.captureCard(any())).thenAnswer((_) async {
      captureCount++;
      return Uint8List.fromList([captureCount]);
    });
    when(
      () => service.shareSessionCard(
        any(),
        sharePositionOrigin: any(named: 'sharePositionOrigin'),
      ),
    ).thenAnswer((invocation) async {
      shared.add(invocation.positionalArguments.first as Uint8List);
    });
    when(() => service.downloadSessionCard(any())).thenAnswer((
      invocation,
    ) async {
      downloaded.add(invocation.positionalArguments.first as Uint8List);
    });
  });

  Widget app() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ShareCardPreviewSheet.show(
              context,
              data: data,
              service: service,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> tapShare(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ChunkyButton, 'Share'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Share then Download on the same carousel page captures the card once '
    'and reuses those bytes',
    (tester) async {
      await openSheet(tester);

      await tapShare(tester);
      expect(captureCount, 1);
      expect(shared, hasLength(1));

      await tester.tap(find.widgetWithText(ChunkyButton, 'Download'));
      await tester.pumpAndSettle();

      // No second capture — the style on screen hasn't changed.
      expect(captureCount, 1);
      expect(downloaded.single, shared.single);

      // The confirmation has to be visible once the sheet is out of the way.
      expect(find.text('Saved to gallery'), findsOneWidget);
    },
  );

  testWidgets(
    'swiping to another style re-captures, and each action gets the bytes '
    'of the page currently on screen',
    (tester) async {
      await openSheet(tester);

      await tapShare(tester);
      expect(captureCount, 1);

      // Swipe the carousel to the second style.
      await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();

      await tapShare(tester);

      // A different widget is on screen, so the cached capture must be dropped.
      expect(captureCount, 2);
      expect(shared, hasLength(2));
      expect(shared[0], Uint8List.fromList([1]));
      expect(shared[1], Uint8List.fromList([2]));
    },
  );

  testWidgets(
    'the transparent preset explains itself, and only that preset does',
    (tester) async {
      await openSheet(tester);
      expect(
        find.text('Transparent sticker. Place it over your own photo.'),
        findsNothing,
      );

      // Swipe past the cover and flat presets to the sticker.
      await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();
      expect(
        find.text('Transparent sticker. Place it over your own photo.'),
        findsNothing,
      );

      await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();
      expect(
        find.text('Transparent sticker. Place it over your own photo.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'the transparent preset previews on a transparency checkerboard',
    (tester) async {
      await openSheet(tester);

      // Past the cover and flat presets to the sticker.
      await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();

      expect(
        find.byKey(ShareCardPreviewSheet.stickerBackdropKey),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'the transparent preset washes its preview dark, but never the export',
    (tester) async {
      await openSheet(tester);

      // Past the cover and flat presets to the sticker.
      await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();

      final backdrop = find.byKey(ShareCardPreviewSheet.stickerBackdropKey);
      expect(backdrop, findsOneWidget);

      // It is preview chrome: outside the captured card, so the downloaded PNG
      // stays transparent.
      expect(
        find.descendant(of: find.byType(SessionShareCard), matching: backdrop),
        findsNothing,
      );
    },
  );

  testWidgets('a failed capture surfaces a localized error and re-enables the '
      'buttons', (tester) async {
    when(
      () => service.captureCard(any()),
    ).thenThrow(StateError('Share card is not mounted for capture'));

    await openSheet(tester);
    await tapShare(tester);

    expect(find.text("Couldn't share. Please try again."), findsOneWidget);

    final shareButton = tester.widget<ChunkyButton>(
      find.widgetWithText(ChunkyButton, 'Share'),
    );
    expect(shareButton.onPressed, isNotNull);
  });
}
