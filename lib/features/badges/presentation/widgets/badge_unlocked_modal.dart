import 'package:flutter/material.dart' hide Badge;

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import 'badge_artwork.dart';

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

  /// Shows the modal as a dialog over [context].
  static Future<void> show(
    BuildContext context, {
    required String name,
    required String description,
    String? imageUrl,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => BadgeUnlockedModal(
        name: name,
        description: description,
        imageUrl: imageUrl,
      ),
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
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    // Pop-in with a slight overshoot, per Style Guide Section 6.4/7.
    curve: Curves.easeOutBack,
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

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.sunshine100,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BadgeArtwork(imageUrl: widget.imageUrl, size: 96),
              const SizedBox(height: 12),
              Text(
                l10n.newBadge,
                style: AppTypography.caption.copyWith(color: AppColors.sunshine700),
              ),
              const SizedBox(height: 4),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.awesome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
