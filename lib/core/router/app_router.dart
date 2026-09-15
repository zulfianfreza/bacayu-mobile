import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/shelf/presentation/pages/shelf_page.dart';
import '../../features/social/presentation/pages/followers_page.dart';
import '../../features/social/presentation/pages/following_page.dart';
import '../../features/social/presentation/pages/leaderboard_page.dart';
import '../../features/stats/presentation/pages/stats_page.dart';
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

  static const followers = '/followers';
  static const following = '/following';

  /// Temporary — still no real navigation entry point (leaderboard wasn't
  /// in `profile`'s scope). Exists purely for manual testing, same pattern
  /// followers/following used before `profile` gave them a real one.
  static const leaderboardDebug = '/debug/leaderboard';
}

/// Routes reachable without an auth token.
const _publicRoutes = {AppRoutes.login, AppRoutes.register};

@module
abstract class NavigatorKeyModule {
  /// Lets code outside the widget tree (push notification handlers) reach a
  /// [BuildContext] — see `notifications`' `AppNotificationNavigator`.
  @lazySingleton
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();
}

@module
abstract class AppRouterModule {
  @lazySingleton
  GoRouter goRouter(SecureTokenStorage tokenStorage, GlobalKey<NavigatorState> navigatorKey) {
    return GoRouter(
      navigatorKey: navigatorKey,
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
        GoRoute(
          path: AppRoutes.followers,
          builder: (context, state) => const FollowersPage(),
        ),
        GoRoute(
          path: AppRoutes.following,
          builder: (context, state) => const FollowingPage(),
        ),
        GoRoute(
          path: AppRoutes.leaderboardDebug,
          builder: (context, state) => const LeaderboardPage(),
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
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
