import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/app.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/notifications/data/services/firebase_messaging_gateway.dart';

class _MockFirebaseMessagingGateway extends Mock
    implements FirebaseMessagingGateway {}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
    // GoRouter now depends on AuthCubit (for refreshListenable — see
    // app_router.dart), and AuthCubit's constructor chain reaches
    // PushNotificationService -> FirebaseMessagingGateway ->
    // `FirebaseMessaging.instance`, which throws without a real
    // `Firebase.initializeApp()` (never called in this smoke test, same as
    // before this dependency existed). Overriding just this one leaf with a
    // mock — the only Firebase-touching piece of that chain — keeps this
    // test a real app boot without needing full firebase_core platform
    // channel mocking for a smoke test that never exercises push
    // notifications at all.
    if (getIt.isRegistered<FirebaseMessagingGateway>()) {
      getIt.unregister<FirebaseMessagingGateway>();
    }
    getIt.registerLazySingleton<FirebaseMessagingGateway>(
      () => _MockFirebaseMessagingGateway(),
    );
    // AuthCubit is a singleton now — resolve it once up front so
    // `getIt<GoRouter>()` (built during `BacaYuApp`'s first frame) picks up
    // this test run's instance deterministically.
    getIt<AuthCubit>();
  });

  testWidgets('BacaYuApp boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const BacaYuApp());
    await tester.pump();

    expect(find.text('BacaYu'), findsOneWidget);
  });
}
