import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../feed/domain/entities/activity.dart';
import '../../../feed/presentation/pages/feed_page.dart';
import '../../../feed/presentation/widgets/badge_activity_card.dart';
import '../../../feed/presentation/widgets/session_activity_card.dart';
import '../../../sessions/presentation/widgets/book_picker_bottom_sheet.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../../../shelf/presentation/widgets/shelf_book_card.dart';
import '../../../stats/domain/entities/daily_stat.dart';
import '../../../stats/presentation/widgets/heatmap_calendar.dart' show heatmapColorFor;
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _openBookPicker(BuildContext context) async {
    await showModalBottomSheet<UserBook>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const BookPickerBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeInitial() || HomeLoading() =>
                const Center(child: CircularProgressIndicator()),
              HomeError(:final failure) => Center(
                  child: Text(
                    failure.localizedMessage(context),
                    style: AppTypography.body,
                  ),
                ),
              HomeLoaded() => RefreshIndicator(
                  onRefresh: () => context.read<HomeCubit>().load(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _Header(userName: state.userName, avatarUrl: state.avatarUrl),
                      const SizedBox(height: 20),
                      _StreakHeroCard(currentStreak: state.currentStreak),
                      const SizedBox(height: 20),
                      _HeatmapStrip(last7Days: state.last7Days),
                      const SizedBox(height: 24),
                      if (state.isEmptyState)
                        _EmptyStateCta(onTap: () => _openBookPicker(context))
                      else ...[
                        if (state.continueReading.isNotEmpty) ...[
                          _ContinueReadingSection(books: state.continueReading),
                          const SizedBox(height: 24),
                        ],
                        _RecentActivitySection(activities: state.recentActivity),
                      ],
                    ],
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.userName, required this.avatarUrl});

  final String userName;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.homeGreeting(userName),
            style: AppTypography.displaySm,
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.tangerine100,
          backgroundImage: avatarUrl.isEmpty ? null : NetworkImage(avatarUrl),
          child: avatarUrl.isEmpty
              ? Text(
                  userName.isEmpty ? '?' : userName[0].toUpperCase(),
                  style: AppTypography.subheading.copyWith(color: AppColors.tangerine700),
                )
              : null,
        ),
      ],
    );
  }
}

class _StreakHeroCard extends StatelessWidget {
  const _StreakHeroCard({required this.currentStreak});

  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tangerine100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: AppColors.tangerine500, size: 36),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$currentStreak', style: AppTypography.displayLg),
              Text(l10n.dayStreak, style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeatmapStrip extends StatelessWidget {
  const _HeatmapStrip({required this.last7Days});

  final List<DailyStat> last7Days;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxMinutes = last7Days.fold(
      0,
      (max, stat) => stat.totalMinutes > max ? stat.totalMinutes : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final stat in last7Days)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: heatmapColorFor(minutes: stat.totalMinutes, maxMinutes: maxMinutes),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => context.go(AppRoutes.stats),
          child: Text(
            l10n.viewFullHeatmap,
            style: AppTypography.caption.copyWith(color: AppColors.tangerine700),
          ),
        ),
      ],
    );
  }
}

class _ContinueReadingSection extends StatelessWidget {
  const _ContinueReadingSection({required this.books});

  final List<UserBook> books;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.continueReading, style: AppTypography.heading),
        const SizedBox(height: 12),
        SizedBox(
          // Asked of the card rather than hardcoded: the compact variant is
          // what fits in a carousel slot, and it is the thing that knows how
          // tall that is at the user's current text size.
          height: ShelfBookCard.compactHeightFor(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 280,
              child: ShelfBookCard.compact(userBook: books[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.recentActivity, style: AppTypography.heading),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FeedPage()),
              ),
              child: Text(l10n.viewAllActivity),
            ),
          ],
        ),
        for (final activity in activities)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: switch (activity.payload) {
              SessionActivityPayload() => SessionActivityCard(activity: activity),
              BadgeActivityPayload() => BadgeActivityCard(activity: activity),
            },
          ),
      ],
    );
  }
}

class _EmptyStateCta extends StatelessWidget {
  const _EmptyStateCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          const Icon(Icons.menu_book_outlined, size: 40, color: AppColors.tangerine300),
          const SizedBox(height: 16),
          Text(
            l10n.startFirstSessionCta,
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startFirstSessionBody,
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onTap, child: Text(l10n.startSession)),
        ],
      ),
    );
  }
}
