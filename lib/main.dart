import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/sessions/data/sync/session_sync_worker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  getIt<SessionSyncWorker>().start();
  runApp(const BacaYuApp());
}
