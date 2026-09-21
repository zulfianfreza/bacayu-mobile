import 'package:flutter/material.dart';

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
/// The composition is chosen by [ShareCardTheme.layout], and the backdrop by
/// [ShareCardTheme.background]. Both are independent: the same arrangement can
/// be offered over the book cover, a flat fill, or nothing at all.
class SessionShareCard extends StatelessWidget {
  const SessionShareCard({super.key, required this.data, required this.theme});

  final SessionShareData data;
  final ShareCardTheme theme;

  /// The card always lays out at this fixed logical size and is scaled to
  /// whatever box it's given, so the design can never reflow or overflow on a
  /// small screen — and every user gets an identically proportioned PNG.
  ///
  /// 360x640 is 9:16, and `ShareCardService` rasterizes at 3x — so the exported
  /// PNG lands on exactly 1080x1920, the resolution a story is authored at.
  static const designWidth = 360.0;
  static const designHeight = 640.0;

  /// Portrait 9:16 — a story, which is the surface the PRD asks this card for
  /// ("share activity card ke Instagram/WhatsApp Story"), rather than a feed
  /// post, and tall enough to leave the sticker preset somewhere to sit.
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
    // A captured card is a fixed design artifact rather than app chrome: the
    // device's font scale must not reflow it, or the PNG changes shape per user.
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: designWidth,
        height: designHeight,
        child: MediaQuery.withNoTextScaling(
          // No rounded frame: this is exported as a full-bleed story image, so
          // the corners have to be square in the PNG rather than transparent.
          child: Stack(
            fit: StackFit.expand,
            children: [
              _BackgroundLayer(
                key: backgroundKey,
                theme: theme,
                coverUrl: data.bookCoverUrl,
              ),
              switch (theme.layout) {
                ShareCardLayout.overlay => _OverlayLayout(
                  data: data,
                  theme: theme,
                ),
                ShareCardLayout.framed => _FramedLayout(
                  data: data,
                  theme: theme,
                ),
                ShareCardLayout.hero => _HeroLayout(data: data, theme: theme),
                ShareCardLayout.spread => _SpreadLayout(
                  data: data,
                  theme: theme,
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary text on the card: bright enough to read over artwork, quiet
/// enough to stay behind the title and the stat values.
const _overlaySecondary = Color(0xCCFFFFFF);

/// The session as the three numbers every layout shares, so a new arrangement
/// never has to reformat "1h 46m 7s" or the speed itself.
List<({String value, String label})> _sessionStats(
  BuildContext context,
  SessionShareData data,
) {
  final l10n = context.l10n;
  return [
    (
      value: formatSessionDurationWords(
        Duration(seconds: data.durationSeconds),
      ),
      label: l10n.shareStatTime,
    ),
    (value: data.pagesRead.toString(), label: l10n.shareStatPages),
    (
      value: l10n.speedPpmValue(data.speedPpm.toStringAsFixed(1)),
      label: l10n.shareStatSpeed,
    ),
  ];
}

/// The largest size at or below the title's own that keeps the whole title
/// inside [maxLines] at [maxWidth].
///
/// Measured rather than guessed: titles run from "Dune" to a full series
/// volume, and the card is a fixed canvas — so the type is what gives. The
/// width check also catches a single word too long to break.
///
/// There is no floor on the result. A real title settles between the display
/// size and about 20px; anything still too tall below that is not a book
/// title, and shrinking past legibility beats the alternatives — a title that
/// lies about itself, or stats pushed off the bottom of the card.
double _fittedTitleSize(
  BuildContext context,
  String title,
  TextStyle style, {
  required double maxWidth,
  required int maxLines,
}) {
  final baseSize = style.fontSize!;
  final maxHeight = baseSize * style.height! * maxLines;

  // A guard against a non-terminating loop, not a design decision.
  const loopGuard = 2.0;

  for (var size = baseSize; size > loopGuard; size -= 0.5) {
    final painter = TextPainter(
      text: TextSpan(
        text: title,
        style: style.copyWith(fontSize: size),
      ),
      textDirection: Directionality.of(context),
    )..layout(maxWidth: maxWidth);

    final fits = painter.height <= maxHeight && painter.width <= maxWidth;
    painter.dispose();

    if (fits) return size;
  }

  return loopGuard;
}

/// Styles [base] for life on top of the card.
///
/// Every preset ends up white-on-dark underneath, so this only applies the
/// preset's face and color — the scrim is what buys the contrast.
TextStyle _overlayTextStyle(ShareCardTheme theme, TextStyle base, Color color) {
  return theme.textStyle(base).copyWith(color: color);
}

/// Photo-first composition: every text element sits white in the lower third,
/// over a scrim-darkened backdrop.
///
/// The transparent preset has no backdrop at all, so this exports as the white
/// type alone on clear alpha. The contrast then comes from whatever media the
/// user places it over, not from the card.
class _OverlayLayout extends StatelessWidget {
  const _OverlayLayout({required this.data, required this.theme});

  final SessionShareData data;
  final ShareCardTheme theme;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titleStyle = _overlayTextStyle(
      theme,
      AppTypography.displaySm,
      Colors.white,
    );
    final titleSize = _fittedTitleSize(
      context,
      data.bookTitle,
      titleStyle,
      maxWidth: SessionShareCard._contentWidth,
      maxLines: SessionShareCard._maxTitleLines,
    );

    return Padding(
      padding: const EdgeInsets.all(SessionShareCard._padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // At 9:16 the slack above the text block is most of the card, so
          // it is split rather than dropped in one place: 6 above the
          // block to 1 below it. That keeps the block in the lower third —
          // where a story puts its subject — without letting it touch the
          // bottom edge, which is where the platform's own reply bar sits.
          const Spacer(flex: 6),
          if (theme.showWatermark) ...[
            // The brand opens the block instead of sitting in the top
            // corner: the top of the frame is what a story's own chrome
            // and the user's photo already compete for.
            _Watermark(theme: theme),
            const SizedBox(height: 10),
          ],
          Text(
            data.bookTitle,
            // Never truncated: a half-finished book title is worse than
            // a smaller one, and the card has no page to continue on.
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
          _Stats(theme: theme, stats: _sessionStats(context, data)),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Full-height composition: title and stats centered down the middle, the
/// brand pinned to the foot.
///
/// Used by the transparent preset. Without a backdrop, the lower-third
/// [_OverlayLayout] leaves the top two thirds empty and the exported PNG reads
/// as a caption floating on nothing; a centered, full-height block uses the
/// whole frame. The stats stack one per row rather than across, which keeps
/// their values large instead of squeezed into a third of the width.
class _SpreadLayout extends StatelessWidget {
  const _SpreadLayout({required this.data, required this.theme});

  final SessionShareData data;
  final ShareCardTheme theme;

  static const _padding = 28.0;

  /// With the whole card to itself the title can run to three lines before it
  /// has to shrink.
  static const _maxTitleLines = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titleStyle = _overlayTextStyle(
      theme,
      AppTypography.displayLg,
      Colors.white,
    );
    final titleSize = _fittedTitleSize(
      context,
      data.bookTitle,
      titleStyle,
      maxWidth: SessionShareCard.designWidth - _padding * 2,
      maxLines: _maxTitleLines,
    );

    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            data.bookTitle,
            textAlign: TextAlign.center,
            style: titleStyle.copyWith(fontSize: titleSize),
          ),
          if (data.bookAuthors.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              l10n.byAuthor(data.bookAuthors.join(', ')),
              textAlign: TextAlign.center,
              style: _overlayTextStyle(
                theme,
                AppTypography.caption,
                _overlaySecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 32),
          _VerticalStats(theme: theme, stats: _sessionStats(context, data)),
          if (theme.showWatermark) ...[
            const SizedBox(height: 24),
            Center(child: _Watermark(theme: theme)),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}

/// Book-plate composition: the cover art in a framed panel, with the title,
/// author and stats stacked on the flat fill beneath it.
///
/// Unlike [_OverlayLayout] it asks the cover to be seen rather than to set the
/// mood, so the art survives even over a `solid` background.
class _FramedLayout extends StatelessWidget {
  const _FramedLayout({required this.data, required this.theme});

  final SessionShareData data;
  final ShareCardTheme theme;

  static const _padding = 28.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titleStyle = _overlayTextStyle(
      theme,
      AppTypography.displaySm,
      Colors.white,
    );
    final titleSize = _fittedTitleSize(
      context,
      data.bookTitle,
      titleStyle,
      maxWidth: SessionShareCard.designWidth - _padding * 2,
      maxLines: 2,
    );

    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: _CoverArt(coverUrl: data.bookCoverUrl),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.bookTitle,
            textAlign: TextAlign.center,
            style: titleStyle.copyWith(fontSize: titleSize),
          ),
          if (data.bookAuthors.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l10n.byAuthor(data.bookAuthors.join(', ')),
              textAlign: TextAlign.center,
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
          _Stats(theme: theme, stats: _sessionStats(context, data)),
          if (theme.showWatermark) ...[
            const SizedBox(height: 14),
            Center(child: _Watermark(theme: theme)),
          ],
        ],
      ),
    );
  }
}

/// Number-first composition: the session's duration leads as a display figure,
/// the title (with author) explains it, and pages/speed close the card.
class _HeroLayout extends StatelessWidget {
  const _HeroLayout({required this.data, required this.theme});

  final SessionShareData data;
  final ShareCardTheme theme;

  static const _padding = 28.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titleStyle = _overlayTextStyle(
      theme,
      AppTypography.displaySm,
      Colors.white,
    );
    final titleSize = _fittedTitleSize(
      context,
      data.bookTitle,
      titleStyle,
      maxWidth: SessionShareCard.designWidth - _padding * 2,
      maxLines: 2,
    );
    final duration = formatSessionDurationWords(
      Duration(seconds: data.durationSeconds),
    );
    // The duration is the hero, so the two stats underneath are the rest.
    final stats = _sessionStats(context, data).sublist(1);

    return Stack(
      fit: StackFit.expand,
      children: [
        // The hero card is deliberately off the book-cover backdrop: a giant
        // number needs a calm field, so it wears the brand's own gradient.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.tangerine700, AppColors.ink],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(_padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (theme.showWatermark) _Watermark(theme: theme),
              const Spacer(flex: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  duration,
                  style: _overlayTextStyle(
                    theme,
                    AppTypography.displayLg.copyWith(fontSize: 64),
                    Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  l10n.shareStatTime.toUpperCase(),
                  style: _overlayTextStyle(
                    theme,
                    AppTypography.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                    _overlaySecondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                data.bookTitle,
                textAlign: TextAlign.center,
                style: titleStyle.copyWith(fontSize: titleSize),
              ),
              if (data.bookAuthors.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.byAuthor(data.bookAuthors.join(', ')),
                  textAlign: TextAlign.center,
                  style: _overlayTextStyle(
                    theme,
                    AppTypography.caption,
                    _overlaySecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              _Stats(theme: theme, stats: stats),
            ],
          ),
        ),
      ],
    );
  }
}

/// What gets painted behind the content: the book cover, a flat fill, or
/// nothing at all.
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
      // Truly nothing: the exported PNG keeps its alpha, and the transparent
      // preset's text block supplies its own dark backing instead.
      ShareCardBackground.scrimOnly => const SizedBox.shrink(),
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
    return Stack(
      fit: StackFit.expand,
      children: [
        _CoverArt(coverUrl: coverUrl, radius: 0),
        const _Scrim(),
      ],
    );
  }
}

/// The book cover itself, with the brand fallback for a coverless book.
///
/// Shared by the full-bleed backdrop and the framed plate so both fail over the
/// same way. A rounded [radius] turns it into the framed plate; zero keeps it
/// square for the full-bleed backdrop, which adds the text scrim on top.
class _CoverArt extends StatelessWidget {
  const _CoverArt({required this.coverUrl, this.radius = AppRadius.md});

  final String? coverUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = coverUrl;

    final art = url == null
        ? const _CoverFallback()
        : Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const _CoverFallback(),
          );

    if (radius <= 0) return art;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: _overlaySecondary.withValues(alpha: 0.25),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: art,
      ),
    );
  }
}

/// The darkening layer that makes white type work over arbitrary artwork.
///
/// Three zones: a light wash behind the date and the mark, a clear window
/// where the cover actually shows, then a heavy base under the title and
/// stats. The ramp has to finish before the title starts — white type on a
/// half-lit cover is what makes these cards unreadable.
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

/// One reading session as numbers, separated by hairlines the way an
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scaled down rather than ellipsized: the time value runs to
                // "1h 46m 7s" inside a third of the card, and a stat that reads
                // as a half-said number is worse than a slightly smaller one.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stats[i].value,
                    // A notch under the `heading` token: the widest value is
                    // "0.8 ppm", and at 20px it ellipsized to "0.8 pp…" inside
                    // a third of a 320px card. At 18px the row carries the
                    // common values at their own size, and only the long time
                    // values get scaled above.
                    style: _overlayTextStyle(
                      theme,
                      AppTypography.heading.copyWith(fontSize: 18),
                      Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stats[i].label.toUpperCase(),
                    style: _overlayTextStyle(
                      theme,
                      AppTypography.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                      // The same white as the value above it: the label names
                      // the number, it doesn't whisper under it.
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// The same three numbers as [_Stats], but stacked one per row and centered.
///
/// A vertical stack gives each value the full card width, so the figures can be
/// large instead of squeezed into a third — which is what the transparent
/// preset wants, since it has no other content to fill the frame.
class _VerticalStats extends StatelessWidget {
  const _VerticalStats({required this.theme, required this.stats});

  final ShareCardTheme theme;
  final List<({String value, String label})> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stats[i].value,
              textAlign: TextAlign.center,
              style: _overlayTextStyle(
                theme,
                AppTypography.heading.copyWith(fontSize: 26),
                Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stats[i].label.toUpperCase(),
              textAlign: TextAlign.center,
              style: _overlayTextStyle(
                theme,
                AppTypography.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
                _overlaySecondary,
              ),
            ),
          ),
        ],
      ],
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
