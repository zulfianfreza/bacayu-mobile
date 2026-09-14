import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../books/presentation/pages/book_search_page.dart';
import '../../domain/entities/user_book.dart';
import '../cubit/shelf_cubit.dart';
import '../cubit/shelf_state.dart';
import '../widgets/shelf_book_card.dart';

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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BookSearchPage()),
    );
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.localizedMessage(context))),
            );
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
        onAddBook: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BookSearchPage()),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShelfBookCard(userBook: items[index]),
      ),
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
            Icon(Icons.menu_book_outlined, size: 48, color: AppColors.tangerine300),
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
            ElevatedButton(
              onPressed: onAddBook,
              child: Text(l10n.addABook),
            ),
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
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (status, label) = tabs[index];
          final isActive = status == activeFilter;
          return ChoiceChip(
            label: Text(label),
            selected: isActive,
            onSelected: (_) =>
                context.read<ShelfCubit>().changeFilter(status),
            showCheckmark: false,
            selectedColor: AppColors.tangerine500,
            backgroundColor: AppColors.surface,
            labelStyle: AppTypography.button.copyWith(
              color: isActive ? Colors.white : AppColors.inkSoft,
            ),
            side: BorderSide(
              color: isActive ? AppColors.tangerine500 : AppColors.line,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          );
        },
      ),
    );
  }
}
