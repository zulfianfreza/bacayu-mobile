import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../features/sessions/presentation/pages/session_start_page.dart';
import '../../features/sessions/presentation/widgets/book_picker_bottom_sheet.dart';
import '../../features/shelf/domain/entities/user_book.dart';
import '../localization/build_context_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/build_context_extension.dart';

/// Nav icons are assets rather than `IconData`, so the artwork can be swapped
/// without touching this file. Replace the files in `assets/icons/` — they
/// must be monochrome with a transparent background, because [_TintedIcon]
/// recolors them per state.
const _navHomeIcon = 'assets/icons/home-stroke.png';
const _navShelfIcon = 'assets/icons/library-stroke.png';
const _navStatsIcon = 'assets/icons/stats-stroke.png';
const _navProfileIcon = 'assets/icons/user-stroke.png';
const _navSessionIcon = 'assets/icons/record-alt-stroke.svg';

/// Root shell for the 4 primary tabs (Home/Shelf/Stats/Profile) — hosts
/// go_router's [StatefulNavigationShell] so each tab keeps its own
/// navigation stack independently (switching tabs never resets a tab's
/// in-progress state). The "Start Session" button sits in the middle of the
/// bar as a 5th, non-branch slot — it opens `BookPickerBottomSheet` directly.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Lets tests find the session action now that its icon is an asset rather
  /// than an [IconData].
  @visibleForTesting
  static const startSessionKey = Key('start-session-button');

  Future<void> _startSession(BuildContext context) async {
    final userBook = await showModalBottomSheet<UserBook>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const BookPickerBottomSheet(),
    );

    if (userBook == null || !context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SessionStartPage(userBook: userBook)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: navigationShell,
      bottomNavigationBar: _AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        onStartSession: () => _startSession(context),
      ),
    );
  }
}

class _AppBottomNavBar extends StatelessWidget {
  const _AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onStartSession,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onStartSession;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (icon: _navHomeIcon, label: l10n.tabHome),
      (icon: _navShelfIcon, label: l10n.tabShelf),
      (icon: _navStatsIcon, label: l10n.tabStats),
      (icon: _navProfileIcon, label: l10n.tabProfile),
    ];

    // Every slot gets an equal share of the bar, the session button included —
    // that is what keeps it on the same line as the tabs instead of floating
    // above them.
    final slots = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i == items.length ~/ 2) {
        slots.add(
          Expanded(child: _StartSessionButton(onPressed: onStartSession)),
        );
      }
      slots.add(
        Expanded(
          child: _NavItem(
            icon: items[i].icon,
            label: items[i].label,
            isActive: i == currentIndex,
            onTap: () => onTap(i),
          ),
        ),
      );
    }

    return Container(
      // The bar carries type, so it grows with the user's font size the way
      // its labels do — a hard 72 clips them the moment the text is scaled up.
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.hairline, width: 2)),
        // boxShadow: [
        //   BoxShadow(
        //     color: context.colors.hairline,
        //     blurRadius: 12,
        //     offset: const Offset(0, -2),
        //   ),
        // ],
      ),
      // Stretch so each slot owns the full height of the bar: a 42px-tall tap
      // target would be under the 44px minimum.
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: slots,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The active tab is carried by colour alone — no pill behind it.
    final color = isActive ? AppColors.tangerine : context.colors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 3,
            width: isActive ? 32 : 0,
            decoration: BoxDecoration(
              color: AppColors.tangerine,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _TintedIcon(asset: icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

/// Draws a monochrome asset in [color].
///
/// `srcIn` keeps the asset's alpha and replaces its colour outright, which is
/// what lets one file serve both the active and inactive state.
class _TintedIcon extends StatelessWidget {
  const _TintedIcon({
    required this.asset,
    required this.color,
    required this.size,
  });

  final String asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}

class _StartSessionButton extends StatelessWidget {
  const _StartSessionButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        key: AppShell.startSessionKey,
        message: context.l10n.startSession,
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          child: SvgPicture.asset(
            _navSessionIcon,
            height: 40,
            width: 40,
            colorFilter: ColorFilter.mode(AppColors.tangerine, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
