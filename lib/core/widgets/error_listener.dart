import 'package:flutter/material.dart';

import '../error/failure.dart';
import '../error/failure_localizer.dart';

/// The one place every "show a snackbar for a failed operation" call site
/// in the app funnels through — used from a `BlocListener`/`BlocConsumer`
/// listener, or straight after a `result.fold(...)` on a raw usecase call.
///
/// [SessionExpiredFailure] is deliberately skipped: `dio_client.dart`'s 401
/// interceptor already triggered a global auto-logout (see
/// `SessionExpiredHandler`/`AuthCubit.forceLogout`), and `LoginPage` shows
/// its own one-time "session expired" message once the redirect lands there
/// — showing a second, page-local snackbar here would double up.
extension FailureSnackBar on BuildContext {
  void showFailureSnackBar(Failure failure) {
    if (failure is SessionExpiredFailure) return;
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(failure.localizedMessage(this))),
    );
  }
}
