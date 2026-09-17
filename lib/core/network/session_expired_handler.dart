/// Lets `core/network` trigger a global auto-logout without importing
/// anything from `features/auth` — `dio_client.dart`'s interceptor depends
/// only on this interface; `AuthCubit` is the concrete implementation,
/// wired up via DI (see the small binding module next to `AuthCubit`).
abstract class SessionExpiredHandler {
  void onSessionExpired();
}
