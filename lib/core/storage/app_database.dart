import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';

part 'app_database.g.dart';

/// Local SQLite database (offline cache + pending-sync queues). No tables
/// yet — each feature adds its own as it's built (e.g. `sessions` adds
/// `PendingSessions`). Never store the auth token here — that lives in
/// [SecureTokenStorage] instead.
@DriftDatabase(tables: [])
@lazySingleton
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'bacayu_db');
}
