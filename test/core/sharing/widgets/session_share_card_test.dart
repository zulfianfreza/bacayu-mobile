import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/sharing/models/session_share_data.dart';
import 'package:mobile/core/sharing/models/share_card_theme.dart';
import 'package:mobile/core/sharing/widgets/session_share_card.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  SessionShareData buildData({
    String title = 'The Hobbit',
    int durationSeconds = 1800,
  }) => SessionShareData(
    bookTitle: title,
    bookAuthors: const ['J.R.R. Tolkien'],
    bookCoverUrl: null,
    pagesRead: 24,
    durationSeconds: durationSeconds,
    speedPpm: 0.8,
  );

  Widget wrap(SessionShareData data, ShareCardTheme theme) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: SessionShareCard.designWidth,
            height: SessionShareCard.designHeight,
            child: SessionShareCard(data: data, theme: theme),
          ),
        ),
      ),
    );
  }

  /// Everything the card paints behind its text.
  Finder backgroundLayer() => find.byKey(SessionShareCard.backgroundKey);

  test('the canvas is 9:16, so the 3x export lands on 1080x1920', () {
    expect(SessionShareCard.aspectRatio, closeTo(9 / 16, 0.0001));
    expect(SessionShareCard.designWidth * 3, 1080);
    expect(SessionShareCard.designHeight * 3, 1920);
  });

  testWidgets('photo content is centered and sits at the bottom padding', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.photo));

    final card = tester.getRect(backgroundLayer());
    final stats = find
        .ancestor(of: find.text('Time'), matching: find.byType(Row))
        .first;
    expect(
      card.bottom - tester.getRect(stats).bottom,
      closeTo(card.width * 20 / SessionShareCard.designWidth, 0.01),
    );
    for (final text in ['The Hobbit', 'by J.R.R. Tolkien']) {
      expect(tester.widget<Text>(find.text(text)).textAlign, TextAlign.center);
      expect(
        tester.getRect(find.text(text)).center.dx,
        closeTo(card.center.dx, 0.01),
      );
    }
    for (final label in ['Time', 'Pages', 'Speed']) {
      final column = find
          .ancestor(of: find.text(label), matching: find.byType(Column))
          .first;
      expect(
        tester.widget<Column>(column).crossAxisAlignment,
        CrossAxisAlignment.center,
      );
    }
  });

  testWidgets('has no rounded frame, so the export is a full-bleed rectangle', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.photo));

    expect(
      find.descendant(
        of: find.byType(SessionShareCard),
        matching: find.byType(ClipRRect),
      ),
      findsNothing,
    );
  });

  testWidgets('renders date, title, author, stats and watermark', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.photo));

    expect(find.text('The Hobbit'), findsOneWidget);
    expect(find.text('by J.R.R. Tolkien'), findsOneWidget);

    // Each stat is a bare value with its unit on the label underneath, the
    // way an activity card reads.
    expect(find.text('30m'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('0.8 ppm'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('PAGES'), findsOneWidget);
    expect(find.text('SPEED'), findsOneWidget);

    // Watermark on every preset — it's the growth loop.
    expect(find.text('BacaYu'), findsOneWidget);
  });

  testWidgets('carries no date, and the brand sits above the title', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.photo));

    expect(find.textContaining('2026'), findsNothing);

    // The brand opens the text block rather than floating in the top corner.
    expect(
      tester.getRect(find.text('BacaYu')).bottom,
      lessThan(tester.getRect(find.text('The Hobbit')).top),
    );
  });

  testWidgets('states the duration in units, the way Strava does', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(buildData(durationSeconds: 6367), ShareCardTheme.photo),
    );

    // 1h 46m 7s — the whole value, inside a third of the card.
    expect(find.text('1h 46m 7s'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('photo preset paints the cover behind the text', (tester) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.photo));

    // No cover URL in the fixture, so this is the brand fallback gradient plus
    // the scrim that keeps white type readable over artwork.
    expect(
      find.descendant(
        of: backgroundLayer(),
        matching: find.byType(DecoratedBox),
      ),
      findsWidgets,
    );
  });

  testWidgets(
    'solid preset centers title, horizontal stats, icon and logo on alpha',
    (tester) async {
      await tester.pumpWidget(wrap(buildData(), ShareCardTheme.solid));

      expect(ShareCardTheme.solid.isSticker, isTrue);
      expect(
        find.descendant(
          of: backgroundLayer(),
          matching: find.byType(ColoredBox),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: backgroundLayer(),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );
      final title = tester.getRect(find.text('The Hobbit'));
      final time = tester.getRect(find.text('Time'));
      final pages = tester.getRect(find.text('Pages'));
      final speed = tester.getRect(find.text('Speed'));
      final iconFinder = find.image(
        const AssetImage('assets/icons/book-open-02-stroke.png'),
      );
      final icon = tester.getRect(iconFinder);
      final logo = tester.getRect(
        find.image(const AssetImage('assets/images/bacayu-logo-white.png')),
      );
      final center = tester.getRect(backgroundLayer()).center.dx;
      expect(title.bottom, lessThan(time.top));
      final statColumns = ['Time', 'Pages', 'Speed']
          .map(
            (label) => tester.getRect(
              find
                  .ancestor(of: find.text(label), matching: find.byType(Column))
                  .first,
            ),
          )
          .toList();
      expect(statColumns[0].top, closeTo(statColumns[1].top, 0.01));
      expect(statColumns[1].top, closeTo(statColumns[2].top, 0.01));
      expect(time.center.dx, lessThan(pages.center.dx));
      expect(pages.center.dx, lessThan(speed.center.dx));
      expect(time.bottom, lessThan(icon.top));
      expect(icon.bottom, lessThan(logo.top));
      for (final rect in [title, icon, logo]) {
        expect(rect.center.dx, closeTo(center, 0.01));
      }
      expect(tester.widget<Image>(iconFinder).color, AppColors.tangerine);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('sticker preset exports the type alone on clear alpha', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.sticker));

    expect(
      find.descendant(of: backgroundLayer(), matching: find.byType(Image)),
      findsNothing,
    );
    // Nothing is painted anywhere in the card — no cover, no fill, no panel —
    // so the downloaded PNG carries the text and nothing else.
    expect(
      find.descendant(
        of: find.byType(SessionShareCard),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );

    // The type is still there, watermark included.
    expect(find.text('The Hobbit'), findsOneWidget);
    expect(find.text('BacaYu'), findsOneWidget);
  });

  testWidgets('the transparent preset centers its text, brand just under the '
      'stats', (tester) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.sticker));

    final card = tester.getRect(backgroundLayer());
    final watermark = tester.getRect(find.text('BacaYu'));
    final title = tester.getRect(find.text('The Hobbit'));
    final time = tester.getRect(find.text('TIME'));
    final pages = tester.getRect(find.text('PAGES'));
    final speed = tester.getRect(find.text('SPEED'));

    // Title, then the stats below it, then the brand right after them.
    expect(title.bottom, lessThan(time.top));
    expect(speed.bottom, lessThan(watermark.top));
    expect(watermark.top - speed.bottom, lessThan(card.height * 0.1));

    // Stats stack vertically, one per row.
    expect(time.top, lessThan(pages.top));
    expect(pages.top, lessThan(speed.top));
  });

  testWidgets('a long title shrinks its type instead of truncating', (
    tester,
  ) async {
    const long = 'The 100-Year-Old Man Who Climbed Out the Window';
    await tester.pumpWidget(wrap(buildData(title: long), ShareCardTheme.photo));

    final title = tester.widget<Text>(find.text(long));
    expect(title.maxLines, isNull);
    expect(title.overflow, isNot(TextOverflow.ellipsis));
    // Stepped down to fit three lines, but still a hero.
    expect(title.style!.fontSize, lessThan(AppTypography.displaySm.fontSize!));
    expect(title.style!.fontSize, greaterThan(16));

    expect(tester.takeException(), isNull);
  });

  testWidgets('a short title keeps the full display size', (tester) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.photo));

    final title = tester.widget<Text>(find.text('The Hobbit'));
    expect(title.style!.fontSize, AppTypography.displaySm.fontSize);
  });

  testWidgets('an absurd title still fits the fixed canvas', (tester) async {
    final absurd = List.filled(24, 'Antidisestablishmentarianism').join(' ');
    await tester.pumpWidget(
      wrap(buildData(title: absurd), ShareCardTheme.photo),
    );

    // No RenderFlex overflow, and the text is still whole.
    expect(tester.takeException(), isNull);
    expect(find.text(absurd), findsOneWidget);
  });

  testWidgets('plate preset frames the cover and stacks the text beneath it', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.plate));

    expect(find.text('The Hobbit'), findsOneWidget);
    expect(find.text('by J.R.R. Tolkien'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('BacaYu'), findsOneWidget);

    // The cover is presented as a clipped plate rather than as the backdrop.
    expect(
      find.descendant(
        of: find.byType(SessionShareCard),
        matching: find.byType(ClipRRect),
      ),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('plate has a transparent background and centered stat columns', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.plate));
    expect(ShareCardTheme.plate.isSticker, isTrue);
    expect(
      find.descendant(of: backgroundLayer(), matching: find.byType(ColoredBox)),
      findsNothing,
    );
    for (final label in ['TIME', 'PAGES', 'SPEED']) {
      final column = find
          .ancestor(of: find.text(label), matching: find.byType(Column))
          .first;
      expect(
        tester.widget<Column>(column).crossAxisAlignment,
        CrossAxisAlignment.center,
      );
      final fitted = find
          .ancestor(of: find.text(label), matching: find.byType(FittedBox))
          .first;
      expect(tester.widget<FittedBox>(fitted).alignment, Alignment.center);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'hero preset aligns cover and stats below centered logo and title',
    (tester) async {
      await tester.pumpWidget(
        wrap(buildData(durationSeconds: 1800), ShareCardTheme.hero),
      );

      expect(find.text('30m'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Pages'), findsOneWidget);
      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('The Hobbit'), findsOneWidget);

      expect(ShareCardTheme.hero.isSticker, isTrue);
      expect(
        find.descendant(
          of: backgroundLayer(),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: backgroundLayer(),
          matching: find.byType(ColoredBox),
        ),
        findsNothing,
      );
      final cover = tester.getRect(find.byType(ClipRRect));
      final title = tester.getRect(find.text('The Hobbit'));
      final time = tester.getRect(find.text('Time'));
      final pages = tester.getRect(find.text('Pages'));
      final speed = tester.getRect(find.text('Speed'));
      final logo = tester.getRect(find.byType(Image));
      expect(cover.right, lessThan(time.left));
      expect(
        (cover.right + time.left) / 2,
        closeTo(tester.getRect(backgroundLayer()).center.dx, 0.01),
      );
      expect(cover.top, closeTo(time.top, 0.01));
      expect(title.bottom, lessThan(cover.top));
      expect(title.bottom, lessThan(time.top));
      expect(time.bottom, lessThan(pages.top));
      expect(pages.bottom, lessThan(speed.top));
      expect(
        logo.center.dx,
        closeTo(tester.getRect(backgroundLayer()).center.dx, 0.01),
      );
      expect(logo.bottom, lessThan(cover.top));
      expect(title.center.dx, closeTo(logo.center.dx, 0.01));
      expect(logo.bottom, lessThan(title.top));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('every preset uses larger stats and fits a long duration', (
    tester,
  ) async {
    for (final preset in ShareCardTheme.presets) {
      await tester.pumpWidget(wrap(buildData(durationSeconds: 6367), preset));
      final (valueSize, labelSize) = switch (preset.layout) {
        ShareCardLayout.spread => (28.0, 14.0),
        ShareCardLayout.hero => (22.0, 14.0),
        _ => (20.0, 12.0),
      };
      for (final value in ['1h 46m 7s', '24', '0.8 ppm']) {
        expect(
          tester.widget<Text>(find.text(value)).style!.fontSize,
          valueSize,
        );
      }
      for (final label in ['Time', 'Pages', 'Speed']) {
        expect(
          tester.widget<Text>(find.text(label)).style!.fontSize,
          labelSize,
        );
      }
      expect(tester.takeException(), isNull, reason: '${preset.layout}');
    }
  });

  testWidgets('every preset survives an absurd title without overflowing', (
    tester,
  ) async {
    final absurd = List.filled(24, 'Antidisestablishmentarianism').join(' ');

    for (final preset in ShareCardTheme.presets) {
      await tester.pumpWidget(wrap(buildData(title: absurd), preset));
      expect(
        tester.takeException(),
        isNull,
        reason: 'layout ${preset.layout} overflowed the fixed canvas',
      );
    }
  });

  test('the presets offer more than one composition', () {
    final layouts = ShareCardTheme.presets
        .map((preset) => preset.layout)
        .toSet();

    expect(
      layouts,
      containsAll([
        ShareCardLayout.overlay,
        ShareCardLayout.framed,
        ShareCardLayout.hero,
        ShareCardLayout.spread,
      ]),
    );
  });

  testWidgets('every preset offers the watermark and the same carousel slots', (
    tester,
  ) async {
    expect(ShareCardTheme.presets, contains(ShareCardTheme.photo));
    expect(ShareCardTheme.presets, contains(ShareCardTheme.solid));
    expect(ShareCardTheme.presets, contains(ShareCardTheme.sticker));
    expect(ShareCardTheme.presets, contains(ShareCardTheme.plate));
    expect(ShareCardTheme.presets, contains(ShareCardTheme.hero));
    expect(
      ShareCardTheme.presets.every((preset) => preset.showWatermark),
      isTrue,
    );
  });
}
