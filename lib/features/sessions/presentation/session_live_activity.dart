import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SessionLiveActivity {
  static const channel = MethodChannel('app.bacayu/session_activity');
  Future<void> _pending = Future.value();

  Future<void> update({
    required String title,
    required String status,
    required Duration elapsed,
    required bool paused,
    required int tint,
    String runningLabel = '',
    String pausedLabel = '',
    String pauseLabel = '',
    String resumeLabel = '',
  }) => _send('update', {
    'title': title,
    'status': status,
    'elapsed': elapsed.inMilliseconds / 1000,
    'referenceDate': DateTime.now().millisecondsSinceEpoch / 1000,
    'paused': paused,
    'tint': tint,
    'runningLabel': runningLabel,
    'pausedLabel': pausedLabel,
    'pauseLabel': pauseLabel,
    'resumeLabel': resumeLabel,
  });

  Future<void> end() => _send('end', null);

  Future<void> consumeEvents(
    void Function(bool paused, DateTime at) apply,
  ) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    await _pending;
    try {
      final events = await channel.invokeListMethod<Object?>('events');
      for (final event in events ?? []) {
        if (event is! Map ||
            event['paused'] is! bool ||
            event['timestamp'] is! num) {
          continue;
        }
        final timestamp = (event['timestamp'] as num).toDouble();
        if (!timestamp.isFinite) continue;
        apply(
          event['paused'] as bool,
          DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).round()),
        );
      }
    } on PlatformException catch (error) {
      debugPrint('Session Live Activity: ${error.code}');
    } on MissingPluginException {
      // Other platforms keep their existing Flutter-only controls.
    }
  }

  Future<void> _send(String method, Map<String, Object>? arguments) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return Future.value();
    }
    return _pending = _pending.then((_) async {
      try {
        await channel.invokeMethod<void>(method, arguments);
      } on PlatformException catch (error) {
        debugPrint('Session Live Activity: ${error.code}');
      } on MissingPluginException {
        // Native activity support is optional; session recording must continue.
      }
    });
  }
}
