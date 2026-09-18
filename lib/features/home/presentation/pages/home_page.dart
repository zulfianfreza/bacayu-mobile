import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../feed/domain/entities/activity.dart';
import '../../../feed/presentation/pages/feed_page.dart';
import '../../../feed/presentation/widgets/activity_author_header.dart';
import '../../../feed/presentation/widgets/badge_activity_card.dart';
import '../../../feed/presentation/widgets/session_activity_card.dart';
import '../../../sessions/presentation/widgets/book_picker_bottom_sheet.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../../../shelf/presentation/widgets/shelf_book_card.dart';
import '../../../stats/domain/entities/daily_stat.dart';
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
              HomeInitial() ||
              HomeLoading() => const Center(child: CircularProgressIndicator()),
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
                    _Header(
                      userName: state.userName,
                      avatarUrl: state.avatarUrl,
                    ),
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
                      _RecentActivitySection(
                        activities: state.recentActivity,
                        userName: state.userName,
                        avatarUrl: state.avatarUrl,
                      ),
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
                  style: AppTypography.subheading.copyWith(
                    color: AppColors.tangerine700,
                  ),
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
          const Icon(
            Icons.local_fire_department,
            color: AppColors.tangerine500,
            size: 36,
          ),
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

/// Diameter of one day in the week strip.
const _dayCircleSize = 24.0;

class _HeatmapStrip extends StatelessWidget {
  const _HeatmapStrip({required this.last7Days});

  final List<DailyStat> last7Days;

  @override
  Widget build(BuildContext context) {
    // Abbreviated, not a single letter: in Indonesian three weekdays start
    // with S (Senin, Selasa, Sabtu), so an initial cannot tell them apart.
    // `E` is the locale's own short name, so English gets Mon/Tue/… for free.
    final dayName = DateFormat.E(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final stat in last7Days)
              Expanded(
                child: Column(
                  children: [
                    _DayCircle(read: stat.totalMinutes > 0),
                    const SizedBox(height: 6),
                    Text(
                      dayName.format(stat.date),
                      style: AppTypography.caption,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// One day of the last week: a circle that turns green with a check once
/// something was read that day.
///
/// Binary on purpose. How *much* was read is the full heatmap's job, one tap
/// away below — a week strip only has to answer "did I read?".
class _DayCircle extends StatelessWidget {
  const _DayCircle({required this.read});

  final bool read;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _dayCircleSize,
      height: _dayCircleSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: read ? AppColors.lagoon : AppColors.slate200,
      ),
      child: read
          ? const Icon(Icons.check, size: 16, color: AppColors.surface)
          : null,
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
  const _RecentActivitySection({
    required this.activities,
    required this.userName,
    required this.avatarUrl,
  });

  final List<Activity> activities;
  final String userName;
  final String avatarUrl;

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
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const FeedPage())),
              child: Text(l10n.viewAllActivity),
            ),
          ],
        ),
        for (final activity in activities)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            // Activities are posts: each card introduces its author and its
            // own timestamp, so one header per activity — never shared.
            child: switch (activity.payload) {
              SessionActivityPayload() => SessionActivityCard(
                activity: activity,
                author: _authorOf(activity),
              ),
              BadgeActivityPayload() => BadgeActivityCard(
                activity: activity,
                author: _authorOf(activity),
              ),
            },
          ),
      ],
    );
  }

  /// Activities are posts, so every card is introduced by its author. The feed
  /// endpoint only returns the requester's own activities for now, which makes
  /// that author the signed-in user.
  ActivityAuthorHeader _authorOf(Activity activity) => ActivityAuthorHeader(
    name: userName,
    avatarUrl: avatarUrl,
    occurredAt: activity.occurredAt,
  );
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
          const Icon(
            Icons.menu_book_outlined,
            size: 40,
            color: AppColors.tangerine300,
          ),
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
