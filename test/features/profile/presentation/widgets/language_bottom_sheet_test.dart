import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/localization/locale_cubit.dart';
import 'package:mobile/features/profile/presentation/widgets/language_bottom_sheet.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocaleCubit localeCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    localeCubit = LocaleCubit(await SharedPreferences.getInstance());
  });

  tearDown(() => localeCubit.close());

  Widget wrap() {
    return BlocProvider<LocaleCubit>.value(
      value: localeCubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => LanguageBottomSheet.show(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('picking English emits a Locale("en") from LocaleCubit',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('English'), findsOneWidget);
    expect(find.text('Bahasa Indonesia'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(localeCubit.state, const Locale('en'));
  });

  testWidgets('picking Bahasa Indonesia emits a Locale("id") and closes the sheet',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bahasa Indonesia'));
    await tester.pumpAndSettle();

    expect(localeCubit.state, const Locale('id'));
    // Sheet closed itself after the pick.
    expect(find.byType(LanguageBottomSheet), findsNothing);
  });

  testWidgets('the currently active locale shows a checkmark', (tester) async {
    await localeCubit.setLocale(const Locale('id'));
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final indonesianTile = tester.widget<ListTile>(
      find.ancestor(of: find.text('Bahasa Indonesia'), matching: find.byType(ListTile)),
    );
    expect(indonesianTile.trailing, isNotNull);

    final englishTile = tester.widget<ListTile>(
      find.ancestor(of: find.text('English'), matching: find.byType(ListTile)),
    );
    expect(englishTile.trailing, isNull);
  });
}
