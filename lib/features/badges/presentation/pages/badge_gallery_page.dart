import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../domain/entities/badge.dart';
import '../cubit/badge_cubit.dart';
import '../cubit/badge_state.dart';
import '../widgets/badge_artwork.dart';

class BadgeGalleryPage extends StatelessWidget {
  const BadgeGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BadgeCubit>()..load(),
      child: const _BadgeGalleryView(),
    );
  }
}

class _BadgeGalleryView extends StatelessWidget {
  const _BadgeGalleryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.badgeGalleryTitle)),
      body: SafeArea(
        child: BlocBuilder<BadgeCubit, BadgeState>(
          builder: (context, state) => switch (state) {
            BadgeInitial() || BadgeLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            BadgeError(:final failure) => _GalleryMessage(
              icon: Icons.cloud_off,
              text: failure.localizedMessage(context),
            ),
            BadgeLoaded(:final badges) => badges.isEmpty
                ? _GalleryMessage(
                    icon: Icons.workspace_premium_outlined,
                    text: context.l10n.noBadgesYet,
                  )
                : _Gallery(badges: badges),
          },
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.badges});

  final List<Badge> badges;

  /// Two per row, laid out as rows rather than a `GridView`: a badge name is
  /// allowed to run to its full length, so cells differ in height and a grid
  /// delegate would either clip them or force the tallest height on every row.
  static const _columns = 2;

  @override
  Widget build(BuildContext context) {
    final unlocked = badges.where((badge) => badge.unlocked).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CollectionProgress(unlocked: unlocked, total: badges.length),
        const SizedBox(height: 20),
        for (var start = 0; start < badges.length; start += _columns)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _columns; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: start + i < badges.length
                          ? _BadgeCard(badge: badges[start + i])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// How much of the set is unlocked — the reason to scroll through it.
class _CollectionProgress extends StatelessWidget {
  const _CollectionProgress({required this.unlocked, required this.total});

  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    return BorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.badgesCollected(unlocked, total),
            style: AppTypography.subheading,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              // Lagoon, the palette's "positive progress" colour — same as a
              // shelf book's progress bar.
              value: total == 0 ? 0 : unlocked / total,
              minHeight: 8,
              backgroundColor: AppColors.slate200,
              color: AppColors.lagoon500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final Badge badge;

  /// Style Guide Section 6.4: a locked badge is the same artwork, desaturated
  /// and dimmed, rather than a different picture.
  static const _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final artwork = BadgeArtwork(imageUrl: badge.imageUrl, size: 72);
    final stateColor = badge.unlocked
        ? AppColors.lagoon700
        : AppColors.slate600;

    return BorderedCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          badge.unlocked
              ? artwork
              : ColorFiltered(
                  colorFilter: _grayscale,
                  child: Opacity(opacity: 0.45, child: artwork),
                ),
          const SizedBox(height: 10),
          // Uncapped, like every other name in the app: it wraps rather than
          // being cut.
          Text(
            badge.name,
            style: AppTypography.subheading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // The state is said out loud, not carried by the greying alone.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                badge.unlocked
                    ? Icons.check_circle_outline
                    : Icons.lock_outline,
                size: 14,
                color: stateColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  badge.unlocked ? l10n.badgeUnlocked : l10n.badgeLocked,
                  style: AppTypography.caption.copyWith(color: stateColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Nothing to show, or the set failed to load — the same quiet illustration in
/// both cases, so an empty gallery never reads as a broken one.
class _GalleryMessage extends StatelessWidget {
  const _GalleryMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.tangerine300),
            const SizedBox(height: 12),
            Text(text, style: AppTypography.body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
