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

class FollowersPage extends StatelessWidget {
  const FollowersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FollowCubit>()..loadFollowers(),
      child: const _FollowListView(),
    );
  }
}

class _FollowListView extends StatelessWidget {
  const _FollowListView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.followersTitle)),
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
            return Center(child: Text(l10n.noFollowers, style: AppTypography.body));
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
