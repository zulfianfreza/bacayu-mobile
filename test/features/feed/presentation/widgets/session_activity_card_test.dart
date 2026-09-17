import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';
import 'package:mobile/features/feed/presentation/widgets/session_activity_card.dart';
import 'package:mobile/l10n/app_localizations.dart';

Activity _activity(String bookTitle) => Activity(
      id: 'act-1',
      occurredAt: DateTime(2026, 1, 1),
      payload: SessionActivityPayload(
        bookId: 'book-1',
        bookTitle: bookTitle,
        bookCoverUrl: null,
        pagesRead: 20,
        speedPpm: 1.2,
        activeDurationSeconds: 600,
      ),
      likeCount: 2,
      commentCount: 3,
      isLiked: false,
    );

void main() {
  // Nothing here taps or fetches, so the card needs no router and no DI. The
  // width is pinned to a phone so a long title actually has to wrap, and the
  // card sits in a Column the way both real call sites stack it — that is what
  // lets it size to its own content.
  Widget wrap(String bookTitle) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 360,
              child: SessionActivityCard(activity: _activity(bookTitle)),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('a long book title renders in full, never ellipsized',
      (tester) async {
    const long = 'The 100-Year-Old Man Who Climbed Out the Window';
    await tester.pumpWidget(wrap(long));

    final title = tester.widget<Text>(find.text(long));
    expect(title.maxLines, isNull);
    expect(title.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the card grows with the title instead of clipping it',
      (tester) async {
    await tester.pumpWidget(wrap('Atomic Habits'));
    final shortHeight = tester.getSize(find.byType(Card)).height;

    await tester.pumpWidget(
      wrap('The 100-Year-Old Man Who Climbed Out the Window'),
    );
    final longHeight = tester.getSize(find.byType(Card)).height;

    expect(longHeight, greaterThan(shortHeight));
  });
}
