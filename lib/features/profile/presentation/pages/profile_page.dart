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
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/raised_box.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
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

  Future<void> _openReadingGoals(BuildContext context, User user) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ReadingGoalsPage(user: user)),
    );
    if (changed == true && context.mounted) {
      context.read<ProfileCubit>().load();
    }
  }

  Future<void> _openPrivacyPicker(BuildContext context, User user) async {
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
              ProfileLoaded() => RefreshIndicator(
                onRefresh: () => context.read<ProfileCubit>().load(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _ProfileHeader(
                      user: state.user,
                      followersCount: state.followersCount,
                      followingCount: state.followingCount,
                    ),
                    const SizedBox(height: 24),
                    _StatsRow(
                      booksFinished: state.booksFinished,
                      currentStreak: state.user.currentStreak,
                      badgesUnlocked: state.badgesUnlocked,
                      totalBadges: state.totalBadges,
                    ),
                    const SizedBox(height: 24),
                    SettingsListGroup(
                      children: [
                        SettingsListTile(
                          icon: "assets/icons/flag-stroke.png",
                          label: l10n.readingGoals,
                          onTap: () => _openReadingGoals(context, state.user),
                        ),
                        SettingsListTile(
                          icon: "assets/icons/globe-stroke.png",
                          label: l10n.language,
                          onTap: () => LanguageBottomSheet.show(context),
                        ),
                        SettingsListTile(
                          icon: "assets/icons/lock-stroke.png",
                          label: l10n.privacy,
                          onTap: () => _openPrivacyPicker(context, state.user),
                        ),
                        SettingsListTile(
                          icon: "assets/icons/question-mark-stroke.png",
                          label: l10n.helpAndSupport,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportPage(),
                            ),
                          ),
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
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}

/// The avatar, the name, and the two counts that describe the account's
/// social side — one card, because they are one identity rather than three
/// separate sections.
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

    return BorderedCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.slate200, width: 2),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.tangerine100,
              backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl) : null,
              child: hasAvatar
                  ? null
                  : Text(
                      user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                      style: AppTypography.displaySm.copyWith(
                        color: AppColors.tangerine700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _FollowPill(
                    label: l10n.profileFollowersCount(followersCount),
                    onTap: () => context.push(AppRoutes.followers),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FollowPill(
                    label: l10n.profileFollowingCount(followingCount),
                    onTap: () => context.push(AppRoutes.following),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A count you can tap, drawn with the same border language as the cards so it
/// reads as pressable sitting on the header's white body.
class _FollowPill extends StatelessWidget {
  const _FollowPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BorderedCard(
        radius: AppRadius.pill,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodyStrong,
            textAlign: TextAlign.center,
          ),
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
              tint: AppColors.lagoon100,
              accent: AppColors.lagoon700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatTile(
              icon: 'assets/images/day-streak.png',
              value: '$currentStreak',
              label: l10n.profileStatsStreak,
              tint: AppColors.tangerine100,
              accent: AppColors.tangerine700,
              iconSize: 32,
              // The streak flame is full-colour artwork — tinting it to one
              // hue would flatten the yellow highlight that makes it read as
              // a flame.
              tintIcon: false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatTile(
              icon: 'assets/icons/star-solid.png',
              value: '$badgesUnlocked/$totalBadges',
              label: l10n.profileStatsBadges,
              tint: AppColors.sunshine100,
              accent: AppColors.sunshine700,
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
