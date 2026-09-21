import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/navigation/full_screen_page.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/build_context_extension.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/raised_box.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../../feed/domain/entities/activity.dart';
import '../../../feed/presentation/cubit/feed_cubit.dart';
import '../../../feed/presentation/cubit/feed_state.dart';
import '../../../feed/presentation/widgets/activity_author_header.dart';
import '../../../feed/presentation/widgets/badge_activity_card.dart';
import '../../../feed/presentation/widgets/session_activity_card.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/appearance_bottom_sheet.dart';
import '../widgets/language_bottom_sheet.dart';
import '../widgets/privacy_bottom_sheet.dart';
import '../widgets/settings_list_group.dart';
import 'help_support_page.dart';
import 'reading_goals_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() || ProfileLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              ProfileError(:final failure) => Center(
                child: Text(
                  failure.localizedMessage(context),
                  style: AppTypography.body,
                ),
              ),
              ProfileLoaded() => _ProfileTabs(state: state),
            };
          },
        ),
      ),
    );
  }
}

/// Who you are, then two tabs: your own activity and your settings.
///
/// The identity block scrolls away and the tab bar stays put — the header is
/// tall enough that pinning it would leave a list almost no room.
class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.state});

  final ProfileLoaded state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Provided above the tab view on purpose: switching tabs must not throw the
    // loaded activity away and fetch it again.
    return BlocProvider(
      create: (_) => getIt<MyActivityCubit>()..refresh(),
      child: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    _ProfileHeader(
                      user: state.user,
                      followersCount: state.followersCount,
                      followingCount: state.followingCount,
                    ),
                    const SizedBox(height: 16),
                    _StatsRow(
                      booksFinished: state.booksFinished,
                      currentStreak: state.user.currentStreak,
                      badgesUnlocked: state.badgesUnlocked,
                      totalBadges: state.totalBadges,
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedTabBar(
                TabBar(
                  labelColor: AppColors.tangerine600,
                  unselectedLabelColor: context.colors.textSecondary,
                  labelStyle: AppTypography.button,
                  unselectedLabelStyle: AppTypography.button,
                  indicatorColor: AppColors.tangerine500,
                  indicatorWeight: 3,
                  dividerColor: context.colors.hairline,
                  tabs: [
                    Tab(text: l10n.profileActivityTab),
                    Tab(text: l10n.profileSettingsTab),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              const _ActivityTab(),
              _SettingsTab(user: state.user),
            ],
          ),
        ),
      ),
    );
  }
}

/// Holds the tab bar on screen once the identity block has scrolled past.
class _PinnedTabBar extends SliverPersistentHeaderDelegate {
  const _PinnedTabBar(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Opaque: cards scroll underneath this bar.
    return ColoredBox(color: context.colors.surface, child: tabBar);
  }

  @override
  bool shouldRebuild(_PinnedTabBar oldDelegate) => oldDelegate.tabBar != tabBar;
}

/// The reader's own activity, newest first.
///
/// Every item here is theirs, so the cards keep their default `isOwnActivity`
/// — which is also what keeps the visibility menu on their own posts. The
/// author line stays because it is the only place a card says *when* something
/// happened.
class _ActivityTab extends StatelessWidget {
  const _ActivityTab();

  ActivityAuthorHeader _authorOf(Activity activity) => ActivityAuthorHeader(
    name: activity.author.name,
    avatarUrl: activity.author.avatarUrl,
    occurredAt: activity.occurredAt,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<MyActivityCubit, FeedState>(
      builder: (context, state) => switch (state) {
        FeedInitial() || FeedLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        FeedError(:final failure) => _ActivityMessage(
          icon: Icons.cloud_off,
          text: failure.localizedMessage(context),
        ),
        FeedLoaded(:final activities, :final isLoadingMore) => activities.isEmpty
            ? _ActivityMessage(
                icon: Icons.auto_stories_outlined,
                text: l10n.noActivityYet,
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  final metrics = notification.metrics;
                  if (metrics.pixels >= metrics.maxScrollExtent - 300) {
                    context.read<MyActivityCubit>().loadMore();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activities.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= activities.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final activity = activities[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
                    );
                  },
                ),
              ),
      },
    );
  }
}

/// Everything that used to sit under the profile header — same groups, same
/// order, just behind its own tab.
class _SettingsTab extends StatelessWidget {
  const _SettingsTab({required this.user});

  final User user;

  Future<void> _openReadingGoals(BuildContext context) async {
    final changed = await pushFullScreen<bool>(
      context,
      (_) => ReadingGoalsPage(user: user),
    );
    if (changed == true && context.mounted) {
      context.read<ProfileCubit>().load();
    }
  }

  Future<void> _openPrivacyPicker(BuildContext context) async {
    final changed = await PrivacyBottomSheet.show(
      context,
      currentValue: user.privacyDefault,
    );
    if (changed == true && context.mounted) {
      context.read<ProfileCubit>().load();
    }
  }

  Future<void> _confirmLogOut(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logOutConfirmTitle),
        content: Text(l10n.logOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.logOut),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await getIt<Logout>().call();
    if (context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SettingsListGroup(
          children: [
            SettingsListTile(
              icon: "assets/icons/flag-stroke.png",
              label: l10n.readingGoals,
              onTap: () => _openReadingGoals(context),
            ),
            SettingsListTile(
              icon: "assets/icons/globe-stroke.png",
              label: l10n.language,
              onTap: () => LanguageBottomSheet.show(context),
            ),
            SettingsListTile(
              iconData: Icons.dark_mode_outlined,
              label: l10n.appearance,
              onTap: () => AppearanceBottomSheet.show(context),
            ),
            SettingsListTile(
              icon: "assets/icons/lock-stroke.png",
              label: l10n.privacy,
              onTap: () => _openPrivacyPicker(context),
            ),
            SettingsListTile(
              icon: "assets/icons/question-mark-stroke.png",
              label: l10n.helpAndSupport,
              onTap: () =>
                  pushFullScreen(context, (_) => const HelpSupportPage()),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsListGroup(
          children: [
            SettingsListTile(
              icon: "assets/icons/logout-stroke.png",
              label: l10n.logOut,
              destructive: true,
              onTap: () => _confirmLogOut(context),
            ),
          ],
        ),
      ],
    );
  }
}

/// Nothing to show, or the list failed to load — the quiet icon-and-line the
/// app uses wherever a screen can come up empty.
class _ActivityMessage extends StatelessWidget {
  const _ActivityMessage({required this.icon, required this.text});

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

/// Avatar, name, join line and the two social counts — the whole identity in
/// one card. Strava-style: the counts sit inline under the name instead of in
/// their own stacked number-over-label columns, which is what keeps the band
/// compact.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.followersCount,
    required this.followingCount,
  });

  final User user;
  final int followersCount;
  final int followingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasAvatar = user.avatarUrl.isNotEmpty;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return BorderedCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.hairline, width: 2),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: context.colors.tangerineTint,
              backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl) : null,
              child: hasAvatar
                  ? null
                  : Text(
                      user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                      style: AppTypography.heading.copyWith(
                        color: context.colors.tangerineAccent,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Uncapped, like every other identity line in the app: a
                // long name wraps rather than being cut.
                Text(user.name, style: AppTypography.displaySm),
                const SizedBox(height: 2),
                Text(
                  l10n.memberSince(
                    DateFormat.yMMMM(locale).format(user.createdAt),
                  ),
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InlineFollowStat(
                      count: followersCount,
                      label: l10n.profileFollowersLabel,
                      onTap: () => context.push(AppRoutes.followers),
                    ),
                    const SizedBox(width: 16),
                    _InlineFollowStat(
                      count: followingCount,
                      label: l10n.profileFollowingLabel,
                      onTap: () => context.push(AppRoutes.following),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A count and its word on one line — the compact counterpart of a stacked
/// number-over-label column. The whole pair is the tap target.
class _InlineFollowStat extends StatelessWidget {
  const _InlineFollowStat({
    required this.count,
    required this.label,
    required this.onTap,
  });

  final int count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      // The label repeats the two Texts, so exclude them from the tree the
      // screen reader walks.
      excludeSemantics: true,
      label: '$count $label',
      child: GestureDetector(
        onTap: onTap,
        // Opaque so the gap around the pair is part of the target.
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count', style: AppTypography.subheading),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.booksFinished,
    required this.currentStreak,
    required this.badgesUnlocked,
    required this.totalBadges,
  });

  final int booksFinished;
  final int currentStreak;
  final int badgesUnlocked;
  final int totalBadges;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // IntrinsicHeight so the three tiles match the tallest one: "5/12" wraps
    // to two lines where "12" does not, and a row of uneven tiles reads as a
    // mistake rather than a set.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatTile(
              icon: 'assets/icons/book-open-02-stroke.png',
              value: '$booksFinished',
              label: l10n.profileStatsBooks,
              tint: context.colors.lagoonTint,
              accent: context.colors.lagoonAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatTile(
              icon: 'assets/images/day-streak.png',
              value: '$currentStreak',
              label: l10n.profileStatsStreak,
              tint: context.colors.tangerineTint,
              accent: context.colors.tangerineAccent,
              iconSize: 24,
              // The streak flame is full-colour artwork — tinting it to one
              // hue would flatten the yellow highlight that makes it read as
              // a flame.
              tintIcon: false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatTile(
              icon: 'assets/icons/award-stroke.png',
              value: '$badgesUnlocked/$totalBadges',
              label: l10n.profileStatsBadges,
              tint: context.colors.sunshineTint,
              accent: context.colors.sunshineAccent,
            ),
          ),
        ],
      ),
    );
  }
}

/// One number on its own chunky tile: a step-100 background carrying a step-700
/// icon, the chip recipe at tile size.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
    required this.accent,
    this.tintIcon = true,
    this.iconSize = 26,
  });

  final String icon;
  final String value;
  final String label;

  /// The tile's family: [tint] for the body, [accent] for the icon.
  final Color tint;
  final Color accent;

  /// Whether [icon] should be recoloured to [accent]. Off for artwork that is
  /// already coloured.
  final bool tintIcon;

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return RaisedBox(
      color: tint,
      radius: AppRadius.md,
      edgeHeight: 4,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            icon,
            width: iconSize,
            height: iconSize,
            color: tintIcon ? accent : null,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
