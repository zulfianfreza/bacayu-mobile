import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart' hide Badge;

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../badges/domain/entities/badge.dart';
import '../../../badges/domain/usecases/get_all_badges.dart';
import '../../../badges/presentation/pages/badge_gallery_page.dart';

/// Badge collection lives on the Stats tab by design (no separate tab) —
/// shows the most recently unlocked badges; "See all" opens the full
/// gallery.
class BadgePreviewRow extends StatefulWidget {
  const BadgePreviewRow({super.key});

  @override
  State<BadgePreviewRow> createState() => _BadgePreviewRowState();
}

class _BadgePreviewRowState extends State<BadgePreviewRow> {
  late final Future<Either<Failure, List<Badge>>> _future = getIt<GetAllBadges>().call();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.yourBadges, style: AppTypography.heading),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BadgeGalleryPage()),
              ),
              child: Text(l10n.seeAll),
            ),
          ],
        ),
        SizedBox(
          height: 76,
          child: FutureBuilder<Either<Failure, List<Badge>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              return snapshot.data!.fold(
                (failure) => Center(
                  child: Text(
                    failure.localizedMessage(context),
                    style: AppTypography.caption,
                  ),
                ),
                (badges) {
                  final unlocked = badges.where((b) => b.unlocked).toList()
                    ..sort((a, b) {
                      final aAt = a.unlockedAt ?? DateTime(0);
                      final bAt = b.unlockedAt ?? DateTime(0);
                      return bAt.compareTo(aAt);
                    });
                  final preview = unlocked.take(8).toList();

                  if (preview.isEmpty) {
                    return Center(
                      child: Text(l10n.noBadgesYet, style: AppTypography.caption),
                    );
                  }

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: preview.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _BadgeMedal(badge: preview[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BadgeMedal extends StatelessWidget {
  const _BadgeMedal({required this.badge});

  final Badge badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sunshine100,
            ),
            alignment: Alignment.center,
            child: Text(badge.icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 4),
          Text(
            badge.name,
            style: AppTypography.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
