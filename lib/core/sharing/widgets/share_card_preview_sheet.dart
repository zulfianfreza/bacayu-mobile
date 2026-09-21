import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../di/injection.dart';
import '../../localization/build_context_extension.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/sheet_header.dart';
import '../models/session_share_data.dart';
import '../models/share_card_theme.dart';
import '../services/share_card_service.dart';
import 'session_share_card.dart';

enum _Action { share, download }

/// Lets the user see the card before it leaves the app, and pick a style by
/// swiping.
///
/// The carousel is a [PageView] rather than a two-option toggle on purpose:
/// [ShareCardTheme.presets] is a list, so a future paid style pack is "append
/// to the list" — the dots and the swipe handle any number of styles without a
/// redesign.
class ShareCardPreviewSheet extends StatefulWidget {
  const ShareCardPreviewSheet({
    super.key,
    required this.data,
    this.themes = ShareCardTheme.presets,
    this.service,
  });

  /// Marks the checkerboard-and-wash backdrop shown behind the transparent
  /// preset in the preview. It lives outside the captured boundary, so it never
  /// reaches the exported PNG.
  @visibleForTesting
  static const stickerBackdropKey = Key('sticker-checkerboard');

  final SessionShareData data;
  final List<ShareCardTheme> themes;

  /// Overridable so widget tests can count captures without touching the
  /// platform channels; production resolves it from `get_it`.
  final ShareCardService? service;

  static Future<void> show(
    BuildContext context, {
    required SessionShareData data,
    ShareCardService? service,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => ShareCardPreviewSheet(data: data, service: service),
    );
  }

  @override
  State<ShareCardPreviewSheet> createState() => _ShareCardPreviewSheetState();
}

class _ShareCardPreviewSheetState extends State<ShareCardPreviewSheet> {
  static const _viewportFraction = 0.85;

  final _pageController = PageController(viewportFraction: _viewportFraction);

  /// One key per carousel page — a single shared key would be attached to
  /// whichever page happened to build last, and the capture would rasterize
  /// the wrong card.
  late final List<GlobalKey> _cardKeys = List.generate(
    widget.themes.length,
    (_) => GlobalKey(),
  );

  /// Capture cache, valid only for the page it was taken on: tapping Share and
  /// then Download on the same style must not rasterize twice, while swiping
  /// to another style must (different widget, different boundary).
  Uint8List? _cachedBytes;
  int? _cachedPageIndex;

  int _pageIndex = 0;
  _Action? _busyAction;

  late final ShareCardService _service =
      widget.service ?? getIt<ShareCardService>();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _pageIndex = index;
      _cachedBytes = null;
      _cachedPageIndex = null;
    });
  }

  Future<Uint8List> _captureActivePage() async {
    final cached = _cachedBytes;
    if (cached != null && _cachedPageIndex == _pageIndex) return cached;

    final bytes = await _service.captureCard(_cardKeys[_pageIndex]);
    _cachedBytes = bytes;
    _cachedPageIndex = _pageIndex;
    return bytes;
  }

  /// Anchor rect for the iPad share popover — the sheet's own bounds.
  Rect? _shareOrigin() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _share() async {
    if (_busyAction != null) return;
    setState(() => _busyAction = _Action.share);

    try {
      final bytes = await _captureActivePage();
      if (!mounted) return;
      await _service.shareSessionCard(
        bytes,
        sharePositionOrigin: _shareOrigin(),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.shareFailed)));
    } finally {
      if (mounted) setState(() => _busyAction = null);
    }
  }

  Future<void> _download() async {
    if (_busyAction != null) return;
    setState(() => _busyAction = _Action.download);

    // Captured before the first await: the confirmation belongs to the screen
    // underneath, which is what the user sees once this sheet closes.
    final messenger = ScaffoldMessenger.of(context);
    final savedMessage = context.l10n.savedToGallery;

    try {
      final bytes = await _captureActivePage();
      await _service.downloadSessionCard(bytes);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(savedMessage)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busyAction = null);
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.saveImageFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // The card is the point of the sheet, so it takes the biggest slice that
    // still leaves room for the picker and the two actions on a short phone.
    final screenHeight = MediaQuery.sizeOf(context).height;
    final carouselHeight = (screenHeight * 0.45).clamp(220.0, 460.0);
    final isBusy = _busyAction != null;

    return SafeArea(
      // Scrollable rather than overflowing: a landscape phone is shorter than
      // the card's floor height plus the chrome around it.
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetHeader(title: l10n.shareSession),
              const SizedBox(height: 12),
              SizedBox(
                height: carouselHeight,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.themes.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: SessionShareCard.aspectRatio,
                          // The backdrop stands in for the user's own photo and
                          // sits OUTSIDE the boundary, so it is never captured
                          // into the exported sticker.
                          child: _PreviewBackdrop(
                            theme: widget.themes[index],
                            child: RepaintBoundary(
                              key: _cardKeys[index],
                              child: SessionShareCard(
                                data: widget.data,
                                theme: widget.themes[index],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _StyleDots(count: widget.themes.length, index: _pageIndex),
              if (widget.themes[_pageIndex].isSticker) ...[
                const SizedBox(height: 12),
                _SheetNote(text: l10n.shareStickerHint),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ChunkyButton(
                      label: l10n.share,
                      // Swaps the label for a spinner in place, so neither
                      // button moves when the other one is working.
                      isLoading: _busyAction == _Action.share,
                      onPressed: isBusy ? null : _share,
                      icon: Image.asset(
                        'assets/icons/share-stroke.png',
                        width: 18,
                        height: 18,
                        // The primary variant's foreground, which a bundled PNG
                        // can't inherit.
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChunkyButton(
                      label: l10n.download,
                      variant: ChunkyButtonVariant.secondary,
                      isLoading: _busyAction == _Action.download,
                      onPressed: isBusy ? null : _download,
                      // No bundled download glyph exists yet; the platform's own
                      // is clearer than a borrowed icon that means something
                      // else.
                      icon: const Icon(
                        Icons.download,
                        size: 18,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carousel indicator, in the app's pill language: the style on screen is a
/// wide tangerine pill, the rest are slate dots — the same marks the onboarding
/// progress uses.
class _StyleDots extends StatelessWidget {
  const _StyleDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? AppColors.tangerine500 : AppColors.slate200,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}

/// The one line of guidance a preset needs — on a soft fill rather than as a
/// bare caption, so it reads as part of the sheet's chrome instead of as
/// content the user has to parse.
class _SheetNote extends StatelessWidget {
  const _SheetNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.caption,
      ),
    );
  }
}

/// Paints the transparent preset's preview backdrop: a transparency
/// checkerboard under a full-frame dark wash.
///
/// The sticker exports as white type on clear alpha, so in the preview there is
/// nothing behind that type but the sheet. The checkerboard says the clear
/// areas are alpha and not white paint; the wash is what actually buys the
/// contrast the export will get from wherever the user pastes it.
///
/// Both are painted by a single painter on a single layer, so they can never
/// disagree about their bounds and leak a sliver of grid at the edge. The whole
/// backdrop sits outside the `RepaintBoundary`, so it is never captured — the
/// downloaded PNG stays text-only.
///
/// Square-edged, like the card itself: the export has no rounded frame, and a
/// preview that draws one would not be showing what gets shared.
class _PreviewBackdrop extends StatelessWidget {
  const _PreviewBackdrop({required this.theme, required this.child});

  final ShareCardTheme theme;
  final Widget child;

  /// Side of one checker square. Big enough to read as a pattern at preview
  /// size, small enough that it never competes with the card's own text.
  static const _cell = 14.0;

  /// Dark, but not opaque: enough for the white type, not so much that the
  /// checkerboard — the point of the preview — disappears.
  static final _wash = AppColors.ink.withValues(alpha: 0.45);

  @override
  Widget build(BuildContext context) {
    if (!theme.isSticker) return child;

    return CustomPaint(
      key: ShareCardPreviewSheet.stickerBackdropKey,
      painter: _StickerBackdropPainter(cell: _cell, wash: _wash),
      child: child,
    );
  }
}

/// The classic two-tone transparency grid with the dark wash laid over it.
/// Kept light: the wash supplies the contrast, and a dark grid under a dark
/// wash would just disappear.
class _StickerBackdropPainter extends CustomPainter {
  const _StickerBackdropPainter({required this.cell, required this.wash});

  final double cell;
  final Color wash;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    // A CustomPaint is never clipped to its own box, and the grid is drawn in
    // whole squares — so without this the last column/row would spill a few
    // pixels past the card and read as an uncovered edge.
    canvas.clipRect(bounds);

    canvas.drawRect(bounds, Paint()..color = AppColors.surface);
    final dark = Paint()..color = AppColors.slate200;
    for (var y = 0; y * cell < size.height; y++) {
      for (var x = 0; x * cell < size.width; x++) {
        if ((x + y).isEven) continue;
        canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), dark);
      }
    }

    canvas.drawRect(bounds, Paint()..color = wash);
  }

  @override
  bool shouldRepaint(covariant _StickerBackdropPainter oldDelegate) =>
      oldDelegate.cell != cell || oldDelegate.wash != wash;
}
