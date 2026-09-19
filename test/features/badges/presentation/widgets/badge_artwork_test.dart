import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/badges/presentation/widgets/badge_artwork.dart';

void main() {
  /// One frame only: the image is resolved asynchronously, and in a test the
  /// network one never arrives — asserting after a second pump would inspect
  /// the errorBuilder's placeholder instead of the provider under test.
  Future<void> pumpArtwork(WidgetTester tester, BadgeArtwork artwork) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: artwork))),
    );
  }

  ImageProvider providerOf(WidgetTester tester) =>
      tester.widget<Image>(find.byType(Image)).image;

  testWidgets('falls back to the bundled placeholder with no image url', (
    tester,
  ) async {
    await pumpArtwork(tester, const BadgeArtwork(imageUrl: null));

    expect(
      providerOf(tester),
      isA<AssetImage>().having(
        (asset) => asset.assetName,
        'assetName',
        BadgeArtwork.placeholderAsset,
      ),
    );
  });

  testWidgets('an empty image url is the same as none', (tester) async {
    await pumpArtwork(tester, const BadgeArtwork(imageUrl: ''));

    expect(
      (providerOf(tester) as AssetImage).assetName,
      BadgeArtwork.placeholderAsset,
    );
  });

  testWidgets('uses the artwork the API sent when there is one', (
    tester,
  ) async {
    await pumpArtwork(
      tester,
      const BadgeArtwork(imageUrl: 'https://cdn.example.com/badges/first.png'),
    );

    // The provider is what matters here — the test HTTP client never serves the
    // bytes, and the errorBuilder is what covers that case.
    expect(
      (providerOf(tester) as NetworkImage).url,
      'https://cdn.example.com/badges/first.png',
    );
  });

  testWidgets('draws at the size it was asked for', (tester) async {
    await pumpArtwork(tester, const BadgeArtwork(imageUrl: null, size: 96));

    expect(tester.getSize(find.byType(BadgeArtwork)), const Size(96, 96));
  });
}
