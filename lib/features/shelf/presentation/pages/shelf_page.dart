import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/navigation/full_screen_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../../core/widgets/raised_box.dart';
import '../../../books/presentation/pages/book_search_page.dart';
import '../../domain/entities/user_book.dart';
import '../cubit/shelf_cubit.dart';
import '../cubit/shelf_state.dart';
import '../widgets/shelf_book_card.dart';
import '../../../../core/theme/build_context_extension.dart';

class ShelfPage extends StatelessWidget {
  const ShelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShelfCubit>()..loadShelf(),
      child: const _ShelfView(),
    );
  }
}

class _ShelfView extends StatelessWidget {
  const _ShelfView();

  void _openAddBook(BuildContext context) {
    pushFullScreen(context, (_) => const BookSearchPage());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shelfTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addABook,
            onPressed: () => _openAddBook(context),
          ),
        ],
      ),
      body: BlocConsumer<ShelfCubit, ShelfState>(
        listener: (context, state) {
          if (state is ShelfUpdateError) {
            context.showFailureSnackBar(state.failure);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _FilterTabs(activeFilter: state.activeFilter),
              Expanded(child: _ShelfBody(state: state)),
            ],
          );
        },
      ),
    );
  }
}

class _ShelfBody extends StatelessWidget {
  const _ShelfBody({required this.state});

  final ShelfState state;

  @override
  Widget build(BuildContext context) {
    if (state case ShelfLoading()) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state case ShelfError(:final failure)) {
      return Center(
        child: Text(
          failure.localizedMessage(context),
          style: AppTypography.body,
        ),
      );
    }

    final items = state.items;

    if (items.isEmpty) {
      return _EmptyShelf(
        onAddBook: () => pushFullScreen(context, (_) => const BookSearchPage()),
      );
    }

    // Two books per row, laid out as rows rather than through a `GridView`:
    // titles are shown in full, so tiles differ in height, and a grid delegate
    // would either clip them or force a tallest-tile-wins aspect ratio on
    // every cover. A row at a time also keeps the list lazy.
    const columns = 2;
    const gap = 12.0;
    final rowCount = (items.length / columns).ceil();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rowCount,
      itemBuilder: (context, rowIndex) {
        final start = rowIndex * columns;
        final row = items.skip(start).take(columns).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: gap),
          // IntrinsicHeight gives the stretch something to resolve against;
          // a ListView hands each row an unbounded height otherwise. Both
          // cards then share the taller one's height, so a one-line title and
          // a four-line title still read as one grid.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  Expanded(
                    child: i < row.length
                        ? ShelfBookCard(userBook: row[i])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyShelf extends StatelessWidget {
  const _EmptyShelf({required this.onAddBook});

  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: AppColors.tangerine300,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.emptyShelfHeadline,
              style: AppTypography.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyShelfBody,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ChunkyButton(label: l10n.addABook, onPressed: onAddBook),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.activeFilter});

  final ShelfStatus? activeFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = <(ShelfStatus?, String)>[
      (null, l10n.filterAll),
      (ShelfStatus.wantToRead, l10n.statusWantToRead),
      (ShelfStatus.reading, l10n.statusReading),
      (ShelfStatus.finished, l10n.statusFinished),
      (ShelfStatus.dnf, l10n.statusDnf),
    ];

    return SizedBox(
      // Scaled with the user's font size: the pills carry labels, and a fixed
      // row would clip them the moment someone sets larger type.
      height: MediaQuery.textScalerOf(context).scale(56),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (status, label) = tabs[index];
          return _FilterTab(
            label: label,
            isActive: status == activeFilter,
            onTap: () => context.read<ShelfCubit>().changeFilter(status),
          );
        },
      ),
    );
  }
}

/// One shelf filter, built like the range control on Stats: a chunky pill on
/// its own edge, filled in when it is the active one.
class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RaisedBox(
        color: isActive ? AppColors.tangerine : context.colors.surface,
        radius: AppRadius.pill,
        edgeHeight: 3,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          label,
          style: AppTypography.button.copyWith(
            color: isActive ? Colors.white : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
