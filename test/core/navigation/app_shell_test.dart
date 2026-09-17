import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/navigation/app_shell.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/sessions/presentation/widgets/book_picker_bottom_sheet.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A minimal go_router with the same shell shape as the real app, but
/// trivial branch content — isolates the test to AppShell's own tab/FAB
/// behavior, no auth/redirect involved.
GoRouter _testRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const Text('Home Page')),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/shelf', builder: (_, _) => const Text('Shelf Page')),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/stats', builder: (_, _) => const Text('Stats Page')),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const Text('Profile Page'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  Future<void> pumpShell(WidgetTester tester, {double textScale = 1.0}) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: MaterialApp.router(
          routerConfig: _testRouter(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The slot that owns a tab is the bar's own height, so measuring it
  /// measures the bar.
  Rect tabSlot(WidgetTester tester, String label) => tester.getRect(
        find
            .ancestor(of: find.text(label), matching: find.byType(InkWell))
            .first,
      );

  int activeBranchIndex(WidgetTester tester) =>
      tester.widget<IndexedStack>(find.byType(IndexedStack)).index!;

  testWidgets('starts on the Home tab', (tester) async {
    await pumpShell(tester);

    expect(activeBranchIndex(tester), 0);
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('tapping each tab switches to that branch', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('Shelf'));
    await tester.pumpAndSettle();
    expect(activeBranchIndex(tester), 1);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(activeBranchIndex(tester), 2);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(activeBranchIndex(tester), 3);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(activeBranchIndex(tester), 0);
  });

  testWidgets('tapping the session button opens BookPickerBottomSheet, not a '
      'tab switch', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.byKey(AppShell.startSessionKey));
    // Not pumpAndSettle: the sheet's book list keeps an indeterminate
    // spinner running while its (real, unmocked in this test) network call
    // is in flight, which never settles. A couple of bounded pumps is
    // enough for the sheet itself to mount.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(BookPickerBottomSheet), findsOneWidget);
    // Still on Home underneath — the button is an action, not a 5th branch.
    expect(activeBranchIndex(tester), 0);
  });

  testWidgets('every nav icon comes from an asset, not an IconData',
      (tester) async {
    await pumpShell(tester);

    // One per tab plus the session button.
    expect(find.byType(Image), findsNWidgets(5));
    expect(find.byIcon(Icons.play_arrow), findsNothing);
  });

  testWidgets('the active tab is carried by colour alone — no pill behind it',
      (tester) async {
    await pumpShell(tester);

    final activeLabel = tester.widget<Text>(find.text('Home'));
    final inactiveLabel = tester.widget<Text>(find.text('Shelf'));

    expect(activeLabel.style?.color, AppColors.tangerine700);
    expect(activeLabel.style?.fontWeight, FontWeight.w700);
    expect(inactiveLabel.style?.color, AppColors.inkSoft);

    // Icons follow the same two colours. Order in the bar is Home, Shelf,
    // session, Stats, Profile.
    final icons = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(icons[0].color, AppColors.tangerine700);
    expect(icons[1].color, AppColors.inkSoft);
    expect(icons[2].color, Colors.white);
  });

  testWidgets('the session button sits on the same line as the tabs, inside '
      'the bar', (tester) async {
    await pumpShell(tester);

    final button = tester.getRect(find.byKey(AppShell.startSessionKey));
    final slot = tabSlot(tester, 'Home');

    expect(button.center.dy, closeTo(slot.center.dy, 1));
    expect(button.top, greaterThanOrEqualTo(slot.top));
    expect(button.bottom, lessThanOrEqualTo(slot.bottom));
  });

  testWidgets('the bar grows with the text scaler instead of clipping its '
      'labels', (tester) async {
    await pumpShell(tester, textScale: 2.0);

    expect(tabSlot(tester, 'Home').height, greaterThan(72));
    expect(tester.takeException(), isNull);
  });
}
