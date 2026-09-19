import 'package:flutter/material.dart';

/// A badge's artwork: the image the backend sent for it, or the bundled
/// placeholder until there is one.
///
/// Just the art — no disc behind it. This is the single place badge art is
/// resolved, so swapping the placeholder for the real set (or for `image_url`
/// on every badge) is a change here and nowhere else.
class BadgeArtwork extends StatelessWidget {
  const BadgeArtwork({super.key, required this.imageUrl, this.size = 48});

  /// The badge's `image_url` from the API. Null or empty means the backend has
  /// no artwork for it yet — every badge today, hence the placeholder.
  final String? imageUrl;

  final double size;

  /// Stand-in artwork, used until the backend carries a badge image.
  static const placeholderAsset = 'assets/images/bookworm.png';

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final hasImage = url != null && url.isNotEmpty;

    return SizedBox(
      width: size,
      height: size,
      child: hasImage
          ? Image.network(
              url,
              fit: BoxFit.contain,
              // A badge whose image 404s still has to say something.
              errorBuilder: (context, error, stackTrace) =>
                  const _Placeholder(),
            )
          : const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Image.asset(BadgeArtwork.placeholderAsset, fit: BoxFit.contain);
  }
}
