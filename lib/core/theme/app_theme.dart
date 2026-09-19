import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Full ThemeData — colors, Nunito text theme, and the pill/rounded shapes
/// from Style Guide Section 4. All widgets must read from here; no
/// hardcoded `Color(0xFF...)` or `fontSize:` in feature code.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.tangerine,
      brightness: Brightness.light,
      primary: AppColors.tangerine,
      onPrimary: Colors.white,
      secondary: AppColors.lagoon,
      onSecondary: Colors.white,
      error: AppColors.berry,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: AppTypography.body.fontFamily,
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLg,
        headlineLarge: AppTypography.displaySm,
        titleLarge: AppTypography.heading,
        titleMedium: AppTypography.subheading,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.bodyStrong,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.button,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.slate200, width: 1),
        ),
      ),
      // Sheets are white, not Material 3's `surfaceContainerLow`. That default
      // is derived from the seed colour, so with a tangerine seed it comes out
      // a soft orange — every sheet was passing `surface` by hand to avoid it,
      // and the ones that forgot went warm.
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
      ),
      // Same story for the date picker: body and header both default to a
      // seeded `surfaceContainerHigh`, and both belong to the app's white
      // surfaces.
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: AppColors.surface,
        headerBackgroundColor: AppColors.surface,
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
          foregroundColor: AppColors.tangerine700,
          textStyle: AppTypography.button,
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.tangerine500, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.slate900,
          textStyle: AppTypography.button,
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
      ),
    );
  }
}
