import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../storage/secure_token_storage.dart';

/// Route paths as constants — never hardcode a path string at a call site.
class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const home = '/home';
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
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const _PlaceholderPage(title: 'Home'),
        ),
      ],
    );
  }
}

/// Stand-in until `home` lands with its own feature.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(title)),
    );
  }
}
