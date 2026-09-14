import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/reading_session.dart';
import '../../domain/entities/unlocked_badge.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_local_datasource.dart';
import '../datasources/session_remote_datasource.dart';
import '../models/reading_session_model.dart';
import '../models/unlocked_badge_model.dart';

/// The backend code for a retried submit of an already-landed `client_id`
/// (see `api/internal/features/sessions/domain/errors.go`
/// `ErrDuplicateClientID`) — safe to treat as "already synced", not a
/// failure to keep retrying.
const _duplicateSessionCode = 'DUPLICATE_SESSION';

@LazySingleton(as: SessionRepository)
class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._remote, this._local);

  final SessionRemoteDataSource _remote;
  final SessionLocalDataSource _local;

  @override
  Future<Either<Failure, Unit>> submitSession(
    ReadingSession session, {
    void Function(List<UnlockedBadge> badges)? onSyncedWithBadges,
  }) async {
    final model = ReadingSessionModel.fromEntity(session);
    final payload = model.toJson();

    try {
      await _local.enqueue(clientId: session.clientId, payload: payload);
    } catch (_) {
      return const Left(CacheFailure());
    }

    // Best-effort immediate send. Deliberately NOT awaited by the caller —
    // the local enqueue above is already "success" (CLAUDE.md Section 6.2).
    unawaited(_trySyncNow(session.clientId, payload, onSyncedWithBadges));

    return const Right(unit);
  }

  Future<void> _trySyncNow(
    String clientId,
    Map<String, dynamic> payload,
    void Function(List<UnlockedBadge> badges)? onSyncedWithBadges,
  ) async {
    try {
      final json = await _remote.submit(payload);
      await _local.markSynced(clientId);
      final badges = (json['badges_unlocked'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(UnlockedBadgeModel.fromJson)
          .toList();
      onSyncedWithBadges?.call(badges);
    } on DioException catch (e) {
      final failure = mapDioExceptionToFailure(e);
      if (failure is ServerFailure && failure.code == _duplicateSessionCode) {
        // Already landed server-side from an earlier attempt (e.g. this
        // exact request succeeded once but the response timed out) — safe
        // to mark synced rather than retry forever.
        await _local.markSynced(clientId);
      }
      // Otherwise: leave unsynced. SessionSyncWorker retries later.
    }
  }

  @override
  Future<Either<Failure, List<ReadingSession>>> getHistory({int page = 1}) async {
    try {
      final json = await _remote.getHistory(page: page);
      final sessions = json
          .cast<Map<String, dynamic>>()
          .map(ReadingSessionModel.fromJson)
          .toList();
      return Right(sessions);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }
}

/// Decodes a `PendingSessions.payload` row back into the request map, for
/// `SessionSyncWorker`'s retries — kept here since it's the mirror of
/// `enqueue`'s encoding.
Map<String, dynamic> decodePendingSessionPayload(String payload) =>
    jsonDecode(payload) as Map<String, dynamic>;
