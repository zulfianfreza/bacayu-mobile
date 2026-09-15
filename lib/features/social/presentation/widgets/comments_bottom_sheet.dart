import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../domain/entities/activity_comment.dart';
import '../../domain/usecases/add_comment.dart';
import '../../domain/usecases/list_comments.dart';

class CommentsBottomSheet extends StatefulWidget {
  const CommentsBottomSheet({super.key, required this.activityId});

  final String activityId;

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
    final result =
        await getIt<AddComment>().call(activityId: widget.activityId, body: body);
    if (!mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.localizedMessage(context))),
      ),
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

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<Either<Failure, List<ActivityComment>>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return snapshot.data!.fold(
                      (failure) => Center(
                        child: Text(failure.localizedMessage(context)),
                      ),
                      (fetched) {
                        final comments = [..._newComments, ...fetched];
                        if (comments.isEmpty) {
                          return Center(
                            child: Text(l10n.noComments, style: AppTypography.body),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: comments.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _CommentTile(comment: comments[index]),
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
            ],
          ),
        ),
      ),
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
