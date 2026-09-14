import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/error/failure_localizer.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// [FailureLocalizer.localizedMessage] needs a [BuildContext] with
/// [AppLocalizations] in the tree, so this runs as a widget test rather
/// than a plain unit test.
Future<void> _withLocalizedContext(
  WidgetTester tester,
  void Function(BuildContext context) body,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          body(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

void main() {
  group('FailureLocalizer.localizedMessage', () {
    testWidgets('known server code maps to the matching l10n string',
        (tester) async {
      await _withLocalizedContext(tester, (context) {
        const failure = ServerFailure(
          code: 'SESSION_NOT_FOUND',
          message: 'session not found',
        );

        expect(
          failure.localizedMessage(context),
          AppLocalizations.of(context)!.sessionNotFound,
        );
      });
    });

    testWidgets(
        'unknown server code falls back to the raw backend message',
        (tester) async {
      await _withLocalizedContext(tester, (context) {
        const failure = ServerFailure(
          code: 'SOME_BRAND_NEW_CODE',
          message: 'a message the mobile app has never seen before',
        );

        expect(
          failure.localizedMessage(context),
          'a message the mobile app has never seen before',
        );
      });
    });

    testWidgets('NetworkFailure maps to noInternetConnection',
        (tester) async {
      await _withLocalizedContext(tester, (context) {
        expect(
          const NetworkFailure().localizedMessage(context),
          AppLocalizations.of(context)!.noInternetConnection,
        );
      });
    });

    testWidgets('ValidationFailure surfaces the first field message',
        (tester) async {
      await _withLocalizedContext(tester, (context) {
        const failure = ValidationFailure(
          details: {'end_page': 'must be greater than start_page'},
        );

        expect(
          failure.localizedMessage(context),
          'must be greater than start_page',
        );
      });
    });
  });
}
