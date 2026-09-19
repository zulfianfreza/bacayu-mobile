import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../cubit/follow_cubit.dart';
import '../widgets/follow_list.dart';

class FollowingPage extends StatelessWidget {
  const FollowingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FollowCubit>()..loadFollowing(),
      child: const _FollowingView(),
    );
  }
}

class _FollowingView extends StatelessWidget {
  const _FollowingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.followingTitle)),
      body: FollowList(
        emptyMessage: context.l10n.noFollowing,
        // Here the flag actually says something: who follows you back.
        showFollowsYouBack: true,
      ),
    );
  }
}
