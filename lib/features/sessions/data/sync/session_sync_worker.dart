import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../datasources/session_local_datasource.dart';
import '../datasources/session_remote_datasource.dart';
import '../repositories/session_repository_impl.dart';

const _duplicateSessionCode = 'DUPLICATE_SESSION';
const _baseBackoff = Duration(seconds: 15);
const _maxBackoff = Duration(minutes: 5);

@module
abstract class ConnectivityModule {
  @lazySingleton
  Connectivity get connectivity => Connectivity();
}

/// Retries `PendingSessions` rows that didn't sync on their first attempt —
/// CLAUDE.md Section 6.2. Runs on a self-rescheduling timer (simple
/// exponential backoff while there's nothing to send or sends keep
/// failing) and jumps the queue on reconnect. Deliberately NOT
/// `workmanager`-based: that needs native platform wiring (Android
/// callback dispatcher, iOS BGTaskScheduler) this pass doesn't cover —
/// `connectivity_plus` + a foreground timer is the CLAUDE.md-sanctioned
/// alternative ("workmanager ATAU connectivity_plus").
@lazySingleton
class SessionSyncWorker {
  SessionSyncWorker(this._local, this._remote, this._connectivity);

  final SessionLocalDataSource _local;
  final SessionRemoteDataSource _remote;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _timer;
  Duration _backoff = _baseBackoff;
  bool _isSyncing = false;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _scheduleNext(Duration.zero);
  }

  void dispose() {
    _started = false;
    _connectivitySubscription?.cancel();
    _timer?.cancel();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isConnected = results.any((r) => r != ConnectivityResult.none);
    if (isConnected) _scheduleNext(Duration.zero);
  }

  void _scheduleNext(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, () async {
      await syncNow();
      _scheduleNext(_backoff);
    });
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final pending = await _local.getUnsynced();
      if (pending.isEmpty) {
        _backoff = _baseBackoff;
        return;
      }

      var anyFailed = false;
      for (final row in pending) {
        final payload = decodePendingSessionPayload(row.payload);
        try {
          await _remote.submit(payload);
          await _local.markSynced(row.clientId);
        } on DioException catch (e) {
          final failure = mapDioExceptionToFailure(e);
          if (failure is ServerFailure && failure.code == _duplicateSessionCode) {
            await _local.markSynced(row.clientId);
          } else {
            anyFailed = true;
          }
        }
      }

      _backoff = anyFailed
          ? Duration(
              seconds: (_backoff.inSeconds * 2).clamp(
                _baseBackoff.inSeconds,
                _maxBackoff.inSeconds,
              ),
            )
          : _baseBackoff;
    } finally {
      _isSyncing = false;
    }
  }
}
