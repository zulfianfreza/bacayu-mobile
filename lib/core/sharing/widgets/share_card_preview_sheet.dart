import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../di/injection.dart';
import '../../localization/build_context_extension.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
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
  late final List<GlobalKey> _cardKeys =
      List.generate(widget.themes.length, (_) => GlobalKey());

  /// Capture cache, valid only for the page it was taken on: tapping Share and
  /// then Download on the same style must not rasterize twice, while swiping
  /// to another style must (different widget, different boundary).
  Uint8List? _cachedBytes;
  int? _cachedPageIndex;

  int _pageIndex = 0;
  _Action? _busyAction;

  late final ShareCardService _service = widget.service ?? getIt<ShareCardService>();

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
      await _service.shareSessionCard(bytes, sharePositionOrigin: _shareOrigin());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.shareFailed)),
      );
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
    final carouselHeight =
        (MediaQuery.sizeOf(context).height * 0.5).clamp(280.0, 520.0);
    final isBusy = _busyAction != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.shareSession, style: AppTypography.heading),
            const SizedBox(height: 16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.themes.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _pageIndex ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _pageIndex
                          ? AppColors.tangerine500
                          : AppColors.line,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
              ],
            ),
            if (widget.themes[_pageIndex].isSticker) ...[
              const SizedBox(height: 12),
              Text(
                l10n.shareStickerHint,
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : _share,
                    icon: _busyAction == _Action.share
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.ios_share, size: 18),
                    label: Text(l10n.share),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : _download,
                    icon: _busyAction == _Action.download
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download, size: 18),
                    label: Text(l10n.download),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints a stand-in photo behind the sticker preset.
///
/// The sticker's scrim is translucent and its top is nearly clear, so a
/// preview on the sheet's own flat surface would misrepresent it — the whole
/// point is how it sits on media. This stands in for that media.
class _PreviewBackdrop extends StatelessWidget {
  const _PreviewBackdrop({required this.theme, required this.child});

  final ShareCardTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!theme.isSticker) return child;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9AAEC4), Color(0xFFE7D3B8)],
          ),
        ),
        child: child,
      ),
    );
  }
}
