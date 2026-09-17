import 'package:equatable/equatable.dart';

/// Everything a [SessionShareCard] renders, flattened to plain values.
///
/// Deliberately NOT a `sessions` or `feed` entity: the card is shared from
/// both features, and they carry different shapes (`ReadingSession` +
/// `UserBook` on one side, `SessionActivityPayload` on the other — which has
/// no author and no internal book id). Callers map into this, so the widget
/// never depends on either feature.
class SessionShareData extends Equatable {
  const SessionShareData({
    required this.bookTitle,
    required this.bookAuthors,
    required this.bookCoverUrl,
    required this.pagesRead,
    required this.durationSeconds,
    required this.speedPpm,
    required this.sessionDate,
    this.streakDays,
  });

  final String bookTitle;
  final List<String> bookAuthors;
  final String? bookCoverUrl;
  final int pagesRead;
  final int durationSeconds;
  final double speedPpm;
  final DateTime sessionDate;

  /// `null` renders the card without the streak chip — never a blocker for
  /// sharing (the fresh `GetCurrentUser` that feeds this can fail, and that's
  /// fine).
  final int? streakDays;

  @override
  List<Object?> get props => [
        bookTitle,
        bookAuthors,
        bookCoverUrl,
        pagesRead,
        durationSeconds,
        speedPpm,
        sessionDate,
        streakDays,
      ];
}
