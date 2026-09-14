import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/storage/app_database.dart';
import 'package:mobile/features/sessions/data/datasources/session_local_datasource.dart';
import 'package:mobile/features/sessions/data/datasources/session_remote_datasource.dart';
import 'package:mobile/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:mobile/features/sessions/domain/entities/reading_session.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionRemoteDataSource extends Mock implements SessionRemoteDataSource {}

ReadingSession _session({String clientId = 'client-1'}) {
  final start = DateTime(2026, 1, 1, 9, 0, 0);
  return ReadingSession(
    clientId: clientId,
    userBookId: 'ub-1',
    inputMode: 'timer',
    startTime: start,
    endTime: start.add(const Duration(minutes: 20)),
    activeDurationSeconds: const Duration(minutes: 20).inSeconds,
    pauseIntervals: const [],
    startPage: 10,
    endPage: 25,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  late AppDatabase db;
  late SessionLocalDataSource local;
  late _MockSessionRemoteDataSource remote;
  late SessionRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    local = SessionLocalDataSource(db);
    remote = _MockSessionRemoteDataSource();
    repository = SessionRepositoryImpl(remote, local);
  });

  tearDown(() => db.close());

  test(
      'submitSession succeeds from the caller\'s point of view even when '
      'offline — the session is queued in PendingSessions, not lost',
      () async {
    when(() => remote.submit(any())).thenAnswer(
      (_) async => throw DioException(
        requestOptions: RequestOptions(path: '/sessions'),
        type: DioExceptionType.connectionError,
      ),
    );

    final session = _session();
    final result = await repository.submitSession(session);

    // Success is reported immediately, based on the local save alone.
    expect(result, const Right<Failure, Unit>(unit));

    // Let the fire-and-forget background sync attempt run (and fail).
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final unsynced = await local.getUnsynced();
    expect(unsynced, hasLength(1));
    expect(unsynced.single.clientId, session.clientId);

    final payload = jsonDecode(unsynced.single.payload) as Map<String, dynamic>;
    expect(payload['user_book_id'], 'ub-1');
    expect(payload['start_page'], 10);
    expect(payload['end_page'], 25);
  });

  test(
      'submitSession marks the row synced once the background remote send '
      'succeeds', () async {
    when(() => remote.submit(any())).thenAnswer(
      (_) async => {'badges_unlocked': <dynamic>[]},
    );

    final session = _session(clientId: 'client-2');
    await repository.submitSession(session);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final unsynced = await local.getUnsynced();
    expect(unsynced, isEmpty);
  });

  test(
      'a DUPLICATE_SESSION response (retry of an already-landed client_id) '
      'is treated as synced, not left to retry forever', () async {
    when(() => remote.submit(any())).thenAnswer(
      (_) async => throw DioException(
        requestOptions: RequestOptions(path: '/sessions'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/sessions'),
          statusCode: 409,
          data: {
            'success': false,
            'status_code': 409,
            'timestamp': '2026-01-01T00:00:00Z',
            'request_id': 'req-1',
            'message': 'session already submitted',
            'data': {'code': 'DUPLICATE_SESSION', 'details': null},
          },
        ),
      ),
    );

    final session = _session(clientId: 'client-3');
    await repository.submitSession(session);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final unsynced = await local.getUnsynced();
    expect(unsynced, isEmpty);
  });
}
