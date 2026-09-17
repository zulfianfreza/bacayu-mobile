import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/feed/presentation/widgets/activity_author_header.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  /// Two hours back, so the relative time is a stable "2h ago" while the test
  /// runs.
  final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));

  Widget wrap(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  testWidgets('shows the name, and the initial when there is no picture', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(ActivityAuthorHeader(name: 'Julian', occurredAt: twoHoursAgo)),
    );

    expect(find.text('Julian'), findsOneWidget);
    // The avatar falls back to the first initial, not an empty circle.
    expect(find.text('J'), findsOneWidget);

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isNull);
  });

  testWidgets('shows how long ago the activity happened', (tester) async {
    await tester.pumpWidget(
      wrap(ActivityAuthorHeader(name: 'Julian', occurredAt: twoHoursAgo)),
    );

    expect(find.text('2h ago'), findsOneWidget);
  });

  testWidgets('uses the picture when there is one, and drops the initial', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ActivityAuthorHeader(
          name: 'Julian',
          occurredAt: twoHoursAgo,
          avatarUrl: 'https://example.com/avatar.png',
        ),
      ),
    );

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isA<NetworkImage>());
    expect(find.text('J'), findsNothing);

    // The test environment has no network, so the avatar request itself
    // fails; that is the expected path here, not a broken widget.
    expect(tester.takeException(), isA<NetworkImageLoadException>());
  });

  testWidgets('an empty avatar URL is treated as no avatar', (tester) async {
    await tester.pumpWidget(
      wrap(
        ActivityAuthorHeader(
          name: 'Julian',
          occurredAt: twoHoursAgo,
          avatarUrl: '',
        ),
      ),
    );

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isNull);
    expect(find.text('J'), findsOneWidget);
  });

  testWidgets('a blank name still renders an avatar slot', (tester) async {
    await tester.pumpWidget(
      wrap(ActivityAuthorHeader(name: '', occurredAt: twoHoursAgo)),
    );

    expect(find.text('?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
