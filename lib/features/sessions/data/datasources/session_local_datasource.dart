import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/storage/app_database.dart';

/// Drift access for the `PendingSessions` queue — see CLAUDE.md Section 6.2.
@injectable
class SessionLocalDataSource {
  SessionLocalDataSource(this._db);

  final AppDatabase _db;

  Future<void> enqueue({
    required String clientId,
    required Map<String, dynamic> payload,
  }) {
    return _db.into(_db.pendingSessions).insertOnConflictUpdate(
          PendingSessionsCompanion.insert(
            clientId: clientId,
            payload: jsonEncode(payload),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> markSynced(String clientId) {
    return (_db.update(_db.pendingSessions)
          ..where((row) => row.clientId.equals(clientId)))
        .write(const PendingSessionsCompanion(synced: Value(true)));
  }

  Future<List<PendingSession>> getUnsynced() {
    return (_db.select(_db.pendingSessions)
          ..where((row) => row.synced.equals(false)))
        .get();
  }
}
