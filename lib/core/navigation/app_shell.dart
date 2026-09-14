import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/sessions/presentation/pages/session_timer_page.dart';
import '../../features/sessions/presentation/widgets/book_picker_bottom_sheet.dart';
import '../../features/shelf/domain/entities/user_book.dart';
import '../localization/build_context_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

const _barHeight = 64.0;
const _fabDiameter = 60.0;
const _fabOverlap = 24.0;

/// Root shell for the 4 primary tabs (Home/Shelf/Stats/Profile) — hosts
/// go_router's [StatefulNavigationShell] so each tab keeps its own
/// navigation stack independently (switching tabs never resets a tab's
/// in-progress state). The "Start Session" FAB is a plain action button,
/// NOT a 5th branch — it opens `BookPickerBottomSheet` directly.
///
/// Both the bottom bar and the FAB are laid out by hand in a [Stack]
/// (never `Scaffold.bottomNavigationBar`/`floatingActionButtonLocation`)
/// so the FAB overlaps the bar exactly per the mockup, not Material's
/// default notch.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  Future<void> _startSession(BuildContext context) async {
    final userBook = await showModalBottomSheet<UserBook>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const BookPickerBottomSheet(),
    );

    if (userBook == null || !context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionTimerPage(initialUserBook: userBook),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: _barHeight),
              child: navigationShell,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _AppBottomNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: _barHeight - _fabOverlap,
            child: Center(
              child: _StartSessionFab(onPressed: () => _startSession(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBottomNavBar extends StatelessWidget {
  const _AppBottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (Icons.home_outlined, Icons.home, l10n.tabHome),
      (Icons.menu_book_outlined, Icons.menu_book, l10n.tabShelf),
      (Icons.bar_chart_outlined, Icons.bar_chart, l10n.tabStats),
      (Icons.person_outline, Icons.person, l10n.tabProfile),
    ];

    return Container(
      height: _barHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(
              child: _NavItem(
                outlineIcon: items[i].$1,
                filledIcon: items[i].$2,
                label: items[i].$3,
                isActive: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
            // Gap in the middle row for the FAB to float above.
            if (i == 1) const SizedBox(width: _fabDiameter),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.tangerine100 : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? filledIcon : outlineIcon,
                size: 22,
                color: isActive ? AppColors.tangerine700 : AppColors.inkSoft,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isActive ? AppColors.tangerine700 : AppColors.inkSoft,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartSessionFab extends StatelessWidget {
  const _StartSessionFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.startSession,
      child: Material(
        color: AppColors.tangerine500,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: AppColors.tangerine500,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox(
            width: _fabDiameter,
            height: _fabDiameter,
            child: Icon(Icons.play_arrow, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
