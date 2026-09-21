import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../badges/presentation/widgets/badge_artwork.dart';
import '../../../books/presentation/pages/book_detail_page.dart';
import '../../../social/domain/entities/activity_comment.dart';
import '../../../social/domain/usecases/add_comment.dart';
import '../../../social/domain/usecases/list_comments.dart';
import '../../../social/presentation/widgets/comment_tile.dart';
import '../../../social/presentation/widgets/like_button.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/activity_detail.dart';
import '../../domain/usecases/get_activity_detail.dart';
import '../widgets/activity_author_header.dart';
import '../widgets/activity_share.dart';
import '../../../../core/theme/build_context_extension.dart';

/// Full-page counterpart to [CommentsBottomSheet] — reached by tapping an
/// activity card's main body (cover/title/badge, NOT the comment icon,
/// which still opens the quick-access bottom sheet). Shows the activity at
/// full size plus the complete, inline (not modal) comment thread.
///
/// [activity] is the copy the card already had. It renders straight away so
/// opening a detail never flashes a spinner, while `GET /feed/:activityId`
/// fills in what only that endpoint knows: a session's pauses and the badges it
/// unlocked. Reached without one (a deep link), the page waits for the fetch.
class ActivityDetailPage extends StatefulWidget {
  const ActivityDetailPage({
    super.key,
    required this.activityId,
    this.activity,
  });

  final String activityId;
  final Activity? activity;

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  late final Future<Either<Failure, ActivityDetail>> _detailFuture =
      getIt<GetActivityDetail>().call(widget.activityId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: FutureBuilder<Either<Failure, ActivityDetail>>(
          future: _detailFuture,
          builder: (context, snapshot) {
            final loaded = snapshot.connectionState == ConnectionState.done;
            // A failed fetch is not loud on purpose: with the card's copy in
            // hand there is still a perfectly good page to show, just without
            // the detail. Without one, "not available" is the honest answer.
            final detail = loaded && snapshot.data != null
                ? snapshot.data!.fold((_) => null, (value) => value)
                : null;

            final activity = detail?.activity ?? widget.activity;
            if (activity == null) {
              return loaded
                  ? const _NotAvailable()
                  : const Center(child: CircularProgressIndicator());
            }

            return _ActivityDetailBody(
              activity: activity,
              session: detail?.session,
              badgeImageUrl: detail?.badge?.imageUrl,
            );
          },
        ),
      ),
    );
  }
}

/// Reached when there is nothing to show: no activity came with the tap and the
/// fetch did not produce one either — either the id is gone or the viewer may
/// not see it.
class _NotAvailable extends StatelessWidget {
  const _NotAvailable();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 40,
              color: AppColors.tangerine300,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.activityNotAvailable,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityDetailBody extends StatefulWidget {
  const _ActivityDetailBody({
    required this.activity,
    this.session,
    this.badgeImageUrl,
  });

  final Activity activity;

  /// Present for a reading session once the detail has loaded — the pauses and
  /// the badges it unlocked, neither of which the feed item carries.
  final SessionDetail? session;

  /// A badge unlock's artwork, from the detail. Null until then (and for the
  /// feed's own badge payload, which only snapshots the emoji).
  final String? badgeImageUrl;

  @override
  State<_ActivityDetailBody> createState() => _ActivityDetailBodyState();
}

class _ActivityDetailBodyState extends State<_ActivityDetailBody> {
  late final Future<Either<Failure, List<ActivityComment>>> _commentsFuture =
      getIt<ListComments>().call(widget.activity.id);

  final _controller = TextEditingController();
  final List<ActivityComment> _newComments = [];
  User? _currentUser;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: this only feeds the comment box's own avatar, and
    // nothing on the page blocks on it.
    _loadCurrentUser();
  }

  Future<User?> _loadCurrentUser() async {
    final result = await getIt<GetCurrentUser>().call();
    if (!mounted) return null;
    return result.fold((_) => null, (user) {
      setState(() => _currentUser = user);
      return user;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final result = await getIt<AddComment>().call(
      activityId: widget.activity.id,
      body: body,
    );
    if (!mounted) return;

    result.fold((failure) => context.showFailureSnackBar(failure), (comment) {
      final user = _currentUser;
      final display = user == null
          ? comment
          : ActivityComment(
              id: comment.id,
              userId: comment.userId,
              userName: user.name,
              userAvatarUrl: user.avatarUrl.isEmpty ? null : user.avatarUrl,
              body: comment.body,
              createdAt: comment.createdAt,
            );
      setState(() {
        _newComments.insert(0, display);
        _controller.clear();
      });
    });
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activity = widget.activity;
    // The share card paints the session as *your* reading card, so it belongs
    // to your own posts only. Until the viewer is known this stays false, which
    // hides the button rather than showing it on someone else's activity.
    final isOwner = _currentUser?.id == activity.author.id;
    final canShare = canShareActivity(activity, isOwnActivity: isOwner);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // The post itself, in one card: who posted it, what they read or
              // unlocked, and its like/share row — the same shape as the feed
              // card it was opened from, at full size.
              BorderedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ActivityAuthorHeader(
                      name: activity.author.name,
                      avatarUrl: activity.author.avatarUrl,
                      occurredAt: activity.occurredAt,
                    ),
                    const SizedBox(height: 16),
                    _ActivityHeader(
                      activity: activity,
                      badgeImageUrl: widget.badgeImageUrl,
                    ),
                    if (widget.session != null &&
                        widget.session!.pauses.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Divider(height: 1, color: context.colors.hairline),
                      const SizedBox(height: 12),
                      _PausesBlock(session: widget.session!),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        LikeButton(
                          activityId: activity.id,
                          initialIsLiked: activity.isLiked,
                          initialLikeCount: activity.likeCount,
                        ),
                        // Expanded + Align rather than a Spacer: ChunkyButton
                        // wraps a Flexible label, so it needs a bounded width
                        // — a plain Row child gets an unbounded one.
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            // Badge unlocks have nothing to render as a
                            // reading card, and someone else's session is not
                            // yours to share.
                            child: canShare
                                ? ChunkyButton(
                                    label: l10n.share,
                                    variant: ChunkyButtonVariant.secondary,
                                    icon: Image.asset(
                                      'assets/icons/share-stroke.png',
                                      width: 18,
                                      height: 18,
                                      // Matches the variant's foreground, which
                                      // a bundled PNG can't inherit.
                                      color: context.colors.ink,
                                    ),
                                    onPressed: () =>
                                        shareActivity(context, activity),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (widget.session != null &&
                  widget.session!.badges.isNotEmpty) ...[
                _SessionBadges(badges: widget.session!.badges),
                const SizedBox(height: 24),
              ],
              FutureBuilder<Either<Failure, List<ActivityComment>>>(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return snapshot.data!.fold(
                    (failure) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(failure.localizedMessage(context)),
                      ),
                    ),
                    (fetched) {
                      final comments = [..._newComments, ...fetched];
                      if (comments.isEmpty) return const CommentsEmpty();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final comment in comments)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CommentTile(comment: comment),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l10n.addCommentHint,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: _fieldBorder(context.colors.hairline),
                      enabledBorder: _fieldBorder(context.colors.hairline),
                      focusedBorder: _fieldBorder(
                        AppColors.tangerine,
                        width: 2.5,
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 8),
                _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        onPressed: _submit,
                        icon: const Icon(
                          Icons.send_rounded,
                          color: AppColors.tangerine500,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The chunky input the rest of the app's forms use: a thick rounded border,
/// with focus called out by colour rather than a hairline.
OutlineInputBorder _fieldBorder(Color color, {double width = 2}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: color, width: width),
  );
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({required this.activity, this.badgeImageUrl});

  final Activity activity;

  /// Only the detail endpoint carries a badge's artwork; a feed item snapshots
  /// the emoji alone.
  final String? badgeImageUrl;

  @override
  Widget build(BuildContext context) {
    return switch (activity.payload) {
      final SessionActivityPayload payload => _SessionHeader(payload: payload),
      final BadgeActivityPayload payload => _BadgeHeader(
        payload: payload,
        imageUrl: badgeImageUrl,
      ),
    };
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.payload});

  final SessionActivityPayload payload;

  void _openBookDetail(BuildContext context) {
    final bookId = payload.bookId;
    if (bookId == null || bookId.isEmpty) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => BookDetailPage(bookId: bookId)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navigable = payload.bookId != null && payload.bookId!.isNotEmpty;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            width: 120,
            height: 170,
            child: payload.bookCoverUrl == null
                ? const _CoverPlaceholder()
                : Image.network(
                    payload.bookCoverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _CoverPlaceholder(),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          payload.bookTitle,
          style: AppTypography.heading,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatChip(
              text: formatSessionDuration(
                Duration(seconds: payload.activeDurationSeconds),
              ),
            ),
            _StatChip(text: l10n.pagesCount(payload.pagesRead)),
            _StatChip(
              text: l10n.speedPpmValue(payload.speedPpm.toStringAsFixed(1)),
            ),
          ],
        ),
      ],
    );

    if (!navigable) return content;

    return InkWell(
      onTap: () => _openBookDetail(context),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: content,
    );
  }
}

class _BadgeHeader extends StatelessWidget {
  const _BadgeHeader({required this.payload, this.imageUrl});

  final BadgeActivityPayload payload;

  /// `image_url` from the detail — null while the detail is still loading, and
  /// for the feed payload, which never carries one.
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BadgeArtwork(imageUrl: imageUrl, size: 96),
        const SizedBox(height: 16),
        Text(
          l10n.newBadge,
          style: AppTypography.caption.copyWith(color: context.colors.sunshineAccent),
        ),
        const SizedBox(height: 4),
        Text(
          payload.badgeName,
          style: AppTypography.displaySm,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          payload.badgeDescription,
          style: AppTypography.body,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.hairline,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(text, style: AppTypography.bodyStrong),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.tangerineWash,
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book,
        size: 40,
        color: AppColors.tangerine300,
      ),
    );
  }
}

/// A finished session's timeline: the pause summary, then the stretches the
/// reader actually spent reading — the part a feed item cannot show, because
/// the payload only carries the net reading time.
class _PausesBlock extends StatelessWidget {
  const _PausesBlock({required this.session});

  final SessionDetail session;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final clock = DateFormat.Hm(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.sessionPauses(session.pauseCount),
                style: AppTypography.bodyStrong,
              ),
            ),
            Text(
              l10n.pausedTotal(formatSessionDuration(session.pausedFor)),
              style: AppTypography.caption,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(l10n.readingTime, style: context.captionStyle),
        const SizedBox(height: 4),
        for (final interval in session.readingIntervals)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    // Local time: the timestamps come back in UTC, and the
                    // reader remembers when *their* afternoon was interrupted.
                    '${clock.format(interval.start.toLocal())} – '
                    '${clock.format(interval.end.toLocal())}',
                    style: AppTypography.caption,
                  ),
                ),
                Text(
                  formatSessionDuration(interval.duration),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The badges this session unlocked — they also exist as their own activities,
/// but seeing them on the session that earned them is the point.
class _SessionBadges extends StatelessWidget {
  const _SessionBadges({required this.badges});

  final List<SessionBadge> badges;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.sessionBadgesTitle,
          style: AppTypography.heading,
        ),
        const SizedBox(height: 12),
        for (final badge in badges)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BorderedCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(badge.name, style: AppTypography.subheading),
                        const SizedBox(height: 2),
                        // In full, like every other badge description.
                        Text(
                          badge.description,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  BadgeArtwork(imageUrl: badge.imageUrl, size: 48),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
