import 'dart:math';

import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';

enum WidgetStreakState {
  repair,
  frozenSafe,
  done,
  calm,
  reminder,
  urgent,
  critical,
}

class WidgetBundleSelection {
  const WidgetBundleSelection({
    required this.bundleId,
    required this.backgroundRes,
    required this.mascotRes,
    required this.text,
  });

  final String bundleId;
  final String backgroundRes;
  final String mascotRes;
  final String text;
}

WidgetStreakState resolveWidgetState({
  required bool readToday,
  required int currentStreak,
  required DateTime now,
  bool streakFrozen = false,
}) {
  if (currentStreak == 0) return WidgetStreakState.repair;
  if (streakFrozen && !readToday) return WidgetStreakState.frozenSafe;
  if (readToday) return WidgetStreakState.done;
  final minutes = now.hour * 60 + now.minute;
  if (minutes < 10 * 60) return WidgetStreakState.calm;
  if (minutes <= 22 * 60) return WidgetStreakState.reminder;
  if (minutes <= 23 * 60 + 30) return WidgetStreakState.urgent;
  return WidgetStreakState.critical;
}

const _bundles = <WidgetStreakState, List<(String, List<String>)>>{
  WidgetStreakState.calm: [
    ('calm_a', ['Bacaaa yuk!', 'Ada waktu buat baca?']),
    ('calm_b', ['Mulai lebih awal!', 'Semangat pagi!']),
    ('calm_c', ['Belajar pagi-pagi?', 'Masih ngantuk ya?']),
  ],
  WidgetStreakState.reminder: [
    ('reminder_a', ['Belum baca hari ini?', 'Waktunya baca, nih!']),
    ('reminder_b', ['Jangan lupa baca ya!', 'Sisa waktu makin tipis']),
    ('reminder_c', ['Yuk sisihin waktu bentar', 'Streak-mu nunggu nih']),
  ],
  WidgetStreakState.urgent: [
    ('urgent_a', ['Streak-mu mau hilang!', 'Ayo sebelum kemalaman!']),
    ('urgent_b', ['Cepetan, waktu hampir habis!', 'Jangan sampai putus!']),
  ],
  WidgetStreakState.critical: [
    ('critical_a', ['Last chance!', 'Sekarang atau nggak sama sekali!']),
    ('critical_b', ['Baca sekarang atau hilang!', 'Detik-detik terakhir!']),
  ],
  WidgetStreakState.repair: [
    ('repair_a', ['Yuk mulai lagi', 'Nggak apa-apa, coba lagi']),
    ('repair_b', ['Semua orang pernah gagal', 'Ayo bangkit lagi!']),
  ],
  WidgetStreakState.done: [
    ('done_a', ['Mantap, udah baca!', 'Kerja bagus hari ini!']),
    ('done_b', ['Keren, streak aman!', 'Terus lanjutkan!']),
    ('done_c', ['Sampai besok ya!', 'Istirahat, kamu hebat!']),
  ],
  WidgetStreakState.frozenSafe: [
    ('frozen_a', ['Streak-mu aman', 'Dilindungi buat hari ini']),
  ],
};

WidgetBundleSelection selectBundleAndText(
  WidgetStreakState state,
  String userId,
  DateTime today,
) {
  final date =
      '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  final seed = '$userId$date${state.name}'.hashCode;
  final options = _bundles[state]!;
  final bundle = options[Random(seed).nextInt(options.length)];
  // Separate generator keeps text roll independent from bundle roll.
  final text = bundle.$2[Random(seed ^ 0x5f3759df).nextInt(bundle.$2.length)];
  return WidgetBundleSelection(
    bundleId: bundle.$1,
    backgroundRes: 'widget_bg_${bundle.$1}',
    mascotRes: 'mascot_${bundle.$1}',
    text: text,
  );
}

@lazySingleton
class StreakWidgetService {
  static const _androidWidgetProvider = 'StreakWidgetProvider';
  static const _iosWidgetKind = 'StreakWidget';
  static const _appGroupId = 'group.com.example.mobile.streak';
  static const keyCurrentStreak = 'current_streak';
  static const keyWeeklyHeatmap = 'weekly_heatmap';
  static const _keyState = 'widget_streak_state';
  static const _keyBundle = 'bundle_id';
  static const _keyBackground = 'background_res_name';
  static const _keyMascot = 'mascot_res_name';
  static const _keyMessage = 'message_text';

  bool _groupIdSet = false;

  Future<void> updateStreakWidget({
    required String userId,
    required int currentStreak,
    required List<bool> weeklyHeatmap,
    DateTime? now,
    bool streakFrozen = false,
  }) async {
    assert(weeklyHeatmap.length == 7);
    try {
      if (!_groupIdSet) {
        await HomeWidget.setAppGroupId(_appGroupId);
        _groupIdSet = true;
      }
      final timestamp = now ?? DateTime.now();
      final readToday = weeklyHeatmap.last;
      final state = resolveWidgetState(
        readToday: readToday,
        currentStreak: currentStreak,
        now: timestamp,
        streakFrozen: streakFrozen,
      );
      final oldState = await HomeWidget.getWidgetData<String>(_keyState);
      final oldBundle = await HomeWidget.getWidgetData<String>(_keyBundle);
      final oldText = await HomeWidget.getWidgetData<String>(_keyMessage);
      final selection =
          oldState == state.name && oldBundle != null && oldText != null
          ? WidgetBundleSelection(
              bundleId: oldBundle,
              backgroundRes:
                  await HomeWidget.getWidgetData<String>(_keyBackground) ??
                  'widget_bg_$oldBundle',
              mascotRes:
                  await HomeWidget.getWidgetData<String>(_keyMascot) ??
                  'mascot_$oldBundle',
              text: oldText,
            )
          : selectBundleAndText(state, userId, timestamp);

      await Future.wait([
        HomeWidget.saveWidgetData<String>(_keyState, state.name),
        HomeWidget.saveWidgetData<String>(_keyBundle, selection.bundleId),
        HomeWidget.saveWidgetData<String>(
          _keyBackground,
          selection.backgroundRes,
        ),
        HomeWidget.saveWidgetData<String>(_keyMascot, selection.mascotRes),
        HomeWidget.saveWidgetData<String>(_keyMessage, selection.text),
        HomeWidget.saveWidgetData<int>(keyCurrentStreak, currentStreak),
        HomeWidget.saveWidgetData<String>(
          keyWeeklyHeatmap,
          weeklyHeatmap.map((value) => value ? '1' : '0').join(),
        ),
      ]);
      await HomeWidget.updateWidget(
        androidName: _androidWidgetProvider,
        iOSName: _iosWidgetKind,
      );
    } catch (_) {
      // Widget must never block reading flow.
    }
  }

  Future<void> push({
    required String userId,
    required int currentStreak,
    required int longestStreak,
    required List<bool> last7DaysHasActivity,
  }) => updateStreakWidget(
    userId: userId,
    currentStreak: currentStreak,
    weeklyHeatmap: last7DaysHasActivity,
  );
}
