import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../localization/build_context_extension.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../utils/duration_formatter.dart';
import '../models/session_share_data.dart';
import '../models/share_card_theme.dart';

/// The image users actually post: one reading session as a standalone card.
///
/// Rendered inside a `RepaintBoundary` by `ShareCardPreviewSheet` and
/// rasterized by `ShareCardService` — so it owns its full visual treatment and
/// reads nothing from the ambient theme except typography/radius tokens.
///
/// The composition is photo-first: the book cover fills the frame, a scrim
/// darkens it, and every text element sits white on top. That's the shape
/// people already know from activity-sharing apps, and it survives any cover
/// art rather than only the light ones.
class SessionShareCard extends StatelessWidget {
  const SessionShareCard({
    super.key,
    required this.data,
    required this.theme,
  });

  final SessionShareData data;
  final ShareCardTheme theme;

  /// The card always lays out at this fixed logical size and is scaled to
  /// whatever box it's given, so the design can never reflow or overflow on a
  /// small screen — and every user gets an identically proportioned PNG.
  static const designWidth = 320.0;
  static const designHeight = 400.0;

  /// Portrait 4:5 — the tallest ratio an Instagram feed post accepts, and a
  /// comfortable size for the sticker preset on a story.
  static const aspectRatio = designWidth / designHeight;

  static const _padding = 20.0;

  /// Width available to a full-bleed line of type.
  static const _contentWidth = designWidth - _padding * 2;

  /// A title may run this tall before its type starts stepping down — three
  /// lines at the display size. Past that it would swallow the card.
  static const _maxTitleLines = 3;

  /// Marks the layer that decides what the exported PNG has behind the text.
  @visibleForTesting
  static const backgroundKey = Key('share-card-background');

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: designWidth,
        height: designHeight,
        child: _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final l10n = context.l10n;
    final streakDays = data.streakDays;
    final dateLabel = DateFormat.yMMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(data.sessionDate);
    final titleStyle = _overlayTextStyle(
      theme,
      AppTypography.displaySm,
      Colors.white,
    );
    final titleSize = _fittedTitleSize(context, data.bookTitle, titleStyle);

    // A captured card is a fixed design artifact rather than app chrome: the
    // device's font scale must not reflow it, or the PNG changes shape per user.
    return MediaQuery.withNoTextScaling(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _BackgroundLayer(
              key: backgroundKey,
              theme: theme,
              coverUrl: data.bookCoverUrl,
            ),
            Padding(
              padding: const EdgeInsets.all(_padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expanded rather than a Flexible next to a Spacer: two
                      // flex children split the row evenly, which clipped the
                      // date to "March 14, 2…".
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _DateChip(theme: theme, label: dateLabel),
                        ),
                      ),
                      if (theme.showWatermark) _Watermark(theme: theme),
                    ],
                  ),
                  const Spacer(),
                  if (streakDays != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _StreakChip(theme: theme, streakDays: streakDays),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    data.bookTitle,
                    // Never truncated: a half-finished book title is worse
                    // than a smaller one, and the card has no page to
                    // continue on.
                    style: titleStyle.copyWith(fontSize: titleSize),
                  ),
                  if (data.bookAuthors.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.byAuthor(data.bookAuthors.join(', ')),
                      style: _overlayTextStyle(
                        theme,
                        AppTypography.caption,
                        _overlaySecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _Stats(
                    theme: theme,
                    stats: [
                      (
                        value: formatSessionDuration(
                          Duration(seconds: data.durationSeconds),
                        ),
                        label: l10n.shareStatTime,
                      ),
                      (
                        value: data.pagesRead.toString(),
                        label: l10n.shareStatPages,
                      ),
                      (
                        value: l10n.speedPpmValue(
                          data.speedPpm.toStringAsFixed(1),
                        ),
                        label: l10n.shareStatSpeed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Secondary text on the card: bright enough to read over artwork, quiet
/// enough to stay behind the title and the stat values.
const _overlaySecondary = Color(0xCCFFFFFF);

/// The largest size at or below the title's own that keeps the whole title
/// inside [`_maxTitleLines`] at the card's width.
///
/// Measured rather than guessed: titles run from "Dune" to a full series
/// volume, and the card is a fixed canvas — so the type is what gives. The
/// width check also catches a single word too long to break.
///
/// There is no floor on the result. A real title settles between the display
/// size and about 20px; anything still too tall below that is not a book
/// title, and shrinking past legibility beats the alternatives — a title that
/// lies about itself, or stats pushed off the bottom of the card.
double _fittedTitleSize(BuildContext context, String title, TextStyle style) {
  final baseSize = style.fontSize!;
  final maxHeight =
      baseSize * style.height! * SessionShareCard._maxTitleLines;

  // A guard against a non-terminating loop, not a design decision.
  const loopGuard = 2.0;

  for (var size = baseSize; size > loopGuard; size -= 0.5) {
    final painter = TextPainter(
      text: TextSpan(text: title, style: style.copyWith(fontSize: size)),
      textDirection: Directionality.of(context),
    )..layout(maxWidth: SessionShareCard._contentWidth);

    final fits = painter.height <= maxHeight &&
        painter.width <= SessionShareCard._contentWidth;
    painter.dispose();

    if (fits) return size;
  }

  return loopGuard;
}

/// Styles [base] for life on top of the card.
///
/// Every preset ends up white-on-dark underneath, so this only applies the
/// preset's face and color — the scrim is what buys the contrast.
TextStyle _overlayTextStyle(
  ShareCardTheme theme,
  TextStyle base,
  Color color,
) {
  return theme.textStyle(base).copyWith(color: color);
}

/// What gets painted behind the content: the book cover, a flat fill, or the
/// scrim alone.
class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer({
    super.key,
    required this.theme,
    required this.coverUrl,
  });

  final ShareCardTheme theme;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return switch (theme.background) {
      ShareCardBackground.scrimOnly => const _Scrim(),
      ShareCardBackground.solid => ColoredBox(color: theme.backgroundColor),
      ShareCardBackground.cover => _CoverBackground(coverUrl: coverUrl),
    };
  }
}

class _CoverBackground extends StatelessWidget {
  const _CoverBackground({required this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final url = coverUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (url == null)
          const _CoverFallback()
        else
          Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const _CoverFallback(),
          ),
        const _Scrim(),
      ],
    );
  }
}

/// The darkening layer that makes white type work over arbitrary artwork.
///
/// Three zones: a light wash behind the date and the mark, a clear window
/// where the cover actually shows, then a heavy base under the title and
/// stats. The ramp has to finish before the title starts — white type on a
/// half-lit cover is what makes these cards unreadable.
///
/// Translucent, never opaque: pasted over the user's own photo, the top of
/// the sticker still lets that photo through.
class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.ink.withValues(alpha: 0.45),
            AppColors.ink.withValues(alpha: 0.08),
            AppColors.ink.withValues(alpha: 0.92),
          ],
          stops: const [0, 0.32, 0.62],
        ),
      ),
    );
  }
}

/// Warm brand gradient for a book with no cover art, so the card still reads
/// as a designed image instead of a gray box.
class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.tangerine700, AppColors.ink],
        ),
      ),
    );
  }
}

/// One reading session as three numbers, separated by hairlines the way an
/// activity card separates distance, pace, and time.
class _Stats extends StatelessWidget {
  const _Stats({required this.theme, required this.stats});

  final ShareCardTheme theme;
  final List<({String value, String label})> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const _StatDivider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats[i].value,
                  // A notch under the `heading` token: the widest value is
                  // "0.8 ppm", and at 20px it ellipsized to "0.8 pp…" inside a
                  // third of a 320px card.
                  style: _overlayTextStyle(
                    theme,
                    AppTypography.heading.copyWith(fontSize: 18),
                    Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  stats[i].label.toUpperCase(),
                  style: _overlayTextStyle(
                    theme,
                    AppTypography.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                    _overlaySecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withValues(alpha: 0.24),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.theme, required this.label});

  final ShareCardTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // The date is the one small run of type that doesn't sit above the
        // heavy base of the scrim, so it carries its own backdrop rather than
        // asking the whole top of the cover to be dark.
        color: AppColors.ink.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: _overlayTextStyle(
          theme,
          AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
          Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.theme, required this.streakDays});

  final ShareCardTheme theme;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.accentColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        context.l10n.streakDaysChip(streakDays),
        // Ink, not white: tangerine is light enough that white type on it
        // never clears 4.5:1, and this is a 15px label.
        style: theme.textStyle(
          AppTypography.bodyStrong.copyWith(color: AppColors.ink),
        ),
      ),
    );
  }
}

class _Watermark extends StatelessWidget {
  const _Watermark({required this.theme});

  final ShareCardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.menu_book, size: 14, color: _overlaySecondary),
        const SizedBox(width: 4),
        Text(
          context.l10n.appName,
          style: _overlayTextStyle(
            theme,
            AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
            _overlaySecondary,
          ),
        ),
      ],
    );
  }
}
