import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/badges/domain/entities/badge.dart';
import 'package:mobile/features/badges/domain/repositories/badge_repository.dart';
import 'package:mobile/features/badges/domain/usecases/get_all_badges.dart';
import 'package:mobile/features/badges/presentation/cubit/badge_cubit.dart';
import 'package:mobile/features/badges/presentation/pages/badge_gallery_page.dart';
import 'package:mobile/features/badges/presentation/widgets/badge_artwork.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockBadgeRepository extends Mock implements BadgeRepository {}

Badge _badge(
  String id, {
  required bool unlocked,
  String name = 'First Step',
}) => Badge(
  id: id,
  name: name,
  icon: '🎉',
  description: 'A badge',
  imageUrl: null,
  unlocked: unlocked,
  unlockedAt: unlocked ? DateTime(2026, 1, 1) : null,
);

void main() {
  late _MockBadgeRepository badgeRepository;

  setUp(() {
    badgeRepository = _MockBadgeRepository();
    getIt.registerFactory<BadgeCubit>(
      () => BadgeCubit(GetAllBadges(badgeRepository)),
    );
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpGallery(WidgetTester tester) async {
    // Wider than a phone: the test font is wider than Nunito, and two cards a
    // row would otherwise be the thing overflowing.
    tester.view.physicalSize = const Size(700 * 2, 1400 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        // Pinned to the app's primary locale so the assertions below can name
        // the strings it actually ships with.
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BadgeGalleryPage(),
      ),
    );
    await tester.pumpAndSettle();
  }

  void stubBadges(List<Badge> badges) {
    when(() => badgeRepository.getAllBadges())
        .thenAnswer((_) async => Right(badges));
  }

  testWidgets('leads with how much of the set is collected', (tester) async {
    stubBadges([
      _badge('b1', unlocked: true),
      _badge('b2', unlocked: true, name: 'Bookworm'),
      _badge('b3', unlocked: false, name: 'Night Owl'),
    ]);

    await pumpGallery(tester);

    expect(find.text('2 dari 3 terkumpul'), findsOneWidget);
    expect(find.text('First Step'), findsOneWidget);
    expect(find.text('Bookworm'), findsOneWidget);
    expect(find.text('Night Owl'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('each badge says whether it is unlocked, not just shows it', (
    tester,
  ) async {
    stubBadges([
      _badge('b1', unlocked: true),
      _badge('b2', unlocked: false, name: 'Night Owl'),
    ]);

    await pumpGallery(tester);

    expect(find.text('Terbuka'), findsOneWidget);
    expect(find.text('Terkunci'), findsOneWidget);
    // Artwork for every badge, locked ones included.
    expect(find.byType(BadgeArtwork), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty set gets a message, not a blank page', (tester) async {
    stubBadges(const []);

    await pumpGallery(tester);

    expect(find.text('Belum ada badge — terus baca!'), findsOneWidget);
    expect(find.text('0 dari 0 terkumpul'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed load says so', (tester) async {
    when(() => badgeRepository.getAllBadges())
        .thenAnswer((_) async => const Left(CacheFailure()));

    await pumpGallery(tester);

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.byType(BadgeArtwork), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
