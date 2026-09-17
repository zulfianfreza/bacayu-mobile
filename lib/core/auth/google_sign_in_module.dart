import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

/// Single [GoogleSignIn] instance for the whole app. `serverClientId` comes
/// from `--dart-define=GOOGLE_OAUTH_CLIENT_ID=...` and MUST be the exact
/// same OAuth Web Client ID the backend uses to verify Google ID tokens
/// (see backend CLAUDE.md) — a mismatched audience makes every
/// `POST /auth/google` call fail verification.
@module
abstract class GoogleSignInModule {
  @lazySingleton
  GoogleSignIn googleSignIn() => GoogleSignIn(
        serverClientId: const String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID'),
      );
}
