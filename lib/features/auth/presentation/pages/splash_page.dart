import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../notifications/data/services/push_notification_service.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../../../core/theme/build_context_extension.dart';

/// Checks for an auth token, then (if present) fetches the current user to
/// decide onboarding vs. home — mirroring [User.hasOnboarded].
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _decideDestination();
  }

  Future<void> _decideDestination() async {
    final tokenStorage = getIt<SecureTokenStorage>();
    final hasToken = await tokenStorage.hasToken();
    if (!hasToken) {
      if (!mounted) return;
      context.go(AppRoutes.login);
      return;
    }

    final result = await getIt<GetCurrentUser>().call();
    if (!mounted) return;

    await result.fold(
      (failure) async {
        // Stale/invalid token — clear it and fall back to login rather than
        // getting stuck on the splash screen.
        await tokenStorage.clearToken();
        if (!mounted) return;
        context.go(AppRoutes.login);
      },
      (user) async {
        // A found session means this device should be (re-)registered —
        // token/platform can drift (reinstall, FCM token rotation) between
        // app opens.
        unawaited(getIt<PushNotificationService>().registerAfterLogin());
        context.go(user.hasOnboarded ? AppRoutes.home : AppRoutes.onboarding);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Text('BacaYu', style: AppTypography.displaySm),
      ),
    );
  }
}
