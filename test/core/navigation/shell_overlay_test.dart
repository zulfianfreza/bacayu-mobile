import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/navigation/app_shell.dart';
import 'package:mobile/core/navigation/full_screen_page.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pushedPageKey = Key('pushed-page');

/// Pushed pages are opaque and full-bleed, so measuring one tells us which
/// navigator it landed on: the whole screen means the root navigator, the body
/// area means the tab's own — and only the latter leaves the bottom bar showing.
double pushedPageHeight(WidgetTester tester) =>
    tester.getRect(find.byKey(_pushedPageKey)).height;

double screenHeight(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio;

/// Branch content that can push a page the two ways the app does.
class _HomeBranch extends StatelessWidget {
  const _HomeBranch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Home Page'),
          ElevatedButton(
            onPressed: () => pushFullScreen(
              context,
              (_) => const ColoredBox(
                key: _pushedPageKey,
                color: Colors.white,
                child: SizedBox.expand(),
              ),
            ),
            child: const Text('push full screen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ColoredBox(
                  key: _pushedPageKey,
                  color: Colors.white,
                  child: SizedBox.expand(),
                ),
              ),
            ),
            child: const Text('push nested'),
          ),
        ],
      ),
    );
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      // Mirrors the app's top-level routes (followers, leaderboard, an
      // activity's detail) — registered outside the shell.
      GoRoute(
        path: '/detail',
        builder: (_, _) => const ColoredBox(
          key: _pushedPageKey,
          color: Colors.white,
          child: SizedBox.expand(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const _HomeBranch()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/shelf', builder: (_, _) => const Text('Shelf')),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/stats', builder: (_, _) => const Text('Stats')),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (_, _) => const Text('Profile')),
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
        routerConfig: _router(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a page pushed from a tab covers the bottom bar', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('push full screen'));
    await tester.pumpAndSettle();

    expect(pushedPageHeight(tester), screenHeight(tester));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a top-level go_router route also covers the bottom bar', (
    tester,
  ) async {
    await pumpShell(tester);

    // Pushed the way the app does it: from inside a tab, by path.
    tester.element(find.text('Home Page')).push('/detail');
    await tester.pumpAndSettle();

    expect(pushedPageHeight(tester), screenHeight(tester));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a plain push from a tab stops at the bottom bar', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('push nested'));
    await tester.pumpAndSettle();

    // Shorter than the screen: it landed on the tab's own Navigator, which the
    // shell renders inside its body — the bottom bar stays visible. This is the
    // behaviour `pushFullScreen` exists to avoid.
    expect(pushedPageHeight(tester), lessThan(screenHeight(tester)));
    expect(tester.takeException(), isNull);
  });
}
