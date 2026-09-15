import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/social/domain/usecases/like_activity.dart';
import 'package:mobile/features/social/domain/usecases/unlike_activity.dart';
import 'package:mobile/features/social/presentation/widgets/like_button.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockLikeActivity extends Mock implements LikeActivity {}

class _MockUnlikeActivity extends Mock implements UnlikeActivity {}

void main() {
  late _MockLikeActivity mockLike;
  late _MockUnlikeActivity mockUnlike;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    mockLike = _MockLikeActivity();
    mockUnlike = _MockUnlikeActivity();
    // Standalone DI registration — no full configureDependencies() needed,
    // LikeButton only ever reaches for these two types.
    getIt
      ..registerFactory<LikeActivity>(() => mockLike)
      ..registerFactory<UnlikeActivity>(() => mockUnlike);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets(
      'tapping flips the icon/count immediately (optimistic), before the '
      'network call resolves', (tester) async {
    final completer = Completer<Either<Failure, Unit>>();
    when(() => mockLike.call(any())).thenAnswer((_) => completer.future);

    await tester.pumpWidget(wrap(
      const LikeButton(activityId: 'a1', initialIsLiked: false, initialLikeCount: 3),
    ));

    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byType(LikeButton));
    await tester.pump(); // one frame only — the network call is still pending

    expect(find.text('4'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    completer.complete(const Right(unit));
    await tester.pumpAndSettle();
  });

  testWidgets('rolls back the optimistic update when the request fails',
      (tester) async {
    final completer = Completer<Either<Failure, Unit>>();
    when(() => mockLike.call(any())).thenAnswer((_) => completer.future);

    await tester.pumpWidget(wrap(
      const LikeButton(activityId: 'a1', initialIsLiked: false, initialLikeCount: 3),
    ));

    await tester.tap(find.byType(LikeButton));
    await tester.pump();

    // Still optimistically liked while the request is in flight.
    expect(find.text('4'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    completer.complete(const Left(NetworkFailure()));
    await tester.pump(); // resolve the future + rebuild
    await tester.pump(); // let the snackbar animate in

    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('unliking an already-liked activity also rolls back on failure',
      (tester) async {
    final completer = Completer<Either<Failure, Unit>>();
    when(() => mockUnlike.call(any())).thenAnswer((_) => completer.future);

    await tester.pumpWidget(wrap(
      const LikeButton(activityId: 'a1', initialIsLiked: true, initialLikeCount: 5),
    ));

    await tester.tap(find.byType(LikeButton));
    await tester.pump();

    expect(find.text('4'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    completer.complete(const Left(NetworkFailure()));
    await tester.pump();
    await tester.pump();

    expect(find.text('5'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
