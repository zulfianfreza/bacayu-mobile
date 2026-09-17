import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapts a [Stream] into the [Listenable] go_router's `refreshListenable`
/// wants — go_router doesn't ship this itself, this is the well-known
/// community pattern for it (from go_router's own examples). Used here to
/// wrap `AuthCubit.stream`, so a redirect re-evaluates the instant the cubit
/// emits a new state (e.g. `AuthUnauthenticated` after an auto-logout) —
/// nobody has to call `context.go('/login')` manually.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
