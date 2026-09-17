import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../localization/build_context_extension.dart';
import 'failure.dart';

/// Server error codes this app already knows how to localize. Grows one
/// entry at a time, as each feature is built — NOT meant to be exhaustive
/// up front. Any code not listed here falls through to the raw backend
/// message (see [FailureLocalizer.localizedMessage]), so an un-mapped
/// backend error never crashes or shows a blank string.
Map<String, String> _knownServerCodes(AppLocalizations l10n) => {
      'SESSION_NOT_FOUND': l10n.sessionNotFound,
      'INTERNAL_ERROR': l10n.somethingWentWrong,
      'EMAIL_ALREADY_EXISTS': l10n.emailAlreadyExists,
      'INVALID_CREDENTIALS': l10n.invalidCredentials,
      'BOOK_NOT_FOUND': l10n.bookNotFound,
      'ALREADY_IN_SHELF': l10n.alreadyInShelf,
      'CANNOT_FOLLOW_SELF': l10n.cannotFollowSelf,
      'ALREADY_LIKED': l10n.alreadyLiked,
    };

extension FailureLocalizer on Failure {
  /// User-facing, localized message for this failure.
  String localizedMessage(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      NetworkFailure() => l10n.noInternetConnection,
      CacheFailure() => l10n.somethingWentWrong,
      SessionExpiredFailure() => l10n.sessionExpired,
      ValidationFailure(:final details) => details.values.isNotEmpty
          ? details.values.first
          : l10n.somethingWentWrong,
      ServerFailure(:final code, :final message) =>
        _knownServerCodes(l10n)[code] ?? message,
    };
  }
}
