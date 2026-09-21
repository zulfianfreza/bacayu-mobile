import 'package:flutter/material.dart';

import 'app_semantic_colors.dart';
import 'app_typography.dart';

/// `context.colors.surface` instead of the raw palette token — the semantic
/// roles that flip between light and dark (see [AppSemanticColors]).
///
/// Falls back to the light roles when the theme carries no extension (a bare
/// `MaterialApp` in a widget test, a preview): widgets stay renderable outside
/// the app, and the failure mode is the old light colours rather than a crash.
extension ThemeContextExtension on BuildContext {
  AppSemanticColors get colors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;

  /// `AppTypography.caption` in the role's secondary colour — the muted caption
  /// the type scale calls for, correct in both modes.
  ///
  /// The bare `AppTypography.caption` is colourless so it can inherit the
  /// theme's body colour; this is for the (usual) case where a caption should
  /// be visibly quieter than the text around it.
  TextStyle get captionStyle =>
      AppTypography.caption.copyWith(color: colors.textSecondary);
}
