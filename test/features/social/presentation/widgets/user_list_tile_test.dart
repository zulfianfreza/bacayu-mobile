import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/chunky_button.dart';
import 'package:mobile/features/social/domain/entities/followed_user.dart';
import 'package:mobile/features/social/presentation/widgets/user_list_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';

FollowedUser _user({
  bool isFollowing = false,
  bool isFollowedBy = false,
  String name = 'Maya',
}) => FollowedUser(
  id: 'u2',
  name: name,
  avatarUrl: null,
  isFollowing: isFollowing,
  isFollowedBy: isFollowedBy,
);

void main() {
  var toggled = false;

  Future<void> pumpTile(
    WidgetTester tester, {
    required FollowedUser user,
    bool isPending = false,
    bool showFollowsYouBack = false,
  }) async {
    toggled = false;
    await tester.pumpWidget(
      MaterialApp(
        // Pinned to the app's primary locale so the assertions below can name
        // the strings it actually ships with.
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: UserListTile(
            user: user,
            isPending: isPending,
            showFollowsYouBack: showFollowsYouBack,
            onToggleFollow: () => toggled = true,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('the button shows the state the list came back with', (
    tester,
  ) async {
    await pumpTile(tester, user: _user(isFollowing: false));
    expect(find.text('Ikuti'), findsOneWidget);

    await pumpTile(tester, user: _user(isFollowing: true));
    expect(find.text('Mengikuti'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the button asks the cubit to toggle', (tester) async {
    await pumpTile(tester, user: _user());

    await tester.tap(find.text('Ikuti'));
    await tester.pump();

    expect(toggled, isTrue);
  });

  testWidgets('a pending row is a spinner and cannot be tapped again', (
    tester,
  ) async {
    await pumpTile(tester, user: _user(), isPending: true);

    expect(find.text('Ikuti'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(ChunkyButton),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byType(ChunkyButton));
    await tester.pump();

    expect(toggled, isFalse);
  });

  testWidgets('"follows you back" shows only when the list asks for it', (
    tester,
  ) async {
    await pumpTile(tester, user: _user(isFollowedBy: true));
    expect(find.text('Follow kamu balik'), findsNothing);

    await pumpTile(
      tester,
      user: _user(isFollowedBy: true),
      showFollowsYouBack: true,
    );
    expect(find.text('Follow kamu balik'), findsOneWidget);

    await pumpTile(
      tester,
      user: _user(isFollowedBy: false),
      showFollowsYouBack: true,
    );
    expect(find.text('Follow kamu balik'), findsNothing);
  });
}
