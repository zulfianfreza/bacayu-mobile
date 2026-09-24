import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/navigation/full_screen_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/raised_box.dart';
import '../../../feed/domain/entities/activity.dart';
import '../../../feed/presentation/cubit/feed_cubit.dart';
import '../../../feed/presentation/cubit/feed_state.dart';
import '../../../feed/presentation/widgets/activity_author_header.dart';
import '../../../feed/presentation/widgets/badge_activity_card.dart';
import '../../../feed/presentation/widgets/session_activity_card.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../../../shelf/presentation/widgets/shelf_book_card.dart';
import '../../../social/presentation/pages/user_search_page.dart';
import '../../../stats/domain/entities/daily_stat.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../../../core/theme/build_context_extension.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Two cubits, one page: HomeCubit owns the dashboard data, SocialFeedCubit
    // owns the social feed. The feed is paged on scroll, which is a whole state
    // machine of its own — folding it into HomeCubit would just hide it.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<HomeCubit>()..load()),
        BlocProvider(create: (_) => getIt<SocialFeedCubit>()..refresh()),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// The feed pages itself in as the page nears its end — there is no "see
  /// all", this list *is* the feed.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      context.read<SocialFeedCubit>().loadMore();
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<HomeCubit>().load(),
      context.read<SocialFeedCubit>().refresh(),
    ]);
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
                onRefresh: _refresh,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _Header(
                      userName: state.userName,
                      avatarUrl: state.avatarUrl,
                    ),
                    const SizedBox(height: 20),
                    _StreakCard(
                      currentStreak: state.currentStreak,
                      last7Days: state.last7Days,
                    ),
                    const SizedBox(height: 24),
                    if (state.continueReading.isNotEmpty) ...[
                      _ContinueReadingSection(books: state.continueReading),
                      const SizedBox(height: 24),
                    ],
                    const _ActivityFeed(),
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
    final hour = DateTime.now().hour;
    final greeting = hour >= 17
        ? l10n.greetingEvening
        : hour >= 12
            ? l10n.greetingAfternoon
            : l10n.greetingMorning;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.homeGreeting(greeting, userName),
            style: AppTypography.displaySm,
          ),
        ),
        const SizedBox(width: 12),
        _SearchPeopleButton(),
      ],
    );
  }
}

/// The way into user search: a bare icon beside the greeting, so finding
/// people is one tap from the top of Home — not only from the empty state.
class _SearchPeopleButton extends StatelessWidget {
  const _SearchPeopleButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.findFriends,
      child: GestureDetector(
        onTap: () => pushFullScreen(context, (_) => const UserSearchPage()),
        child: Image.asset(
          'assets/icons/search-stroke.png',
          width: 24,
          height: 24,
          color: context.colors.ink,
        ),
      ),
    );
  }
}

/// The streak and the week that feeds it, in one card: the number is the
/// headline, the strip underneath is the evidence for it.
class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.currentStreak, required this.last7Days});

  final int currentStreak;
  final List<DailyStat> last7Days;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/day-streak.png',
                width: 64,
                height: 64,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currentStreak',
                      style: AppTypography.displayLg.copyWith(fontSize: 36),
                    ),
                    Text(l10n.dayStreak, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _WeekStrip(last7Days: last7Days),
        ],
      ),
    );
  }
}

/// Diameter of one day in the week strip.
const _dayCircleSize = 24.0;

/// One week, oldest first, as a row of day markers.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.last7Days});

  final List<DailyStat> last7Days;

  @override
  Widget build(BuildContext context) {
    // Abbreviated, not a single letter: in Indonesian three weekdays start
    // with S (Senin, Selasa, Sabtu), so an initial cannot tell them apart.
    // `E` is the locale's own short name, so English gets Mon/Tue/… for free.
    final dayName = DateFormat.E(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return Row(
      children: [
        for (final stat in last7Days)
          Expanded(
            child: Column(
              children: [
                _DayCircle(read: stat.totalMinutes > 0),
                const SizedBox(height: 6),
                Text(
                  dayName.format(stat.date)[0],
                  style: AppTypography.caption,
                  maxLines: 1,
                ),
              ],
            ),
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
        color: read ? AppColors.lagoon : context.colors.hairline,
      ),
      child: read
          ? Icon(Icons.check, size: 16, color: context.colors.surface)
          : null,
    );
  }
}

class _ContinueReadingSection extends StatelessWidget {
  const _ContinueReadingSection({required this.books});

  final List<UserBook> books;

  /// Width of one carousel slot. The width is fixed; the height is not.
  static const _slotWidth = 280.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.continueReading, style: AppTypography.heading),
        const SizedBox(height: 12),
        // IntrinsicHeight rather than a fixed slot height: each card is exactly
        // as tall as its own title, author and progress need, and the row takes
        // the tallest of them. A hardcoded height either clips a long title or
        // leaves dead space under a short one.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < books.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  SizedBox(
                    width: _slotWidth,
                    child: ShelfBookCard.compact(userBook: books[i]),
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

/// The social feed: everyone the viewer follows, newest first. Pages itself in
/// as the page scrolls.
class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<SocialFeedCubit, FeedState>(
      builder: (context, state) {
        return switch (state) {
          FeedInitial() || FeedLoading() => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
          FeedError(:final failure) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              failure.localizedMessage(context),
              style: AppTypography.body,
            ),
          ),
          FeedLoaded(
            :final activities,
            :final isLoadingMore,
            :final viewerId,
          ) =>
            activities.isEmpty
                ? const _FindFriendsCta()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.recentActivity, style: AppTypography.heading),
                      const SizedBox(height: 12),
                      for (final activity in activities)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          // Activities are posts: each card introduces its own
                          // author and timestamp — now the real one from the
                          // feed, not the signed-in user by assumption.
                          child: switch (activity.payload) {
                            SessionActivityPayload() => SessionActivityCard(
                              activity: activity,
                              isOwnActivity: activity.author.id == viewerId,
                              author: _authorOf(activity),
                            ),
                            BadgeActivityPayload() => BadgeActivityCard(
                              activity: activity,
                              isOwnActivity: activity.author.id == viewerId,
                              author: _authorOf(activity),
                            ),
                          },
                        ),
                      if (isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
        };
      },
    );
  }

  ActivityAuthorHeader _authorOf(Activity activity) => ActivityAuthorHeader(
    name: activity.author.name,
    avatarUrl: activity.author.avatarUrl,
    occurredAt: activity.occurredAt,
  );
}

/// Shown instead of the feed when there is nothing in it — which, on a social
/// feed, means the reader follows nobody yet rather than that they haven't
/// read anything.
class _FindFriendsCta extends StatelessWidget {
  const _FindFriendsCta();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return RaisedBox(
      color: context.colors.surface,
      radius: AppRadius.lg,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.people_outline,
            size: 40,
            color: AppColors.tangerine300,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.findFriendsHeadline,
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.findFriendsBody,
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ChunkyButton(
            label: l10n.findFriends,
            onPressed: () =>
                pushFullScreen(context, (_) => const UserSearchPage()),
          ),
        ],
      ),
    );
  }
}
