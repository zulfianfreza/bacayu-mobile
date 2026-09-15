import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/data/services/firebase_messaging_gateway.dart';
import 'package:mobile/features/notifications/data/services/notification_navigator.dart';
import 'package:mobile/features/notifications/data/services/push_notification_service.dart';
import 'package:mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:mobile/features/notifications/domain/usecases/register_device.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseMessagingGateway extends Mock implements FirebaseMessagingGateway {}

class _MockNotificationRepository extends Mock implements NotificationRepository {}

class _MockNotificationNavigator extends Mock implements NotificationNavigator {}

class _MockNotificationSettings extends Mock implements NotificationSettings {}

void main() {
  late _MockFirebaseMessagingGateway gateway;
  late _MockNotificationRepository repository;
  late _MockNotificationNavigator navigator;
  late RegisterDevice registerDevice;
  late PushNotificationService service;
  late StreamController<RemoteMessage> onMessageController;
  late StreamController<RemoteMessage> onMessageOpenedAppController;
  late StreamController<String> onTokenRefreshController;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    gateway = _MockFirebaseMessagingGateway();
    repository = _MockNotificationRepository();
    navigator = _MockNotificationNavigator();
    registerDevice = RegisterDevice(repository);
    onMessageController = StreamController<RemoteMessage>.broadcast();
    onMessageOpenedAppController = StreamController<RemoteMessage>.broadcast();
    onTokenRefreshController = StreamController<String>.broadcast();

    when(() => gateway.requestPermission())
        .thenAnswer((_) async => _MockNotificationSettings());
    when(() => gateway.onMessage).thenAnswer((_) => onMessageController.stream);
    when(() => gateway.onMessageOpenedApp)
        .thenAnswer((_) => onMessageOpenedAppController.stream);
    when(() => gateway.onTokenRefresh).thenAnswer((_) => onTokenRefreshController.stream);
    when(() => gateway.getInitialMessage()).thenAnswer((_) async => null);
    when(() => gateway.getToken()).thenAnswer((_) async => 'fcm-token-1');
    when(() => repository.registerDevice(
          token: any(named: 'token'),
          platform: any(named: 'platform'),
        )).thenAnswer((_) async => const Right(unit));

    service = PushNotificationService(gateway, registerDevice, navigator);
  });

  tearDown(() async {
    await onMessageController.close();
    await onMessageOpenedAppController.close();
    await onTokenRefreshController.close();
  });

  RemoteMessage badgeMessage() => const RemoteMessage(
        data: {
          'type': 'badge_unlocked',
          'badge_id': 'b1',
          'badge_name': 'First Step',
          'badge_icon': '🎉',
          'badge_description': 'Finish your first session',
        },
      );

  RemoteMessage streakMessage() => const RemoteMessage(
        data: {'type': 'streak_reminder'},
      );

  group('device registration', () {
    test('registerDevice is NOT called merely from initialize() — only '
        'after login', () async {
      await service.initialize();

      verifyNever(() => repository.registerDevice(
            token: any(named: 'token'),
            platform: any(named: 'platform'),
          ));
    });

    test('registerAfterLogin() sends the current FCM token', () async {
      await service.registerAfterLogin();

      verify(() => repository.registerDevice(
            token: 'fcm-token-1',
            platform: any(named: 'platform'),
          )).called(1);
    });

    test('a refreshed token re-registers, once subscribed via '
        'registerAfterLogin()', () async {
      await service.registerAfterLogin();
      clearInteractions(repository);

      onTokenRefreshController.add('fcm-token-2');
      await Future<void>.delayed(Duration.zero);

      verify(() => repository.registerDevice(
            token: 'fcm-token-2',
            platform: any(named: 'platform'),
          )).called(1);
    });
  });

  group('foreground messages (onMessage)', () {
    test('badge_unlocked shows the modal directly, no navigation', () async {
      await service.initialize();

      onMessageController.add(badgeMessage());
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => navigator.goHome());
      verify(() => navigator.showBadgeUnlockedModal(
            name: 'First Step',
            icon: '🎉',
            description: 'Finish your first session',
          )).called(1);
    });

    test('streak_reminder does nothing in-app — tray handles it', () async {
      await service.initialize();

      onMessageController.add(streakMessage());
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => navigator.goHome());
      verifyNever(() => navigator.showBadgeUnlockedModal(
            name: any(named: 'name'),
            icon: any(named: 'icon'),
            description: any(named: 'description'),
          ));
    });
  });

  group('opened-app messages (background tap / terminated launch)', () {
    test('badge_unlocked navigates home THEN shows the modal', () async {
      await service.initialize();

      onMessageOpenedAppController.add(badgeMessage());
      await Future<void>.delayed(Duration.zero);

      verify(() => navigator.goHome()).called(1);
      verify(() => navigator.showBadgeUnlockedModal(
            name: 'First Step',
            icon: '🎉',
            description: 'Finish your first session',
          )).called(1);
    });

    test('streak_reminder navigates home but shows no modal', () async {
      await service.initialize();

      onMessageOpenedAppController.add(streakMessage());
      await Future<void>.delayed(Duration.zero);

      verify(() => navigator.goHome()).called(1);
      verifyNever(() => navigator.showBadgeUnlockedModal(
            name: any(named: 'name'),
            icon: any(named: 'icon'),
            description: any(named: 'description'),
          ));
    });

    test('a terminated-launch initial message routes the same way as a '
        'background tap', () async {
      when(() => gateway.getInitialMessage()).thenAnswer((_) async => badgeMessage());

      await service.initialize();

      verify(() => navigator.goHome()).called(1);
      verify(() => navigator.showBadgeUnlockedModal(
            name: 'First Step',
            icon: '🎉',
            description: 'Finish your first session',
          )).called(1);
    });
  });
}
