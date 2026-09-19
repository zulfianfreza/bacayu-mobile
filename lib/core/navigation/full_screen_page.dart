import 'package:flutter/material.dart';

/// Pushes a page over everything — bottom navigation bar included.
///
/// `Navigator.of(context)` inside a tab resolves to that tab's own Navigator,
/// and the shell renders those *inside* its body (it is a
/// `StatefulShellRoute.indexedStack`). A page pushed on one therefore stops at
/// the bottom bar, which is right for a sheet but wrong for a detail screen.
/// Going to the root navigator puts the page above the whole shell.
Future<T?> pushFullScreen<T>(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(
    context,
    rootNavigator: true,
  ).push<T>(MaterialPageRoute<T>(builder: builder));
}
