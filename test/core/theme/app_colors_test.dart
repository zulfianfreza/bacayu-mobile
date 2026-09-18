import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Every ramp in the palette, 50 through 900, in that order.
const _ramps = <String, List<Color>>{
  'tangerine': [
    AppColors.tangerine50,
    AppColors.tangerine100,
    AppColors.tangerine200,
    AppColors.tangerine300,
    AppColors.tangerine400,
    AppColors.tangerine500,
    AppColors.tangerine600,
    AppColors.tangerine700,
    AppColors.tangerine800,
    AppColors.tangerine900,
  ],
  'lagoon': [
    AppColors.lagoon50,
    AppColors.lagoon100,
    AppColors.lagoon200,
    AppColors.lagoon300,
    AppColors.lagoon400,
    AppColors.lagoon500,
    AppColors.lagoon600,
    AppColors.lagoon700,
    AppColors.lagoon800,
    AppColors.lagoon900,
  ],
  'sunshine': [
    AppColors.sunshine50,
    AppColors.sunshine100,
    AppColors.sunshine200,
    AppColors.sunshine300,
    AppColors.sunshine400,
    AppColors.sunshine500,
    AppColors.sunshine600,
    AppColors.sunshine700,
    AppColors.sunshine800,
    AppColors.sunshine900,
  ],
  'slate': [
    AppColors.slate50,
    AppColors.slate100,
    AppColors.slate200,
    AppColors.slate300,
    AppColors.slate400,
    AppColors.slate500,
    AppColors.slate600,
    AppColors.slate700,
    AppColors.slate800,
    AppColors.slate900,
  ],
  'red': [
    AppColors.red50,
    AppColors.red100,
    AppColors.red200,
    AppColors.red300,
    AppColors.red400,
    AppColors.red500,
    AppColors.red600,
    AppColors.red700,
    AppColors.red800,
    AppColors.red900,
  ],
  'amber': [
    AppColors.amber50,
    AppColors.amber100,
    AppColors.amber200,
    AppColors.amber300,
    AppColors.amber400,
    AppColors.amber500,
    AppColors.amber600,
    AppColors.amber700,
    AppColors.amber800,
    AppColors.amber900,
  ],
  'green': [
    AppColors.green50,
    AppColors.green100,
    AppColors.green200,
    AppColors.green300,
    AppColors.green400,
    AppColors.green500,
    AppColors.green600,
    AppColors.green700,
    AppColors.green800,
    AppColors.green900,
  ],
  'blue': [
    AppColors.blue50,
    AppColors.blue100,
    AppColors.blue200,
    AppColors.blue300,
    AppColors.blue400,
    AppColors.blue500,
    AppColors.blue600,
    AppColors.blue700,
    AppColors.blue800,
    AppColors.blue900,
  ],
  'indigo': [
    AppColors.indigo50,
    AppColors.indigo100,
    AppColors.indigo200,
    AppColors.indigo300,
    AppColors.indigo400,
    AppColors.indigo500,
    AppColors.indigo600,
    AppColors.indigo700,
    AppColors.indigo800,
    AppColors.indigo900,
  ],
  'violet': [
    AppColors.violet50,
    AppColors.violet100,
    AppColors.violet200,
    AppColors.violet300,
    AppColors.violet400,
    AppColors.violet500,
    AppColors.violet600,
    AppColors.violet700,
    AppColors.violet800,
    AppColors.violet900,
  ],
  'purple': [
    AppColors.purple50,
    AppColors.purple100,
    AppColors.purple200,
    AppColors.purple300,
    AppColors.purple400,
    AppColors.purple500,
    AppColors.purple600,
    AppColors.purple700,
    AppColors.purple800,
    AppColors.purple900,
  ],
  'pink': [
    AppColors.pink50,
    AppColors.pink100,
    AppColors.pink200,
    AppColors.pink300,
    AppColors.pink400,
    AppColors.pink500,
    AppColors.pink600,
    AppColors.pink700,
    AppColors.pink800,
    AppColors.pink900,
  ],
  'cyan': [
    AppColors.cyan50,
    AppColors.cyan100,
    AppColors.cyan200,
    AppColors.cyan300,
    AppColors.cyan400,
    AppColors.cyan500,
    AppColors.cyan600,
    AppColors.cyan700,
    AppColors.cyan800,
    AppColors.cyan900,
  ],
};

/// Shortest distance between two hues on the colour wheel.
double _hueDistance(double a, double b) {
  final difference = (a - b).abs() % 360;
  return difference > 180 ? 360 - difference : difference;
}

void main() {
  group('every ramp', () {
    for (final entry in _ramps.entries) {
      test('${entry.key}: darkens one step at a time, 50 through 900', () {
        final lightness = entry.value
            .map((color) => HSLColor.fromColor(color).lightness)
            .toList();

        for (var i = 1; i < lightness.length; i++) {
          expect(
            lightness[i],
            lessThan(lightness[i - 1]),
            reason: '${entry.key} ${i * 100} is not darker than ${(i - 1) * 100}',
          );
        }
      });

      test('${entry.key}: stays in one hue family', () {
        // The 500 is the family's own definition; every other step is a tint or
        // a shade of it. A hex pasted from the wrong ramp lands here.
        final base = HSLColor.fromColor(entry.value[5]).hue;

        for (final (index, color) in entry.value.indexed) {
          expect(
            _hueDistance(HSLColor.fromColor(color).hue, base),
            lessThan(25),
            reason: '${entry.key} ${(index + 1) * 100} drifted off hue',
          );
        }
      });
    }
  });

  test('the tangerine ramp is complete — no step between 50 and 900 missing',
      () {
    expect(_ramps['tangerine'], hasLength(10));
  });

  test('semantic roles point at the families the style guide names', () {
    expect(AppColors.success, AppColors.lagoon500);
    expect(AppColors.danger, AppColors.berry);
    expect(AppColors.warning, AppColors.amber500);
    // Sunshine is reserved for achievements, so warning must not be it.
    expect(AppColors.warning, isNot(AppColors.sunshine500));
    expect(AppColors.info, AppColors.blue500);
  });
}
