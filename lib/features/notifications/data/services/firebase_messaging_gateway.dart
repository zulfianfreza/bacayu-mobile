import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

/// Thin seam around [FirebaseMessaging] — several of its members
/// (`onMessage`, `onMessageOpenedApp`) are static, which can't be
/// overridden by a mock. Wrapping them behind an instance interface is what
/// lets [PushNotificationService] be unit-tested without a platform channel.
abstract class FirebaseMessagingGateway {
  Future<NotificationSettings> requestPermission();
  Future<String?> getToken();
  Stream<String> get onTokenRefresh;
  Stream<RemoteMessage> get onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp;
  Future<RemoteMessage?> getInitialMessage();
}

@LazySingleton(as: FirebaseMessagingGateway)
class FirebaseMessagingGatewayImpl implements FirebaseMessagingGateway {
  FirebaseMessagingGatewayImpl(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  Future<NotificationSettings> requestPermission() =>
      _messaging.requestPermission();

  @override
  Future<String?> getToken() async {
    // iOS: FCM token registration requires an APNs token to already be
    // assigned by the OS first — that assignment is async and NOT
    // instant after requestPermission(). Calling getToken() before it's
    // ready throws FirebaseException[apns-token-not-set]. Android has no
    // such intermediary, so this only runs on iOS.
    if (Platform.isIOS) {
      final apnsReady = await _waitForApnsToken();
      if (!apnsReady) {
        // Most commonly: iOS Simulator, which often never gets a real
        // APNs token. Treat as "no token available" rather than crash —
        // caller (PushNotificationService.registerAfterLogin) already
        // no-ops on a null token.
        return null;
      }
    }
    return _messaging.getToken();
  }

  Future<bool> _waitForApnsToken({
    int maxRetries = 5,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) return true;
      await Future.delayed(delay);
    }
    return false;
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();
}

@module
abstract class FirebaseMessagingModule {
  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
}
