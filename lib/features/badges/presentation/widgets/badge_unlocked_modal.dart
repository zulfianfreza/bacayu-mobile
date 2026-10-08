import 'package:flutter/material.dart' hide Badge;

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import 'badge_artwork.dart';
import '../../../../core/theme/build_context_extension.dart';

/// Reusable celebratory modal — called from more than one place (CLAUDE.md
/// Section 6): `sessions`' summary page when a submit response carries
/// `badges_unlocked`, AND `notifications`' push handler when the app is
/// opened from a `bacayu.badge.unlocked` notification while backgrounded.
/// Deliberately takes plain strings rather than the `Badge` domain entity
/// or `sessions`' `UnlockedBadge` — both callers have different payload
/// shapes (sessions' fast-path response never carries `image_url`/
/// `unlocked_at`), and this widget shouldn't depend on either feature.
class BadgeUnlockedModal extends StatefulWidget {
  const BadgeUnlockedModal({
    super.key,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  final String name;
  final String description;

  /// The badge's artwork, when the caller has one.
  ///
  /// The unlock paths that reach here (the session submit's fast-path response,
  /// or a push) don't carry `image_url` yet, so this is normally null and
  /// [BadgeArtwork]'s placeholder stands in.
  final String? imageUrl;

  /// Shows the celebration over [context].
  static Future<void> show(
    BuildContext context, {
    required String name,
    required String description,
    String? imageUrl,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, _, _) => BadgeUnlockedModal(
        name: name,
        description: description,
        imageUrl: imageUrl,
      ),
      transitionBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  State<BadgeUnlockedModal> createState() => _BadgeUnlockedModalState();
}

class _BadgeUnlockedModalState extends State<BadgeUnlockedModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _scale = Tween(begin: 0.7, end: 1.0).animate(
    CurvedAnimation(
      parent: _controller,
      // Pop-in with a slight overshoot, per Style Guide Section 6.4/7.
      curve: Curves.easeOutBack,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.sunshineTint,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _scale,
                          child: BadgeArtwork(
                            imageUrl: widget.imageUrl,
                            size: 200,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.newBadge,
                          style: AppTypography.caption.copyWith(
                            color: context.colors.sunshineAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.name,
                          style: AppTypography.heading,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.awesome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
