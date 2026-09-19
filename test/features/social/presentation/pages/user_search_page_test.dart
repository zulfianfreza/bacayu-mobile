import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/social/domain/entities/followed_user.dart';
import 'package:mobile/features/social/domain/entities/user_search_results.dart';
import 'package:mobile/features/social/domain/repositories/social_repository.dart';
import 'package:mobile/features/social/domain/usecases/follow_user.dart';
import 'package:mobile/features/social/domain/usecases/search_users.dart';
import 'package:mobile/features/social/domain/usecases/unfollow_user.dart';
import 'package:mobile/features/social/presentation/cubit/user_search_bloc.dart';
import 'package:mobile/features/social/presentation/pages/user_search_page.dart';
import 'package:mobile/features/social/presentation/widgets/user_list_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockSocialRepository extends Mock implements SocialRepository {}

FollowedUser _user({bool isFollowing = false}) => FollowedUser(
  id: 'u1',
  name: 'Maya',
  avatarUrl: null,
  isFollowing: isFollowing,
  isFollowedBy: false,
);

/// An `Image` drawing [path] from the asset bundle.
Finder _assetImage(String path) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == path,
);

void main() {
  late _MockSocialRepository repository;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    repository = _MockSocialRepository();
    getIt.registerFactory<UserSearchBloc>(
      () => UserSearchBloc(
        SearchUsers(repository),
        FollowUser(repository),
        UnfollowUser(repository),
      ),
    );
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpSearch(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        // Pinned to the app's primary locale so the assertions below can name
        // the strings it actually ships with.
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UserSearchPage(),
      ),
    );
    await tester.pump();
  }

  /// Types a query and waits out the bloc's debounce window.
  Future<void> type(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
  }

  testWidgets('opens on its title with a prompt, not a result list', (
    tester,
  ) async {
    await pumpSearch(tester);

    expect(find.text('Cari teman'), findsOneWidget);
    expect(find.text('Cari nama teman'), findsOneWidget);
    expect(
      find.text('Follow teman biar aktivitas bacanya muncul di sini.'),
      findsOneWidget,
    );
    // The prompt carries the app's own "add people" artwork.
    expect(_assetImage('assets/icons/add-team-stroke.png'), findsOneWidget);
    expect(find.byType(UserListTile), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing shows people as followable cards', (tester) async {
    when(() => repository.searchUsers(query: 'maya', page: 1)).thenAnswer(
      (_) async => Right(
        UserSearchResults(users: [_user()], page: 1, totalPages: 1),
      ),
    );

    await pumpSearch(tester);
    await type(tester, 'maya');

    expect(find.byType(UserListTile), findsOneWidget);
    expect(find.text('Maya'), findsOneWidget);
    expect(find.text('Ikuti'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a search with no hits says so', (tester) async {
    when(() => repository.searchUsers(query: 'maya', page: 1)).thenAnswer(
      (_) async => const Right(
        UserSearchResults(users: [], page: 1, totalPages: 0),
      ),
    );

    await pumpSearch(tester);
    await type(tester, 'maya');

    expect(find.text('Tidak ada yang cocok'), findsOneWidget);
    expect(find.byType(UserListTile), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed search says so', (tester) async {
    when(() => repository.searchUsers(query: 'maya', page: 1)).thenAnswer(
      (_) async => const Left(ServerFailure(code: 'BOOM', message: 'boom')),
    );

    await pumpSearch(tester);
    await type(tester, 'maya');

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.byType(UserListTile), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
