import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/features/shelf/presentation/widgets/status_picker_bottom_sheet.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  ShelfStatus? result;

  Widget wrap(ShelfStatus currentStatus) {
    result = null;
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await StatusPickerBottomSheet.show(
                  context,
                  currentStatus: currentStatus,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows all 4 status options', (tester) async {
    await tester.pumpWidget(wrap(ShelfStatus.reading));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Want to read'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Finished'), findsOneWidget);
    expect(find.text('DNF'), findsOneWidget);
  });

  testWidgets('picking a different status pops with that ShelfStatus and closes the sheet',
      (tester) async {
    await tester.pumpWidget(wrap(ShelfStatus.reading));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finished'));
    await tester.pumpAndSettle();

    expect(result, ShelfStatus.finished);
    expect(find.byType(StatusPickerBottomSheet), findsNothing);
  });

  testWidgets('the current status option is highlighted and disabled', (tester) async {
    await tester.pumpWidget(wrap(ShelfStatus.reading));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final readingTile = tester.widget<ListTile>(
      find.ancestor(of: find.text('Reading'), matching: find.byType(ListTile)),
    );
    expect(readingTile.enabled, isFalse);
    expect(readingTile.trailing, isNotNull);

    // Tapping the disabled current option does nothing — sheet stays open.
    await tester.tap(find.text('Reading'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(find.byType(StatusPickerBottomSheet), findsOneWidget);

    final finishedTile = tester.widget<ListTile>(
      find.ancestor(of: find.text('Finished'), matching: find.byType(ListTile)),
    );
    expect(finishedTile.enabled, isTrue);
    expect(finishedTile.trailing, isNull);
  });
}
