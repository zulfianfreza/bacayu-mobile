import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/register_device.dart';
import 'firebase_messaging_gateway.dart';
import 'notification_navigator.dart';

const _typeBadgeUnlocked = 'badge_unlocked';

/// Wires up FCM: permission + foreground/background/terminated message
/// routing (CLAUDE.md "notifications" scope), and registering this device's
/// push token with the backend once a session exists.
@lazySingleton
class PushNotificationService {
  PushNotificationService(this._gateway, this._registerDevice, this._navigator);

  final FirebaseMessagingGateway _gateway;
  final RegisterDevice _registerDevice;
  final NotificationNavigator _navigator;

  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _listenersAttached = false;

  /// Call once at app startup — independent of auth state, since a message
  /// can arrive (or the app can be opened from one) before login finishes.
  Future<void> initialize() async {
    if (_listenersAttached) return;
    _listenersAttached = true;

    await _gateway.requestPermission(); // iOS requires this explicitly.

    _gateway.onMessage.listen(_handleForegroundMessage);
    _gateway.onMessageOpenedApp.listen(_handleOpenedMessage);

    final initialMessage = await _gateway.getInitialMessage();
    if (initialMessage != null) {
      _handleOpenedMessage(initialMessage);
    }
  }

  /// Registers this device's push token with the backend. MUST only be
  /// called after a session exists — `/notifications/register-device` is an
  /// authenticated endpoint — typically right after login/register, or at
  /// splash when an existing valid session is found.
  Future<void> registerAfterLogin() async {
    final token = await _gateway.getToken();
    if (token != null) {
      await _registerDevice(token: token, platform: _platform);
    }

    _tokenRefreshSubscription ??= _gateway.onTokenRefresh.listen((newToken) {
      _registerDevice(token: newToken, platform: _platform);
    });
  }

  String get _platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  /// App is in the foreground — an in-app modal beats the notification
  /// tray, so badge unlocks skip the OS banner entirely. `streak_reminder`
  /// gets no in-app treatment; the tray handles it.
  void _handleForegroundMessage(RemoteMessage message) {
    if (message.data['type'] != _typeBadgeUnlocked) return;
    _showBadgeModal(message);
  }

  /// App was backgrounded (`onMessageOpenedApp`) or terminated
  /// (`getInitialMessage`) and the user tapped the notification — navigate
  /// to a sensible destination first, then layer the modal on top for
  /// badge unlocks.
  void _handleOpenedMessage(RemoteMessage message) {
    _navigator.goHome();
    if (message.data['type'] != _typeBadgeUnlocked) return;
    _showBadgeModal(message);
  }

  void _showBadgeModal(RemoteMessage message) {
    _navigator.showBadgeUnlockedModal(
      name: message.data['badge_name'] ?? '',
      description: message.data['badge_description'] ?? '',
    );
  }
}
