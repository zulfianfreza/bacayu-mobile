import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';
import 'package:mobile/features/feed/presentation/widgets/activity_author_header.dart';
import 'package:mobile/features/feed/presentation/widgets/session_activity_card.dart';
import 'package:mobile/l10n/app_localizations.dart';

Activity _activity(String bookTitle) => Activity(
  id: 'act-1',
  author: const ActivityAuthor(id: 'u1', name: 'Julian', avatarUrl: null),
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
  Widget wrap(String bookTitle, {ActivityAuthorHeader? author}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 360,
              child: SessionActivityCard(
                activity: _activity(bookTitle),
                author: author,
              ),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('a long book title renders in full, never ellipsized', (
    tester,
  ) async {
    const long = 'The 100-Year-Old Man Who Climbed Out the Window';
    await tester.pumpWidget(wrap(long));

    final title = tester.widget<Text>(find.text(long));
    expect(title.maxLines, isNull);
    expect(title.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the card grows with the title instead of clipping it', (
    tester,
  ) async {
    await tester.pumpWidget(wrap('Atomic Habits'));
    final shortHeight = tester.getSize(find.byType(SessionActivityCard)).height;

    await tester.pumpWidget(
      wrap('The 100-Year-Old Man Who Climbed Out the Window'),
    );
    final longHeight = tester.getSize(find.byType(SessionActivityCard)).height;

    expect(longHeight, greaterThan(shortHeight));
  });

  testWidgets('summarises the session on one line', (tester) async {
    await tester.pumpWidget(wrap('Atomic Habits'));

    // Duration, pages and speed read as one set, not three stacked facts.
    expect(find.text('10:00 · 20 pages · 1.2 ppm'), findsOneWidget);
  });

  testWidgets('introduces its author when one is passed', (tester) async {
    await tester.pumpWidget(
      wrap(
        'Atomic Habits',
        author: ActivityAuthorHeader(
          name: 'Julian',
          occurredAt: DateTime.now(),
        ),
      ),
    );

    expect(find.byType(ActivityAuthorHeader), findsOneWidget);
    expect(find.text('Julian'), findsOneWidget);
  });

  testWidgets('no author means no header — the card starts at the book', (
    tester,
  ) async {
    await tester.pumpWidget(wrap('Atomic Habits'));

    expect(find.byType(ActivityAuthorHeader), findsNothing);
  });
}
