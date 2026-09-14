import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

part 'app_database.g.dart';

/// Sessions that finished (`Stop` tapped, start/end page filled — CLAUDE.md
/// Section 6 "Tahap B"). NOT for an in-progress timer — that stays in
/// memory only (`SessionTimerCubit`), by design (Tahap A has no
/// persistence; see Section 6.1). `payload` is the same JSON shape as the
/// `POST /sessions` request body, so a retry re-sends exactly what would
/// have been sent originally.
class PendingSessions extends Table {
  TextColumn get clientId => text()();
  TextColumn get payload => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {clientId};
}

/// Local SQLite database (offline cache + pending-sync queues). Never store
/// the auth token here — that lives in [SecureTokenStorage] instead.
@DriftDatabase(tables: [PendingSessions])
@lazySingleton
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For repository integration tests (CLAUDE.md Section 10) — pass an
  /// in-memory `NativeDatabase` instead of the real on-disk one.
  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'bacayu_db');
}
