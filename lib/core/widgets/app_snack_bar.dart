import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

final _dismissSnackBars = Expando<VoidCallback>();

extension AppSnackBar on BuildContext {
  void showAppSnackBar(String message) {
    final overlay = Overlay.of(this, rootOverlay: true);
    _dismissSnackBars[overlay]?.call();

    final theme = Theme.of(this);
    final persistent = MediaQuery.accessibleNavigationOf(this);
    late final OverlayEntry entry;
    var dismissed = false;

    void dismiss() {
      if (dismissed) return;
      dismissed = true;
      if (overlay.mounted) entry.remove();
      entry.dispose();
      _dismissSnackBars[overlay] = null;
    }

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.paddingOf(context).top + 12,
        left: 16,
        right: 16,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -12 * (1 - value)),
                  child: child,
                ),
              ),
              child: _SnackBarLifetime(
                onDismiss: dismiss,
                persistent: persistent,
                child: Dismissible(
                  key: ObjectKey(entry),
                  direction: DismissDirection.up,
                  onDismissed: (_) => dismiss(),
                  child: Material(
                    color: theme.colorScheme.inverseSurface,
                    elevation: 4,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Semantics(
                      liveRegion: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onInverseSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    _dismissSnackBars[overlay] = dismiss;
  }
}

class _SnackBarLifetime extends StatefulWidget {
  const _SnackBarLifetime({
    required this.onDismiss,
    required this.persistent,
    required this.child,
  });

  final VoidCallback onDismiss;
  final bool persistent;
  final Widget child;

  @override
  State<_SnackBarLifetime> createState() => _SnackBarLifetimeState();
}

class _SnackBarLifetimeState extends State<_SnackBarLifetime> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.persistent) {
      _timer = Timer(const Duration(seconds: 4), widget.onDismiss);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
