import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_listener.dart';
import '../cubit/follow_cubit.dart';
import '../cubit/follow_state.dart';
import '../widgets/user_list_tile.dart';

class FollowingPage extends StatelessWidget {
  const FollowingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FollowCubit>()..loadFollowing(),
      child: const _FollowingListView(),
    );
  }
}

class _FollowingListView extends StatelessWidget {
  const _FollowingListView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.followingTitle)),
      body: BlocConsumer<FollowCubit, FollowState>(
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
            return Center(
              child: Text(state.failure.localizedMessage(context), style: AppTypography.body),
            );
          }

          final users = state.users;
          if (users.isEmpty) {
            return Center(child: Text(l10n.noFollowing, style: AppTypography.body));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserListTile(
                user: user,
                isPending: state.pendingUserIds.contains(user.id),
                onToggleFollow: () => context.read<FollowCubit>().toggleFollow(user),
              );
            },
          );
        },
      ),
    );
  }
}
