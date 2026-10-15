import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/sessions/presentation/session_live_activity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'activity updates stay ordered and native errors do not block end',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final calls = <MethodCall>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SessionLiveActivity.channel, (
        call,
      ) async {
        calls.add(call);
        if (calls.length == 1) throw PlatformException(code: 'DISABLED');
        return null;
      });
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
        messenger.setMockMethodCallHandler(SessionLiveActivity.channel, null);
      });
      final activity = SessionLiveActivity();
      final running = activity.update(
        title: 'Book',
        status: 'Reading',
        elapsed: const Duration(seconds: 12),
        paused: false,
        tint: 0xFFFF0000,
      );
      final paused = activity.update(
        title: 'Book',
        status: 'Paused',
        elapsed: const Duration(seconds: 14),
        paused: true,
        tint: 0xFFFF0000,
      );
      await activity.end();
      await Future.wait([running, paused]);
      expect(calls.map((call) => call.method), ['update', 'update', 'end']);
      expect(calls[0].arguments['elapsed'], 12.0);
      expect(calls[1].arguments['paused'], true);
    },
  );
}
