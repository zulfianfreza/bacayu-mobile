import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';

/// Thin wrapper over the three platform touchpoints of the sharing flow:
/// rasterize a [RepaintBoundary], hand the PNG to the native share sheet, and
/// save it to the device gallery. Holds no state, so `ShareCardPreviewSheet`
/// can call it freely and tests can swap in a mock to count captures.
@injectable
class ShareCardService {
  const ShareCardService();

  /// 3x the logical card size, so the exported PNG stays crisp when it's
  /// scaled up by Instagram/WhatsApp.
  static const _pixelRatio = 3.0;

  static const _albumName = 'BacaYu';

  /// Rasterizes the widget behind [repaintBoundaryKey] to PNG bytes.
  ///
  /// Throws a [StateError] when the key isn't currently mounted — callers
  /// only ever capture the carousel page that's on screen.
  Future<Uint8List> captureCard(GlobalKey repaintBoundaryKey) async {
    final renderObject = repaintBoundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError('Share card is not mounted for capture');
    }

    final image = await renderObject.toImage(pixelRatio: _pixelRatio);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to encode the share card as PNG');
      }
      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  /// Opens the native share sheet with [pngBytes] attached.
  ///
  /// [sharePositionOrigin] is the on-screen rect the sheet should popover
  /// from — required on iPad, where the share sheet is a popover and
  /// `UIActivityViewController` raises without an anchor.
  Future<void> shareSessionCard(
    Uint8List pngBytes, {
    Rect? sharePositionOrigin,
  }) async {
    final file = await _writeTempFile(pngBytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Saves [pngBytes] to the device gallery, in a `BacaYu` album.
  Future<void> downloadSessionCard(Uint8List pngBytes) async {
    await Gal.requestAccess(toAlbum: true);
    await Gal.putImageBytes(pngBytes, album: _albumName);
  }

  Future<File> _writeTempFile(Uint8List bytes) async {
    final dir = await Directory.systemTemp.createTemp('bacayu_share');
    final file = File('${dir.path}/bacayu_session.png');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
