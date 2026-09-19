import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_listener.dart';
import '../cubit/follow_cubit.dart';
import '../cubit/follow_state.dart';
import 'user_list_tile.dart';

/// The body both follow lists share — loading, failure, empty, and the rows
/// themselves. The two pages differ only in which loader they call, the empty
/// message, and whether "follows you back" is worth saying.
class FollowList extends StatelessWidget {
  const FollowList({
    super.key,
    required this.emptyMessage,
    required this.showFollowsYouBack,
  });

  final String emptyMessage;
  final bool showFollowsYouBack;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FollowCubit, FollowState>(
      listener: (context, state) {
        if (state is FollowActionError) {
          context.showFailureSnackBar(state.failure);
        }
      },
      builder: (context, state) {
        if (state is FollowInitial || state is FollowLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FollowError) {
          return _FollowListMessage(
            icon: Icons.cloud_off,
            text: state.failure.localizedMessage(context),
          );
        }

        final users = state.users;
        if (users.isEmpty) {
          return _FollowListMessage(
            icon: Icons.group_outlined,
            text: emptyMessage,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = users[index];
            return UserListTile(
              user: user,
              isPending: state.pendingUserIds.contains(user.id),
              showFollowsYouBack: showFollowsYouBack,
              onToggleFollow: () =>
                  context.read<FollowCubit>().toggleFollow(user),
            );
          },
        );
      },
    );
  }
}

/// Nothing to show, or the list itself failed — the same quiet illustration in
/// both cases, so an empty page never reads as a broken one.
class _FollowListMessage extends StatelessWidget {
  const _FollowListMessage({required this.icon, required this.text});

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
