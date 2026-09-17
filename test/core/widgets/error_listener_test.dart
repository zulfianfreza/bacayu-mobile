import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/widgets/error_listener.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Widget wrap(Failure failure) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.showFailureSnackBar(failure),
              child: const Text('trigger'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('SessionExpiredFailure is skipped — no snackbar shown',
      (tester) async {
    await tester.pumpWidget(wrap(const SessionExpiredFailure()));

    await tester.tap(find.text('trigger'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('NetworkFailure still shows its localized snackbar',
      (tester) async {
    await tester.pumpWidget(wrap(const NetworkFailure()));

    await tester.tap(find.text('trigger'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('ServerFailure still shows its localized snackbar',
      (tester) async {
    await tester.pumpWidget(wrap(
      const ServerFailure(code: 'SESSION_NOT_FOUND', message: 'fallback'),
    ));

    await tester.tap(find.text('trigger'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
