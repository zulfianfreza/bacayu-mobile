import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/sharing/widgets/share_card_preview_sheet.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';
import 'package:mobile/features/feed/presentation/widgets/activity_card_footer.dart';
import 'package:mobile/l10n/app_localizations.dart';

Activity _session() => Activity(
  id: 'act-1',
  author: const ActivityAuthor(id: 'u1', name: 'Julian', avatarUrl: null),
  occurredAt: DateTime(2026, 1, 1),
  payload: const SessionActivityPayload(
    bookId: 'book-1',
    bookTitle: 'Atomic Habits',
    bookCoverUrl: null,
    pagesRead: 20,
    speedPpm: 1.2,
    activeDurationSeconds: 600,
  ),
  likeCount: 2,
  commentCount: 3,
  isLiked: false,
);

Activity _badge() => Activity(
  id: 'act-2',
  author: const ActivityAuthor(id: 'u1', name: 'Julian', avatarUrl: null),
  occurredAt: DateTime(2026, 1, 1),
  payload: const BadgeActivityPayload(
    badgeName: 'First Step',
    badgeIcon: '🎉',
    badgeDescription: 'Finish your first session',
  ),
  likeCount: 0,
  commentCount: 0,
  isLiked: false,
);

void main() {
  // The share affordance is the app's own artwork, not a Material glyph.
  const shareAsset = 'assets/icons/share-stroke.png';
  final shareIcon = find.byWidgetPredicate(
    (widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == shareAsset,
  );

  Widget wrap(Activity activity, {bool isOwnActivity = true}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ActivityCardFooter(
          activity: activity,
          isOwnActivity: isOwnActivity,
        ),
      ),
    );
  }

  testWidgets('your own session can be shared straight from the card', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(_session()));

    expect(shareIcon, findsOneWidget);
    // Icon-only, so it needs a label of its own for assistive tech.
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Share',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping it opens the share card preview', (tester) async {
    await tester.pumpWidget(wrap(_session()));

    await tester.tap(shareIcon);
    await tester.pumpAndSettle();

    expect(find.byType(ShareCardPreviewSheet), findsOneWidget);
  });

  testWidgets('a badge unlock has nothing to share', (tester) async {
    await tester.pumpWidget(wrap(_badge()));

    expect(shareIcon, findsNothing);
  });

  testWidgets("someone else's session is not yours to share", (tester) async {
    await tester.pumpWidget(wrap(_session(), isOwnActivity: false));

    expect(shareIcon, findsNothing);
  });
}
