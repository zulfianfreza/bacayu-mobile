import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';

/// Bridges the streak data already loaded in-app to the native home-screen
/// widget's shared storage (Android `SharedPreferences` / iOS `UserDefaults`
/// via App Group) — a technical wrapper, not a feature (CLAUDE.md Section 4).
///
/// This never computes or fetches anything itself — callers (currently just
/// `HomeCubit`) push data they already have after a successful load. Refresh
/// is app-driven only: there is no background job re-invoking this, so the
/// widget shows whatever was last pushed while the app was open.
@lazySingleton
class StreakWidgetService {
  /// Must match the Android `<receiver>` name in AndroidManifest.xml and the
  /// iOS App Group id configured on the Widget Extension target.
  static const _androidWidgetProvider = 'StreakWidgetProvider';
  static const _iosWidgetKind = 'StreakWidget';
  static const _appGroupId = 'group.com.example.mobile.streak';

  static const keyCurrentStreak = 'currentStreak';
  static const keyLongestStreak = 'longestStreak';
  static const keyLast7Days = 'last7Days';

  bool _groupIdSet = false;

  /// Best-effort by design (see class docstring) — any failure here (plugin
  /// unavailable, no App Group configured yet, etc.) is swallowed rather
  /// than surfaced, since the widget is a bonus surface, never something the
  /// home screen's own load should fail over.
  Future<void> push({
    required int currentStreak,
    required int longestStreak,
    required List<bool> last7DaysHasActivity,
  }) async {
    assert(last7DaysHasActivity.length == 7);

    try {
      if (!_groupIdSet) {
        await HomeWidget.setAppGroupId(_appGroupId);
        _groupIdSet = true;
      }

      await HomeWidget.saveWidgetData<int>(keyCurrentStreak, currentStreak);
      await HomeWidget.saveWidgetData<int>(keyLongestStreak, longestStreak);
      await HomeWidget.saveWidgetData<String>(
        keyLast7Days,
        last7DaysHasActivity
            .map((hasActivity) => hasActivity ? '1' : '0')
            .join(),
      );

      await HomeWidget.updateWidget(
        androidName: _androidWidgetProvider,
        iOSName: _iosWidgetKind,
      );
    } catch (_) {
      // Swallowed — see docstring above.
    }
  }
}
