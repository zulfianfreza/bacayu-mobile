import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/navigation/app_shell.dart';
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

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: _testRouter(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
  }

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

  testWidgets('tapping the FAB opens BookPickerBottomSheet, not a tab switch',
      (tester) async {
    await pumpShell(tester);

    await tester.tap(find.byIcon(Icons.play_arrow));
    // Not pumpAndSettle: the sheet's book list keeps an indeterminate
    // spinner running while its (real, unmocked in this test) network call
    // is in flight, which never settles. A couple of bounded pumps is
    // enough for the sheet itself to mount.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(BookPickerBottomSheet), findsOneWidget);
    // Still on Home underneath — the FAB is an action, not a 5th branch.
    expect(activeBranchIndex(tester), 0);
  });
}
