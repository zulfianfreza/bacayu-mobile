import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../books/presentation/pages/book_detail_page.dart';
import '../../../social/domain/entities/activity_comment.dart';
import '../../../social/domain/usecases/add_comment.dart';
import '../../../social/domain/usecases/list_comments.dart';
import '../../../social/presentation/widgets/like_button.dart';
import '../../domain/entities/activity.dart';

/// Full-page counterpart to [CommentsBottomSheet] — reached by tapping an
/// activity card's main body (cover/title/badge, NOT the comment icon,
/// which still opens the quick-access bottom sheet). Shows the activity at
/// full size plus the complete, inline (not modal) comment thread.
///
/// [activity] is nullable because the `/feed/:activityId` route can in
/// principle be reached without one (a future deep link) — there's no
/// fetch-a-single-activity usecase yet, only `GetFeed`'s list. When null,
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
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    context.l10n.activityNotAvailable,
                    style: AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _ActivityDetailBody(activity: activity),
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
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final result = await getIt<GetCurrentUser>().call();
    if (!mounted) return;
    result.fold((_) {}, (user) => setState(() => _currentUser = user));
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
    final result = await getIt<AddComment>()
        .call(activityId: widget.activity.id, body: body);
    if (!mounted) return;

    result.fold(
      (failure) => context.showFailureSnackBar(failure),
      (comment) {
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
      },
    );
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activity = widget.activity;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ActivityHeader(activity: activity),
              const SizedBox(height: 12),
              LikeButton(
                activityId: activity.id,
                initialIsLiked: activity.isLiked,
                initialLikeCount: activity.likeCount,
              ),
              const Divider(height: 32, color: AppColors.line),
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
                      if (comments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(l10n.noComments, style: AppTypography.body),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final comment in comments)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _CommentTile(comment: comment),
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
                    decoration: InputDecoration(hintText: l10n.addCommentHint),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 8),
                _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        onPressed: _submit,
                        icon: const Icon(Icons.send, color: AppColors.tangerine500),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookDetailPage(bookId: bookId)),
    );
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
            _StatChip(text: l10n.speedPpmValue(payload.speedPpm.toStringAsFixed(1))),
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
        color: AppColors.line,
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
      child: const Icon(Icons.menu_book, size: 40, color: AppColors.tangerine300),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final ActivityComment comment;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = comment.userAvatarUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.tangerine100,
          backgroundImage: avatarUrl == null || avatarUrl.isEmpty
              ? null
              : NetworkImage(avatarUrl),
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Text(
                  comment.userName.isEmpty ? '?' : comment.userName[0].toUpperCase(),
                  style: AppTypography.caption.copyWith(color: AppColors.tangerine700),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.userName, style: AppTypography.bodyStrong),
              Text(comment.body, style: AppTypography.body),
            ],
          ),
        ),
      ],
    );
  }
}
