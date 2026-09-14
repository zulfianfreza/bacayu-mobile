import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/app.dart';
import 'package:mobile/core/di/injection.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  testWidgets('BacaYuApp boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const BacaYuApp());
    await tester.pump();

    expect(find.text('BacaYu'), findsOneWidget);
  });
}
