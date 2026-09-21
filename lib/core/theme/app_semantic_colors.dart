import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic color tokens — the roles that flip between light and dark.
///
/// `AppColors` holds the *palette* (ramps that mean the same thing in both
/// modes: tangerine500 is tangerine500, period). This extension holds the
/// *roles* — surface, primary text, hairline, the chip recipe — whose correct
/// value depends on brightness. Widgets read them through `context.colors`
/// (see `build_context_extension.dart`); never branch on `Theme.brightness` in
/// feature code, and never hardcode a light-mode token where a role is meant.
///
/// The light values are the tokens the app already used, unchanged. The dark
/// values follow Style Guide 2.4: warm dark surfaces (`darkBackground`,
/// `darkSurface`), warm off-white text, and tinted chips derived by lerping
/// the family's 500 step over the dark surface — the dark counterpart of the
/// 50/100 tints, which would glare if kept.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.background,
    required this.surface,
    required this.ink,
    required this.textSecondary,
    required this.textFaint,
    required this.hairline,
    required this.tangerineTint,
    required this.tangerineWash,
    required this.tangerineAccent,
    required this.lagoonTint,
    required this.lagoonWash,
    required this.lagoonAccent,
    required this.sunshineTint,
    required this.sunshineAccent,
    required this.dangerTint,
    required this.infoTint,
    required this.infoAccent,
    required this.heatmapRamp,
  });

  /// The page behind everything. Light keeps it the same white as [surface]
  /// (the app's flat light look); dark splits it one step darker so cards
  /// read as raised without shadows.
  final Color background;

  /// Cards, sheets, pickers, bars — everything that sits on [background].
  final Color surface;

  /// Primary text on [surface]. Ink in light; warm off-white in dark.
  final Color ink;

  /// Captions, secondary text, inactive labels. slate600 light; a warm grey
  /// in dark (see [_mutedInk]).
  final Color textSecondary;

  /// Placeholders, chevrons, disabled icons. slate400 light; a darker warm
  /// grey in dark.
  final Color textFaint;

  /// Borders, dividers, hairlines, progress tracks. slate200 light; a warm
  /// dark line in dark — a cool slate would go muddy on the warm surfaces.
  final Color hairline;

  /// Chip recipe, tangerine family: step-100 body in light, a dark tint in
  /// dark. [tangerineWash] is the same recipe one step weaker (step 50) for
  /// large-area washes.
  final Color tangerineTint;
  final Color tangerineWash;

  /// Text/icons on [tangerineTint]: step 700 in light, step 300 in dark —
  /// on-tint text always shifts *away* from the background, whichever mode.
  final Color tangerineAccent;

  /// Chip recipe, lagoon family — see [tangerineTint].
  final Color lagoonTint;
  final Color lagoonWash;
  final Color lagoonAccent;

  /// Chip recipe, sunshine family — see [tangerineTint]. No wash: sunshine
  /// never covers large areas (it is reserved for achievements).
  final Color sunshineTint;
  final Color sunshineAccent;

  /// The destructive bubble: berry at 12% in light, a dark berry tint in dark.
  final Color dangerTint;

  /// Info-family chip body (the one blue in the palette). blue100 light.
  final Color infoTint;

  /// Text/icons on [infoTint] — blue700 light, blue300 dark (same
  /// away-from-background rule as [tangerineAccent]).
  final Color infoAccent;

  /// Heatmap intensities, dimmest first — index 0 is the "nothing read" cell
  /// (a surface role, not a data one). Light walks the Tangerine ramp's dark
  /// steps, per Style Guide 6.7. Dark walks its *bright* steps instead: on a
  /// dark surface intensity reads as contrast, so a darker orange would read
  /// as less, not more.
  final List<Color> heatmapRamp;

  /// The light roles — exactly the tokens the app used before dark mode
  /// existed, so light rendering is pixel-identical.
  static const light = AppSemanticColors(
    background: AppColors.background,
    surface: AppColors.surface,
    ink: AppColors.ink,
    textSecondary: AppColors.slate600,
    textFaint: AppColors.slate400,
    hairline: AppColors.slate200,
    tangerineTint: AppColors.tangerine100,
    tangerineWash: AppColors.tangerine50,
    tangerineAccent: AppColors.tangerine700,
    lagoonTint: AppColors.lagoon100,
    lagoonWash: AppColors.lagoon50,
    lagoonAccent: AppColors.lagoon700,
    sunshineTint: AppColors.sunshine100,
    sunshineAccent: AppColors.sunshine700,
    dangerTint: Color.fromRGBO(255, 77, 109, 0.12),
    infoTint: AppColors.blue100,
    infoAccent: AppColors.blue700,
    heatmapRamp: [
      AppColors.slate200,
      AppColors.tangerine200,
      AppColors.tangerine300,
      AppColors.tangerine400,
      AppColors.tangerine500,
      AppColors.tangerine700,
    ],
  );

  /// The dark roles, from the Style Guide 2.4 anchors. Tints and washes are
  /// derived, not hand-picked: the family's 500 step lerped over
  /// [AppColors.darkSurface], which keeps hue and saturation honest and the
  /// whole set in sync with the anchors.
  static AppSemanticColors get dark => AppSemanticColors(
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        ink: AppColors.darkInk,
        textSecondary: _mutedInk(0.5),
        textFaint: _mutedInk(0.4),
        hairline: AppColors.darkHairline,
        tangerineTint: _tint(AppColors.tangerine500),
        tangerineWash: _wash(AppColors.tangerine500),
        tangerineAccent: AppColors.tangerine300,
        lagoonTint: _tint(AppColors.lagoon500),
        lagoonWash: _wash(AppColors.lagoon500),
        lagoonAccent: AppColors.lagoon300,
        sunshineTint: _tint(AppColors.sunshine500),
        sunshineAccent: AppColors.sunshine300,
        dangerTint: _tint(AppColors.berry, strength: 0.24),
        infoTint: _tint(AppColors.blue500, strength: 0.24),
        infoAccent: AppColors.blue300,
        // Brightening steps: the top of the light ramp is the *darkest*
        // orange, which would read as the weakest cell on a dark surface.
        heatmapRamp: const [
          AppColors.darkHairline,
          AppColors.tangerine800,
          AppColors.tangerine700,
          AppColors.tangerine600,
          AppColors.tangerine500,
          AppColors.tangerine400,
        ],
      );

  /// A chip body in dark mode: the family's base colour carried just far
  /// enough into the dark surface to read as a tint, not as a glow.
  static Color _tint(Color family, {double strength = 0.2}) =>
      Color.lerp(AppColors.darkSurface, family, strength)!;

  /// A large-area wash in dark mode: same idea, half the strength — the
  /// counterpart of a step-50 tint, which has to stay quiet at that size.
  static Color _wash(Color family) =>
      Color.lerp(AppColors.darkSurface, family, 0.1)!;

  /// Muted text in dark mode: [AppColors.darkInk] pulled back toward the warm
  /// [AppColors.darkSurface], rather than a slate step. A cool slate on the
  /// warm surfaces reads as a muddy blue-grey — the same reason [hairline] is
  /// warm. [t] sets how far toward the ink: higher is brighter.
  static Color _mutedInk(double t) =>
      Color.lerp(AppColors.darkSurface, AppColors.darkInk, t)!;

  @override
  AppSemanticColors copyWith({
    Color? background,
    Color? surface,
    Color? ink,
    Color? textSecondary,
    Color? textFaint,
    Color? hairline,
    Color? tangerineTint,
    Color? tangerineWash,
    Color? tangerineAccent,
    Color? lagoonTint,
    Color? lagoonWash,
    Color? lagoonAccent,
    Color? sunshineTint,
    Color? sunshineAccent,
    Color? dangerTint,
    Color? infoTint,
    Color? infoAccent,
    List<Color>? heatmapRamp,
  }) {
    return AppSemanticColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      textSecondary: textSecondary ?? this.textSecondary,
      textFaint: textFaint ?? this.textFaint,
      hairline: hairline ?? this.hairline,
      tangerineTint: tangerineTint ?? this.tangerineTint,
      tangerineWash: tangerineWash ?? this.tangerineWash,
      tangerineAccent: tangerineAccent ?? this.tangerineAccent,
      lagoonTint: lagoonTint ?? this.lagoonTint,
      lagoonWash: lagoonWash ?? this.lagoonWash,
      lagoonAccent: lagoonAccent ?? this.lagoonAccent,
      sunshineTint: sunshineTint ?? this.sunshineTint,
      sunshineAccent: sunshineAccent ?? this.sunshineAccent,
      dangerTint: dangerTint ?? this.dangerTint,
      infoTint: infoTint ?? this.infoTint,
      infoAccent: infoAccent ?? this.infoAccent,
      heatmapRamp: heatmapRamp ?? this.heatmapRamp,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      tangerineTint: Color.lerp(tangerineTint, other.tangerineTint, t)!,
      tangerineWash: Color.lerp(tangerineWash, other.tangerineWash, t)!,
      tangerineAccent: Color.lerp(tangerineAccent, other.tangerineAccent, t)!,
      lagoonTint: Color.lerp(lagoonTint, other.lagoonTint, t)!,
      lagoonWash: Color.lerp(lagoonWash, other.lagoonWash, t)!,
      lagoonAccent: Color.lerp(lagoonAccent, other.lagoonAccent, t)!,
      sunshineTint: Color.lerp(sunshineTint, other.sunshineTint, t)!,
      sunshineAccent: Color.lerp(sunshineAccent, other.sunshineAccent, t)!,
      dangerTint: Color.lerp(dangerTint, other.dangerTint, t)!,
      infoTint: Color.lerp(infoTint, other.infoTint, t)!,
      infoAccent: Color.lerp(infoAccent, other.infoAccent, t)!,
      // Both themes carry the same number of steps — the ramp is a fixed
      // scale, only its colours differ.
      heatmapRamp: [
        for (var i = 0; i < heatmapRamp.length; i++)
          Color.lerp(heatmapRamp[i], other.heatmapRamp[i], t)!,
      ],
    );
  }
}
