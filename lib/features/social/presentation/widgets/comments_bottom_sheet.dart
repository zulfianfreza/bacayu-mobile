import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../domain/entities/activity_comment.dart';
import '../../domain/usecases/add_comment.dart';
import '../../domain/usecases/list_comments.dart';
import 'comment_tile.dart';

/// Quick-access comment thread for one activity — opened by the comment icon on
/// an activity card. The full-size counterpart is the inline thread on
/// `ActivityDetailPage`; both render [CommentTile], so a comment looks the same
/// in either place.
class CommentsBottomSheet extends StatefulWidget {
  const CommentsBottomSheet({super.key, required this.activityId});

  final String activityId;

  /// Opens the thread over the whole app — `useRootNavigator` matters here:
  /// inside the shell each tab has its own Navigator, which lives *within* the
  /// shell body, so a sheet pushed on that one would sit above the bottom bar
  /// instead of covering it.
  static Future<void> show(
    BuildContext context, {
    required String activityId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => CommentsBottomSheet(activityId: activityId),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  late final Future<Either<Failure, List<ActivityComment>>> _commentsFuture =
      getIt<ListComments>().call(widget.activityId);

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
    final result = await getIt<AddComment>().call(
      activityId: widget.activityId,
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

    return SafeArea(
      child: Padding(
        // Lifts the whole sheet above the keyboard rather than letting the
        // input sit under it.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.commentsTitle, style: AppTypography.heading),
                ),
              ),
              Expanded(
                child: FutureBuilder<Either<Failure, List<ActivityComment>>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return snapshot.data!.fold(
                      (failure) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            failure.localizedMessage(context),
                            style: AppTypography.body,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      (fetched) {
                        final comments = [..._newComments, ...fetched];
                        if (comments.isEmpty) {
                          return const Center(child: CommentsEmpty());
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: comments.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              CommentTile(comment: comments[index]),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
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
            ],
          ),
        ),
      ),
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
