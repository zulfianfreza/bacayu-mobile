import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../cubit/leaderboard_cubit.dart';
import '../cubit/leaderboard_state.dart';
import '../../../../core/theme/build_context_extension.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LeaderboardCubit>()..load(),
      child: const _LeaderboardView(),
    );
  }
}

class _LeaderboardView extends StatelessWidget {
  const _LeaderboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.leaderboardTitle)),
      body: BlocBuilder<LeaderboardCubit, LeaderboardState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _RangeToggle(
                  activeRange: state.range,
                  onChanged: (range) =>
                      context.read<LeaderboardCubit>().changeRange(range),
                ),
              ),
              Expanded(
                child: switch (state) {
                  LeaderboardInitial() || LeaderboardLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  LeaderboardError(:final failure) => Center(
                      child: Text(
                        failure.localizedMessage(context),
                        style: AppTypography.body,
                      ),
                    ),
                  LeaderboardLoaded(:final entries, :final currentUser) =>
                    _LeaderboardList(entries: entries, currentUser: currentUser),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RangeToggle extends StatelessWidget {
  const _RangeToggle({required this.activeRange, required this.onChanged});

  final LeaderboardRange activeRange;
  final ValueChanged<LeaderboardRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = [
      (LeaderboardRange.week, l10n.rangeWeek),
      (LeaderboardRange.month, l10n.rangeMonth),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.hairline,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          for (final (range, label) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(range),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: range == activeRange
                        ? AppColors.tangerine500
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.button.copyWith(
                      color: range == activeRange ? Colors.white : context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({required this.entries, required this.currentUser});

  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUser;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selfInTopN =
        currentUser != null && entries.any((e) => e.userId == currentUser!.userId);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final entry in entries)
          _LeaderboardRow(
            entry: entry,
            isSelf: currentUser != null && entry.userId == currentUser!.userId,
          ),
        if (currentUser != null && !selfInTopN) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(l10n.yourPosition, style: AppTypography.caption),
          ),
          _LeaderboardRow(entry: currentUser!, isSelf: true),
        ],
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry, required this.isSelf});

  final LeaderboardEntry entry;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = entry.avatarUrl;

    return Container(
      color: isSelf ? context.colors.tangerineWash : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${entry.rank}',
              style: AppTypography.bodyStrong,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: context.colors.tangerineTint,
            backgroundImage:
                avatarUrl == null || avatarUrl.isEmpty ? null : NetworkImage(avatarUrl),
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Text(
                    entry.name.isEmpty ? '?' : entry.name[0].toUpperCase(),
                    style: AppTypography.caption.copyWith(color: context.colors.tangerineAccent),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: AppTypography.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${entry.totalPages}', style: AppTypography.bodyStrong),
        ],
      ),
    );
  }
}
