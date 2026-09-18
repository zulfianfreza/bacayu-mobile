import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ProfileHeader(user: state.user),
                    const SizedBox(height: 20),
                    _StatsRow(
                      booksFinished: state.booksFinished,
                      currentStreak: state.user.currentStreak,
                      badgesUnlocked: state.badgesUnlocked,
                      totalBadges: state.totalBadges,
                    ),
                    const SizedBox(height: 16),
                    _FollowRow(
                      followersCount: state.followersCount,
                      followingCount: state.followingCount,
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.tangerine100,
          backgroundImage: user.avatarUrl.isEmpty
              ? null
              : NetworkImage(user.avatarUrl),
          child: user.avatarUrl.isEmpty
              ? Text(
                  user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                  style: AppTypography.displaySm.copyWith(
                    color: AppColors.tangerine700,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(user.name, style: AppTypography.heading),
      ],
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

    return Row(
      children: [
        Expanded(
          child: _StatColumn(
            value: '$booksFinished',
            label: l10n.profileStatsBooks,
          ),
        ),
        Expanded(
          child: _StatColumn(
            value: '$currentStreak',
            label: l10n.profileStatsStreak,
          ),
        ),
        Expanded(
          child: _StatColumn(
            value: '$badgesUnlocked/$totalBadges',
            label: l10n.profileStatsBadges,
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.heading),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

class _FollowRow extends StatelessWidget {
  const _FollowRow({
    required this.followersCount,
    required this.followingCount,
  });

  final int followersCount;
  final int followingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => context.push(AppRoutes.followers),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              l10n.profileFollowersCount(followersCount),
              style: AppTypography.bodyStrong,
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => context.push(AppRoutes.following),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              l10n.profileFollowingCount(followingCount),
              style: AppTypography.bodyStrong,
            ),
          ),
        ),
      ],
    );
  }
}
