import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/shelf/presentation/pages/shelf_page.dart';
import '../../features/stats/presentation/pages/stats_page.dart';
import '../../l10n/app_localizations.dart';
import '../localization/build_context_extension.dart';
import '../navigation/app_shell.dart';
import '../storage/secure_token_storage.dart';

/// Route paths as constants — never hardcode a path string at a call site.
class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const shelf = '/shelf';
  static const stats = '/stats';
  static const profile = '/profile';
}

/// Routes reachable without an auth token.
const _publicRoutes = {AppRoutes.login, AppRoutes.register};

@module
abstract class AppRouterModule {
  @lazySingleton
  GoRouter goRouter(SecureTokenStorage tokenStorage) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) async {
        final location = state.matchedLocation;

        // Splash owns its own navigation decision; never intercept it here.
        if (location == AppRoutes.splash) return null;

        final hasToken = await tokenStorage.hasToken();
        final isPublicRoute = _publicRoutes.contains(location);

        if (!hasToken && !isPublicRoute) return AppRoutes.login;
        if (hasToken && isPublicRoute) return AppRoutes.home;
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.shelf,
                  builder: (context, state) => const ShelfPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.stats,
                  builder: (context, state) => const StatsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  builder: (context, state) => _PlaceholderTabPage(
                    titleBuilder: (l10n) => l10n.tabProfile,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Stand-in for `profile` — not scoped yet (same gap `onboarding` was in
/// before `books`/`shelf` landed).
class _PlaceholderTabPage extends StatelessWidget {
  const _PlaceholderTabPage({required this.titleBuilder});

  final String Function(AppLocalizations l10n) titleBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(titleBuilder(l10n))),
      body: Center(child: Text(l10n.comingSoon)),
    );
  }
}
