import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/badge.dart';
import '../cubit/badge_cubit.dart';
import '../cubit/badge_state.dart';

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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.badgeGalleryTitle)),
      body: BlocBuilder<BadgeCubit, BadgeState>(
        builder: (context, state) {
          return switch (state) {
            BadgeInitial() || BadgeLoading() =>
              const Center(child: CircularProgressIndicator()),
            BadgeError(:final failure) => Center(
                child: Text(
                  failure.localizedMessage(context),
                  style: AppTypography.body,
                ),
              ),
            BadgeLoaded(:final badges) => GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) => _BadgeMedal(badge: badges[index]),
              ),
          };
        },
      ),
    );
  }
}

class _BadgeMedal extends StatelessWidget {
  const _BadgeMedal({required this.badge});

  final Badge badge;

  @override
  Widget build(BuildContext context) {
    final medal = Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.sunshine100,
      ),
      alignment: Alignment.center,
      child: Text(badge.icon, style: const TextStyle(fontSize: 28)),
    );

    return Column(
      children: [
        // Style Guide Section 6.4: locked badges render grayscale.
        badge.unlocked
            ? medal
            : ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: Opacity(opacity: 0.5, child: medal),
              ),
        const SizedBox(height: 6),
        Text(
          badge.name,
          style: AppTypography.caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
