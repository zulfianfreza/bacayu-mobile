import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_listener.dart';
import '../cubit/user_search_bloc.dart';
import '../cubit/user_search_event.dart';
import '../cubit/user_search_state.dart';
import '../widgets/user_list_tile.dart';

/// Find people by name, and follow them without leaving the page.
class UserSearchPage extends StatelessWidget {
  const UserSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserSearchBloc>(),
      child: const _UserSearchView(),
    );
  }
}

class _UserSearchView extends StatefulWidget {
  const _UserSearchView();

  @override
  State<_UserSearchView> createState() => _UserSearchViewState();
}

class _UserSearchViewState extends State<_UserSearchView> {
  final _queryController = TextEditingController();
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
    _queryController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      context.read<UserSearchBloc>().add(const UserSearchLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.findFriends)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _queryController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.userSearchHint,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Image.asset(
                      'assets/icons/search-stroke.png',
                      width: 20,
                      height: 20,
                      color: AppColors.slate400,
                    ),
                  ),
                  // The decorator's default minimum here is 48x48 — a tap
                  // target, which would stretch this decorative glyph to the
                  // field's full height.
                  prefixIconConstraints: const BoxConstraints(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: _fieldBorder(AppColors.slate200),
                  enabledBorder: _fieldBorder(AppColors.slate200),
                  focusedBorder: _fieldBorder(
                    AppColors.tangerine,
                    width: 2.5,
                  ),
                ),
                onChanged: (query) =>
                    context.read<UserSearchBloc>().add(
                      UserSearchQueryChanged(query),
                    ),
              ),
            ),
            Expanded(
              child: BlocConsumer<UserSearchBloc, UserSearchState>(
                listener: (context, state) {
                  if (state is UserSearchActionError) {
                    context.showFailureSnackBar(state.failure);
                  }
                },
                builder: (context, state) => switch (state) {
                  UserSearchInitial() => _UserSearchMessage(
                    icon: Image.asset(
                      'assets/icons/add-team-stroke.png',
                      width: 40,
                      height: 40,
                      color: AppColors.tangerine300,
                    ),
                    text: l10n.findFriendsBody,
                  ),
                  UserSearchLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  UserSearchError(:final failure) => _UserSearchMessage(
                    icon: const Icon(
                      Icons.cloud_off,
                      size: 40,
                      color: AppColors.tangerine300,
                    ),
                    text: failure.localizedMessage(context),
                  ),
                  UserSearchLoaded() || UserSearchActionError() =>
                    _Results(
                      state: state,
                      scrollController: _scrollController,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The result rows, or "no one matched" once a search has actually run.
class _Results extends StatelessWidget {
  const _Results({required this.state, required this.scrollController});

  final UserSearchState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final users = state.users;

    if (users.isEmpty) {
      return _UserSearchMessage(
        icon: const Icon(
          Icons.search_off,
          size: 40,
          color: AppColors.tangerine300,
        ),
        text: l10n.noUserSearchResults,
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: users.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= users.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final user = users[index];
        return UserListTile(
          user: user,
          isPending: state.pendingUserIds.contains(user.id),
          onToggleFollow: () => context.read<UserSearchBloc>().add(
            UserSearchFollowToggled(user),
          ),
        );
      },
    );
  }
}

/// The chunky input the rest of the app's forms use: a thick rounded border,
/// with focus called out by colour rather than a hairline.
OutlineInputBorder _fieldBorder(Color color, {double width = 2}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: color, width: width),
  );
}

/// A centred glyph and line — used for the prompt, for "no one matched", and
/// for a failed search, so an empty page never reads as a broken one.
class _UserSearchMessage extends StatelessWidget {
  const _UserSearchMessage({required this.icon, required this.text});

  /// Assets and `Icon`s both work here, so the prompt can carry the app's own
  /// artwork while the states without one keep a Material glyph.
  final Widget icon;

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 12),
            Text(text, style: AppTypography.body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
