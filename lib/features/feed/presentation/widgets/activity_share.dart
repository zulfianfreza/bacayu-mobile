import 'package:flutter/material.dart';

import '../../../../core/sharing/models/session_share_data.dart';
import '../../../../core/sharing/widgets/share_card_preview_sheet.dart';
import '../../domain/entities/activity.dart';

/// Whether [activity] has a share card to offer.
///
/// A badge unlock has no reading card to render, and someone else's session is
/// not yours to post — which is why [isOwnActivity] is asked for rather than
/// derived here: the caller is the one holding both the activity and the
/// viewer.
bool canShareActivity(Activity activity, {required bool isOwnActivity}) =>
    activity.payload is SessionActivityPayload && isOwnActivity;

/// Opens the share-card preview for a session activity.
///
/// Lives beside the activity cards because it decides *what* a shareable
/// activity is; the sheet it opens is core/sharing's. Both entry points — the
/// card's inline button and the detail page's — go through here, so the two can
/// never disagree about what gets shared.
Future<void> shareActivity(BuildContext context, Activity activity) async {
  final payload = activity.payload;
  if (payload is! SessionActivityPayload) return;

  await ShareCardPreviewSheet.show(
    context,
    data: SessionShareData(
      bookTitle: payload.bookTitle,
      // The denormalized feed payload has no book authors — the card drops
      // that line rather than inventing one.
      bookAuthors: const [],
      bookCoverUrl: payload.bookCoverUrl,
      pagesRead: payload.pagesRead,
      durationSeconds: payload.activeDurationSeconds,
      speedPpm: payload.speedPpm,
    ),
  );
}
