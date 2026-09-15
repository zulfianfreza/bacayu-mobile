import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/notifications/data/services/push_notification_service.dart';
import 'features/sessions/data/sync/session_sync_worker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Requires native Firebase config (google-services.json /
  // GoogleService-Info.plist, generated via `flutterfire configure`) to be
  // present on device — not something this codebase can provide on its own.
  await Firebase.initializeApp();
  await configureDependencies();
  getIt<SessionSyncWorker>().start();
  await getIt<PushNotificationService>().initialize();
  runApp(const BacaYuApp());
}
