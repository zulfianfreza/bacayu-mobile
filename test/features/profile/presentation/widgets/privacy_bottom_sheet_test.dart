import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/widgets/bordered_card.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/update_profile.dart';
import 'package:mobile/features/profile/presentation/widgets/privacy_bottom_sheet.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

User _user() => User(
  id: 'u1',
  email: 'reader@bacayu.app',
  name: 'Julian',
  avatarUrl: '',
  timezone: 'UTC',
  favoriteGenres: const [],
  yearlyGoalBooks: null,
  dailyGoalMinutes: null,
  currentStreak: 3,
  longestStreak: 5,
  lastReadDate: null,
  privacyDefault: 'private',
  onboardingCompletedAt: DateTime(2026, 1, 1),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  late _MockAuthRepository authRepository;

  setUp(() {
    authRepository = _MockAuthRepository();
    when(
      () => authRepository.updateProfile(
        favoriteGenres: any(named: 'favoriteGenres'),
        yearlyGoalBooks: any(named: 'yearlyGoalBooks'),
        dailyGoalMinutes: any(named: 'dailyGoalMinutes'),
        timezone: any(named: 'timezone'),
        privacyDefault: any(named: 'privacyDefault'),
      ),
    ).thenAnswer((_) async => Right(_user()));

    getIt.registerFactory<UpdateProfile>(() => UpdateProfile(authRepository));
  });

  tearDown(() async => getIt.reset());

  /// Hands back the value the sheet popped with.
  late bool? Function() opener;

  Future<void> pumpSheet(WidgetTester tester, String currentValue) async {
    bool? popped;
    opener = () => popped;

    await tester.pumpWidget(
      MaterialApp(
        // Pinned to the app's primary locale so the assertions below can name
        // the strings it actually ships with.
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  popped = await PrivacyBottomSheet.show(
                    context,
                    currentValue: currentValue,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder rowOf(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(BorderedCard));

  testWidgets('offers all three visibilities, ticking the current one', (
    tester,
  ) async {
    await pumpSheet(tester, 'private');

    expect(find.text('Privat'), findsOneWidget);
    expect(find.text('Pengikut'), findsOneWidget);
    expect(find.text('Publik'), findsOneWidget);
    expect(
      find.descendant(
        of: rowOf('Privat'),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: rowOf('Publik'),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking a new visibility saves it and pops true', (
    tester,
  ) async {
    await pumpSheet(tester, 'private');

    await tester.tap(find.text('Publik'));
    await tester.pumpAndSettle();

    verify(
      () => authRepository.updateProfile(
        favoriteGenres: any(named: 'favoriteGenres'),
        yearlyGoalBooks: any(named: 'yearlyGoalBooks'),
        dailyGoalMinutes: any(named: 'dailyGoalMinutes'),
        timezone: any(named: 'timezone'),
        privacyDefault: 'public',
      ),
    ).called(1);
    expect(opener(), isTrue);
    expect(find.byType(PrivacyBottomSheet), findsNothing);
  });

  testWidgets('picking the value already set saves nothing', (tester) async {
    await pumpSheet(tester, 'private');

    await tester.tap(find.text('Privat'));
    await tester.pumpAndSettle();

    verifyNever(
      () => authRepository.updateProfile(
        favoriteGenres: any(named: 'favoriteGenres'),
        yearlyGoalBooks: any(named: 'yearlyGoalBooks'),
        dailyGoalMinutes: any(named: 'dailyGoalMinutes'),
        timezone: any(named: 'timezone'),
        privacyDefault: any(named: 'privacyDefault'),
      ),
    );
    expect(opener(), isFalse);
  });
}
