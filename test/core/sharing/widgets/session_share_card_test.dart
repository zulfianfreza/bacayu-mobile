import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/sharing/models/session_share_data.dart';
import 'package:mobile/core/sharing/models/share_card_theme.dart';
import 'package:mobile/core/sharing/widgets/session_share_card.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  SessionShareData buildData({String title = 'The Hobbit', int? streakDays}) =>
      SessionShareData(
        bookTitle: title,
        bookAuthors: const ['J.R.R. Tolkien'],
        bookCoverUrl: null,
        pagesRead: 24,
        durationSeconds: 1800,
        speedPpm: 0.8,
        sessionDate: DateTime(2026, 3, 14),
        streakDays: streakDays,
      );

  Widget wrap(SessionShareData data, ShareCardTheme theme) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            height: 400,
            child: SessionShareCard(data: data, theme: theme),
          ),
        ),
      ),
    );
  }

  /// Everything the card paints behind its text.
  Finder backgroundLayer() => find.byKey(SessionShareCard.backgroundKey);

  testWidgets('renders date, title, author, stats and watermark without a '
      'streak chip', (tester) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.photo));

    expect(find.text('The Hobbit'), findsOneWidget);
    expect(find.text('by J.R.R. Tolkien'), findsOneWidget);
    expect(find.textContaining('2026'), findsOneWidget);

    // Each stat is a bare value with its unit on the label underneath, the
    // way an activity card reads.
    expect(find.text('30:00'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('0.8 ppm'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('PAGES'), findsOneWidget);
    expect(find.text('SPEED'), findsOneWidget);

    // Watermark on every preset — it's the growth loop.
    expect(find.text('BacaYu'), findsOneWidget);
    expect(find.textContaining('day streak'), findsNothing);
  });

  testWidgets('renders the streak chip when streakDays is provided',
      (tester) async {
    await tester.pumpWidget(
      wrap(buildData(streakDays: 12), ShareCardTheme.photo),
    );

    expect(find.text('🔥 12 day streak'), findsOneWidget);
  });

  testWidgets('photo preset paints the cover behind the text',
      (tester) async {
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

  testWidgets('solid preset paints the flat dark fill instead of a cover',
      (tester) async {
    await tester.pumpWidget(wrap(buildData(), ShareCardTheme.solid));

    final fill = tester.widget<ColoredBox>(
      find.descendant(
        of: backgroundLayer(),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(fill.color, AppColors.ink);
  });

  testWidgets(
      'sticker preset drops the cover and keeps a translucent scrim, so the '
      'user\'s own photo shows through', (tester) async {
    await tester.pumpWidget(
      wrap(buildData(streakDays: 3), ShareCardTheme.sticker),
    );

    expect(
      find.descendant(of: backgroundLayer(), matching: find.byType(Image)),
      findsNothing,
    );
    expect(
      find.descendant(of: backgroundLayer(), matching: find.byType(ColoredBox)),
      findsNothing,
      reason: 'a flat fill would hide the photo the sticker lands on',
    );

    final scrim = tester.widget<DecoratedBox>(
      find.descendant(
        of: backgroundLayer(),
        matching: find.byType(DecoratedBox),
      ),
    );
    final gradient =
        (scrim.decoration as BoxDecoration).gradient! as LinearGradient;
    expect(
      gradient.colors.any((color) => color.a < 1),
      isTrue,
      reason: 'a fully opaque scrim would defeat the point of a sticker',
    );

    // The watermark still shows in sticker mode.
    expect(find.text('BacaYu'), findsOneWidget);
  });

  testWidgets('a long title shrinks its type instead of truncating',
      (tester) async {
    const long = 'The 100-Year-Old Man Who Climbed Out the Window';
    await tester.pumpWidget(
      wrap(buildData(title: long), ShareCardTheme.photo),
    );

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

  testWidgets('every preset offers the watermark and the same carousel slots',
      (tester) async {
    expect(ShareCardTheme.presets, contains(ShareCardTheme.photo));
    expect(ShareCardTheme.presets, contains(ShareCardTheme.solid));
    expect(ShareCardTheme.presets, contains(ShareCardTheme.sticker));
    expect(
      ShareCardTheme.presets.every((preset) => preset.showWatermark),
      isTrue,
    );
  });
}
