import 'package:flutter/material.dart' hide Badge;
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/router/app_router.dart';
import '../../../badges/presentation/widgets/badge_unlocked_modal.dart';

/// Navigation side effects the push handler performs, kept behind an
/// interface so [PushNotificationService] can be unit-tested without a live
/// widget tree — [AppNotificationNavigator] is the only thing that actually
/// touches `navigatorKey`.
abstract class NotificationNavigator {
  void goHome();

  void showBadgeUnlockedModal({
    required String name,
    required String icon,
    required String description,
  });
}

@LazySingleton(as: NotificationNavigator)
class AppNotificationNavigator implements NotificationNavigator {
  AppNotificationNavigator(this._navigatorKey);

  final GlobalKey<NavigatorState> _navigatorKey;

  @override
  void goHome() {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    context.go(AppRoutes.home);
  }

  @override
  void showBadgeUnlockedModal({
    required String name,
    required String icon,
    required String description,
  }) {
    // A small delay so the modal never appears mid-transition — waiting for
    // the first frame after navigation is enough for `goHome()` (if called)
    // to have finished building the destination page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _navigatorKey.currentContext;
      if (context == null) return;
      BadgeUnlockedModal.show(context, name: name, icon: icon, description: description);
    });
  }
}
