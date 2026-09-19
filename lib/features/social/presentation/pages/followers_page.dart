import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../cubit/follow_cubit.dart';
import '../widgets/follow_list.dart';

class FollowersPage extends StatelessWidget {
  const FollowersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FollowCubit>()..loadFollowers(),
      child: const _FollowersView(),
    );
  }
}

class _FollowersView extends StatelessWidget {
  const _FollowersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.followersTitle)),
      body: FollowList(
        emptyMessage: context.l10n.noFollowers,
        // Everyone here already follows you — that is what put them on this
        // page — so the caption would repeat on every card.
        showFollowsYouBack: false,
      ),
    );
  }
}
