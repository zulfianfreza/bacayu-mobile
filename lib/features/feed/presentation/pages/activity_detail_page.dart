import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/sharing/models/session_share_data.dart';
import '../../../../core/sharing/widgets/share_card_preview_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../books/presentation/pages/book_detail_page.dart';
import '../../../social/domain/entities/activity_comment.dart';
import '../../../social/domain/usecases/add_comment.dart';
import '../../../social/domain/usecases/list_comments.dart';
import '../../../social/presentation/widgets/comment_tile.dart';
import '../../../social/presentation/widgets/like_button.dart';
import '../../domain/entities/activity.dart';
import '../widgets/activity_author_header.dart';

/// Full-page counterpart to [CommentsBottomSheet] — reached by tapping an
/// activity card's main body (cover/title/badge, NOT the comment icon,
/// which still opens the quick-access bottom sheet). Shows the activity at
/// full size plus the complete, inline (not modal) comment thread.
///
/// [activity] is nullable because the `/feed/:activityId` route can in
/// principle be reached without one (a future deep link) — there's no
/// fetch-a-single-activity usecase yet, only the feed list. When null,
/// renders a simple "not available" state instead of guessing.
class ActivityDetailPage extends StatelessWidget {
  const ActivityDetailPage({
    super.key,
    required this.activityId,
    this.activity,
  });

  final String activityId;
  final Activity? activity;

  @override
  Widget build(BuildContext context) {
    final activity = this.activity;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: activity == null
            ? const _NotAvailable()
            : _ActivityDetailBody(activity: activity),
      ),
    );
  }
}

/// Reached without an Activity in memory (a deep link, before there is a
/// fetch-by-id usecase) — says so plainly instead of guessing.
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
  const _ActivityDetailBody({required this.activity});

  final Activity activity;

  @override
  State<_ActivityDetailBody> createState() => _ActivityDetailBodyState();
}

class _ActivityDetailBodyState extends State<_ActivityDetailBody> {
  late final Future<Either<Failure, List<ActivityComment>>> _commentsFuture =
      getIt<ListComments>().call(widget.activity.id);

  final _controller = TextEditingController();
  final List<ActivityComment> _newComments = [];
  User? _currentUser;
  late final Future<User?> _currentUserFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = _loadCurrentUser();
  }

  Future<User?> _loadCurrentUser() async {
    final result = await getIt<GetCurrentUser>().call();
    if (!mounted) return null;
    return result.fold((_) => null, (user) {
      setState(() => _currentUser = user);
      return user;
    });
  }

  /// A past session's streak is already settled, so this reuses the user this
  /// page loaded for the comment box instead of re-fetching — and awaits that
  /// in-flight load rather than risking a `null` badge on a fast tap.
  Future<void> _shareSession(Activity activity) async {
    final payload = activity.payload;
    if (payload is! SessionActivityPayload) return;

    final user = await _currentUserFuture;
    if (!mounted) return;

    final streak = user?.currentStreak;

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
        sessionDate: activity.occurredAt,
        streakDays: streak != null && streak > 0 ? streak : null,
      ),
    );
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
    final canShare = activity.payload is SessionActivityPayload;

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
                    _ActivityHeader(activity: activity),
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
                            // reading card — only sessions can be shared.
                            child: canShare
                                ? ChunkyButton(
                                    label: l10n.share,
                                    variant: ChunkyButtonVariant.secondary,
                                    icon: const Icon(Icons.ios_share, size: 18),
                                    onPressed: () => _shareSession(activity),
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
                      border: _fieldBorder(AppColors.slate200),
                      enabledBorder: _fieldBorder(AppColors.slate200),
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
  const _ActivityHeader({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return switch (activity.payload) {
      final SessionActivityPayload payload => _SessionHeader(payload: payload),
      final BadgeActivityPayload payload => _BadgeHeader(payload: payload),
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
  const _BadgeHeader({required this.payload});

  final BadgeActivityPayload payload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.sunshine500,
          ),
          alignment: Alignment.center,
          child: Text(payload.badgeIcon, style: const TextStyle(fontSize: 48)),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.newBadge,
          style: AppTypography.caption.copyWith(color: AppColors.sunshine700),
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
        color: AppColors.slate200,
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
      color: AppColors.tangerine50,
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book,
        size: 40,
        color: AppColors.tangerine300,
      ),
    );
  }
}
