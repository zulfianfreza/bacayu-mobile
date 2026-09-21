import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Feature code must read colors through the semantic roles on
/// `context.colors` (`AppSemanticColors`), never through the raw palette in
/// `AppColors`. Only the palette's base steps (`AppColors.tangerine500`,
/// `AppColors.lagoon500`, ...) are brightness-independent and may be used
/// directly; every tint/shade/neutral below flips between light and dark, so a
/// raw use of one is a dark-mode bug waiting to ship.
///
/// `lib/core/sharing` is exempt: it renders a standalone share image that is
/// deliberately not themed (fixed light grid and dark scrim for the exported
/// PNG), not app chrome.
void main() {
  final scannedRoots = [
    Directory('lib/features'),
    Directory('lib/core/navigation'),
    Directory('lib/core/widgets'),
  ];

  // Palette tokens whose correct value depends on brightness — all of these
  // have a semantic role on `AppSemanticColors`.
  final forbidden = RegExp(
    r'AppColors\.('
    r'surface|background|ink|'
    r'slate200|slate400|slate600|'
    r'tangerine50|tangerine100|tangerine700|tangerine900|'
    r'lagoon50|lagoon100|lagoon700|'
    r'sunshine100|sunshine700|'
    r'blue100|blue700'
    r')\b',
  );

  test('feature code uses semantic color roles, not raw palette tokens', () {
    final offenders = <String>[];

    for (final root in scannedRoots) {
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trimLeft().startsWith('//')) continue; // commented-out code
          final match = forbidden.firstMatch(line);
          if (match != null) {
            offenders.add('${entity.path}:${i + 1}: ${match.group(0)}');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Found raw palette tokens in feature code. Use the matching '
          'context.colors role instead (see AppSemanticColors):\n'
          '${offenders.join('\n')}',
    );
  });
}
