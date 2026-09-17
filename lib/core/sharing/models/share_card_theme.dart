import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// What sits behind the card's content.
enum ShareCardBackground {
  /// The book cover fills the card, darkened by a scrim. The activity-photo
  /// look, and the closest thing this app has to a Strava share.
  cover,

  /// Flat dark fill, for a coverless book or for users who don't want their
  /// book on the image.
  solid,

  /// Scrim only, with nothing behind it, so the user's own photo shows
  /// through the top of the exported PNG. The scrim is translucent rather
  /// than absent on purpose: white type over an unknown photo is unreadable
  /// the moment that photo is bright, and a text outline does not save it.
  scrimOnly,
}

/// Visual preset for a shareable card, deliberately kept as a plain data
/// object instead of hardcoding colors/transparency inside the card widget.
///
/// A future paid "custom style" feature can add more instances (custom font,
/// accent, watermark on/off) and the card widget + preview carousel pick them
/// up without a rewrite.
class ShareCardTheme extends Equatable {
  const ShareCardTheme({
    required this.background,
    required this.backgroundColor,
    required this.accentColor,
    required this.fontFamily,
    required this.showWatermark,
  });

  final ShareCardBackground background;

  /// Fill painted behind the content. Only used by
  /// [ShareCardBackground.solid] — the cover preset paints the book cover
  /// instead, and the transparent preset paints nothing at all.
  final Color backgroundColor;

  /// Highlights inside the card (the streak chip).
  final Color accentColor;

  /// `null` keeps the app's default face (Nunito, via `AppTypography`) —
  /// only set this once a bundled custom font actually exists.
  final String? fontFamily;

  /// The BacaYu mark is a growth loop, so every preset keeps it on.
  final bool showWatermark;

  bool get usesCover => background == ShareCardBackground.cover;

  /// Paints no fill of its own, so the exported PNG keeps alpha and can be
  /// pasted over the user's own photo.
  bool get isSticker => background == ShareCardBackground.scrimOnly;

  /// The book cover, as the card's background.
  static const photo = ShareCardTheme(
    background: ShareCardBackground.cover,
    backgroundColor: AppColors.ink,
    accentColor: AppColors.tangerine500,
    fontFamily: null,
    showWatermark: true,
  );

  /// Flat dark card, no cover image.
  static const solid = ShareCardTheme(
    background: ShareCardBackground.solid,
    backgroundColor: AppColors.ink,
    accentColor: AppColors.tangerine500,
    fontFamily: null,
    showWatermark: true,
  );

  /// Transparent sticker the user places over their own media.
  static const sticker = ShareCardTheme(
    background: ShareCardBackground.scrimOnly,
    backgroundColor: AppColors.ink,
    accentColor: AppColors.tangerine500,
    fontFamily: null,
    showWatermark: true,
  );

  /// Carousel order — append here to offer another style; the preview sheet's
  /// PageView and its page dots grow from this list automatically.
  static const presets = <ShareCardTheme>[photo, solid, sticker];

  /// Applies this preset's face to [base]. `TextStyle.copyWith` ignores a null
  /// argument, so a preset that leaves [fontFamily] unset keeps the app's own
  /// Nunito styling untouched.
  TextStyle textStyle(TextStyle base) => base.copyWith(fontFamily: fontFamily);

  @override
  List<Object?> get props => [
        background,
        backgroundColor,
        accentColor,
        fontFamily,
        showWatermark,
      ];
}
