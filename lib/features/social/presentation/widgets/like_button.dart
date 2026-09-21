import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../domain/usecases/like_activity.dart';
import '../../domain/usecases/unlike_activity.dart';
import '../../../../core/theme/build_context_extension.dart';

/// Optimistic: the icon/count flip the instant it's tapped, before the
/// network call resolves. Only rolled back if the request actually fails —
/// never waits on the response to feel responsive.
class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.activityId,
    required this.initialIsLiked,
    required this.initialLikeCount,
  });

  final String activityId;
  final bool initialIsLiked;
  final int initialLikeCount;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool _isLiked = widget.initialIsLiked;
  late int _likeCount = widget.initialLikeCount;
  bool _isPending = false;

  Future<void> _toggle() async {
    if (_isPending) return;

    final previousIsLiked = _isLiked;
    final previousCount = _likeCount;
    final willLike = !_isLiked;

    setState(() {
      _isLiked = willLike;
      _likeCount = previousCount + (willLike ? 1 : -1);
      _isPending = true;
    });

    final result = willLike
        ? await getIt<LikeActivity>().call(widget.activityId)
        : await getIt<UnlikeActivity>().call(widget.activityId);

    if (!mounted) return;

    result.fold((failure) {
      setState(() {
        _isLiked = previousIsLiked;
        _likeCount = previousCount;
        _isPending = false;
      });
      context.showFailureSnackBar(failure);
    }, (_) => setState(() => _isPending = false));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              _isLiked
                  ? 'assets/icons/like-solid.png'
                  : 'assets/icons/like-stroke.png',
              width: 24,
              height: 24,
              color: _isLiked ? AppColors.berry : context.colors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text('$_likeCount', style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}
