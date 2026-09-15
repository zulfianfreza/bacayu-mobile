import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/activity.dart';
import '../cubit/feed_cubit.dart';
import '../cubit/feed_state.dart';
import '../widgets/badge_activity_card.dart';
import '../widgets/session_activity_card.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FeedCubit>()..refresh(),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatefulWidget {
  const _FeedView();

  @override
  State<_FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<_FeedView> {
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

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      context.read<FeedCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedTitle)),
      body: BlocBuilder<FeedCubit, FeedState>(
        builder: (context, state) {
          return switch (state) {
            FeedInitial() || FeedLoading() =>
              const Center(child: CircularProgressIndicator()),
            FeedError(:final failure) => Center(
                child: Text(
                  failure.localizedMessage(context),
                  style: AppTypography.body,
                ),
              ),
            FeedLoaded(:final activities, :final isLoadingMore) => RefreshIndicator(
                onRefresh: () => context.read<FeedCubit>().refresh(),
                child: activities.isEmpty
                    ? ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(l10n.feedEmpty, style: AppTypography.body),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scrollController,
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
                              SessionActivityPayload() =>
                                SessionActivityCard(activity: activity),
                              BadgeActivityPayload() =>
                                BadgeActivityCard(activity: activity),
                            },
                          );
                        },
                      ),
              ),
          };
        },
      ),
    );
  }
}
