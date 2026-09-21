import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_semantic_colors.dart';
import 'app_typography.dart';

/// Full ThemeData — colors, Nunito text theme, and the pill/rounded shapes
/// from Style Guide Section 4, in both brightnesses. All widgets must read
/// from here or from `context.colors`; no hardcoded `Color(0xFF...)` or
/// `fontSize:` in feature code.
///
/// The two themes differ only in the semantic roles they carry
/// ([AppSemanticColors]) and the surfaces those roles imply. The brand ramps
/// (tangerine, lagoon, sunshine, berry) are shared, which is why a primary
/// button keeps its tangerine in both modes.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        colors: AppSemanticColors.light,
        // The light look is deliberately flat: page, bars and sheets are all
        // the same white, and hierarchy is drawn with borders, not elevation.
        scaffoldBackground: AppColors.surface,
        textButtonForeground: AppColors.slate900,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        colors: AppSemanticColors.dark,
        // Dark splits the two: a warm near-black page under warm card
        // surfaces, so a card reads as raised without a shadow.
        scaffoldBackground: AppColors.darkBackground,
        textButtonForeground: AppColors.darkInk,
      );

  static ThemeData _build({
    required Brightness brightness,
    required AppSemanticColors colors,
    required Color scaffoldBackground,
    required Color textButtonForeground,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.tangerine,
      brightness: brightness,
      primary: AppColors.tangerine,
      onPrimary: Colors.white,
      secondary: AppColors.lagoon,
      onSecondary: Colors.white,
      error: AppColors.berry,
      surface: colors.surface,
      onSurface: colors.ink,
    );

    // Colouring the scale here is what lets every `Text` with a colourless
    // `AppTypography` style inherit the right ink for the mode.
    final textTheme =
        TextTheme(
          displayLarge: AppTypography.displayLg,
          headlineLarge: AppTypography.displaySm,
          titleLarge: AppTypography.heading,
          titleMedium: AppTypography.subheading,
          bodyLarge: AppTypography.body,
          bodyMedium: AppTypography.bodyStrong,
          bodySmall: AppTypography.caption,
          labelLarge: AppTypography.button,
        ).apply(
          bodyColor: colors.ink,
          displayColor: colors.ink,
        ).copyWith(
          labelLarge: AppTypography.button.copyWith(color: colors.ink),
          // Captions are a role, not just a size — quieter than the copy
          // around them, whichever mode.
          bodySmall: AppTypography.caption.copyWith(
            color: colors.textSecondary,
          ),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: AppTypography.body.fontFamily,
      textTheme: textTheme,
      extensions: [colors],
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colors.hairline, width: 1),
        ),
      ),
      // Sheets take the themed surface, not Material 3's `surfaceContainerLow`.
      // That default is derived from the seed colour, so with a tangerine seed
      // it comes out a soft orange — every sheet was passing `surface` by hand
      // to avoid it, and the ones that forgot went warm.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
      ),
      // Same story for the date picker: body and header both default to a
      // seeded `surfaceContainerHigh`, and both belong to the app's surfaces.
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.surface,
        headerBackgroundColor: colors.surface,
      ),
      // And the dialog, which would otherwise come out seeded too.
      dialogTheme: DialogThemeData(backgroundColor: colors.surface),
      // Uncoloured `Divider`s were falling back to the seeded outline; the
      // app's hairline is the one divider colour (Style Guide 2.2).
      dividerTheme: DividerThemeData(color: colors.hairline),
      // And once more for app bars: Material 3 keeps them `surface` at rest but
      // paints `colorScheme.surfaceTint` over the top as soon as content
      // scrolls underneath, which is the seeded tangerine — so every page
      // turned warm somewhere between the top and the bottom of its list.
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tangerine,
          foregroundColor: Colors.white,
          textStyle: AppTypography.button,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.tangerineAccent,
          textStyle: AppTypography.button,
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.tangerine500, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textButtonForeground,
          textStyle: AppTypography.button,
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: colors.hairline),
        ),
      ),
    );
  }
}
