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

  /// Nothing at all, so the exported PNG is fully transparent and only the
  /// card's white type survives. The contrast then depends on the media the
  /// user drops it onto, not on anything this preset paints.
  scrimOnly,
}

/// How the card's content is composed on the fixed canvas, independent of what
/// sits behind it. Two presets can share a backdrop and still be different
/// styles because they arrange the title, cover and stats differently.
enum ShareCardLayout {
  /// Photo-first: the backdrop fills the frame and the text block sits in the
  /// lower third. The activity-photo look, and the original composition.
  overlay,

  /// The cover as a framed plate up top, with title and stats stacked beneath
  /// it. Reads like a book plate rather than a photo.
  framed,

  /// The duration as one hero number, title below and secondary stats at the
  /// foot. Number-first, the way a streak card leads with the count.
  hero,

  /// The text block spread down the whole card: brand at the top, title in the
  /// middle, stats at the foot. The transparent preset has no backdrop to
  /// anchor the lower-third [overlay], so it would otherwise export with a
  /// large empty top.
  spread,
}

/// Visual preset for a shareable card, deliberately kept as a plain data
/// object instead of hardcoding colors/transparency inside the card widget.
///
/// A future paid "custom style" feature can add more instances (custom font,
/// watermark on/off) and the card widget + preview carousel pick them up
/// without a rewrite.
class ShareCardTheme extends Equatable {
  const ShareCardTheme({
    required this.layout,
    required this.background,
    required this.backgroundColor,
    required this.fontFamily,
    required this.showWatermark,
  });

  /// The content composition. See [ShareCardLayout].
  final ShareCardLayout layout;

  final ShareCardBackground background;

  /// Fill painted behind the content. Only used by
  /// [ShareCardBackground.solid] — the cover preset paints the book cover
  /// instead, and the transparent preset paints nothing at all.
  final Color backgroundColor;

  /// `null` keeps the app's default face (Nunito, via `AppTypography`) —
  /// only set this once a bundled custom font actually exists.
  final String? fontFamily;

  /// The BacaYu mark is a growth loop, so every preset keeps it on.
  final bool showWatermark;

  bool get usesCover => background == ShareCardBackground.cover;

  /// Paints nothing behind the content, so the exported PNG is text on clear
  /// alpha that the user can drop over their own media.
  bool get isSticker => background == ShareCardBackground.scrimOnly;

  /// The book cover, as the card's background.
  static const photo = ShareCardTheme(
    layout: ShareCardLayout.overlay,
    background: ShareCardBackground.cover,
    backgroundColor: AppColors.ink,
    fontFamily: null,
    showWatermark: true,
  );

  /// Flat dark card, no cover image.
  static const solid = ShareCardTheme(
    layout: ShareCardLayout.overlay,
    background: ShareCardBackground.solid,
    backgroundColor: AppColors.ink,
    fontFamily: null,
    showWatermark: true,
  );

  /// Transparent sticker the user places over their own media.
  static const sticker = ShareCardTheme(
    layout: ShareCardLayout.spread,
    background: ShareCardBackground.scrimOnly,
    backgroundColor: AppColors.ink,
    fontFamily: null,
    showWatermark: true,
  );

  /// The cover in a plate above the text, rather than filling the frame.
  static const plate = ShareCardTheme(
    layout: ShareCardLayout.framed,
    background: ShareCardBackground.solid,
    backgroundColor: AppColors.ink,
    fontFamily: null,
    showWatermark: true,
  );

  /// The session's duration blown up as the one hero number.
  static const hero = ShareCardTheme(
    layout: ShareCardLayout.hero,
    background: ShareCardBackground.solid,
    backgroundColor: AppColors.ink,
    fontFamily: null,
    showWatermark: true,
  );

  /// Carousel order — append here to offer another style; the preview sheet's
  /// PageView and its page dots grow from this list automatically.
  static const presets = <ShareCardTheme>[photo, solid, sticker, plate, hero];

  /// Applies this preset's face to [base]. `TextStyle.copyWith` ignores a null
  /// argument, so a preset that leaves [fontFamily] unset keeps the app's own
  /// Nunito styling untouched.
  TextStyle textStyle(TextStyle base) => base.copyWith(fontFamily: fontFamily);

  @override
  List<Object?> get props => [
    layout,
    background,
    backgroundColor,
    fontFamily,
    showWatermark,
  ];
}
