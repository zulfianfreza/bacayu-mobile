import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../cubit/session_timer_cubit.dart';
import '../cubit/session_timer_state.dart';
import '../widgets/book_picker_bottom_sheet.dart';
import 'session_summary_page.dart';

class SessionTimerPage extends StatelessWidget {
  const SessionTimerPage({super.key, this.initialUserBook});

  /// When provided (e.g. the shell FAB already ran the picker), the page
  /// starts the timer immediately instead of showing its own picker.
  final UserBook? initialUserBook;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SessionTimerCubit>(),
      child: _SessionTimerView(initialUserBook: initialUserBook),
    );
  }
}

class _SessionTimerView extends StatefulWidget {
  const _SessionTimerView({this.initialUserBook});

  final UserBook? initialUserBook;

  @override
  State<_SessionTimerView> createState() => _SessionTimerViewState();
}

class _SessionTimerViewState extends State<_SessionTimerView> {
  UserBook? _selectedBook;

  @override
  void initState() {
    super.initState();
    final preselected = widget.initialUserBook;
    if (preselected != null) {
      _selectedBook = preselected;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SessionTimerCubit>().start(userBookId: preselected.id),
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickBook());
    }
  }

  Future<void> _pickBook() async {
    final userBook = await showModalBottomSheet<UserBook>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const BookPickerBottomSheet(),
    );

    if (!mounted) return;

    if (userBook == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _selectedBook = userBook);
    context.read<SessionTimerCubit>().start(userBookId: userBook.id);
  }

  void _onStopped(BuildContext context) {
    final book = _selectedBook!;
    final cubit = context.read<SessionTimerCubit>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: SessionSummaryPage(userBook: book),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = _selectedBook;
    if (book == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      backgroundColor: AppColors.tangerine50,
      body: SafeArea(
        child: BlocConsumer<SessionTimerCubit, SessionTimerState>(
          listener: (context, state) {
            if (state is SessionTimerStopped) _onStopped(context);
          },
          builder: (context, state) {
            final (elapsed, pauseCount, isPaused) = switch (state) {
              SessionTimerRunning(:final elapsed, :final pauseCount) => (
                  elapsed,
                  pauseCount,
                  false,
                ),
              SessionTimerPaused(:final elapsed, :final pauseCount) => (
                  elapsed,
                  pauseCount,
                  true,
                ),
              _ => (Duration.zero, 0, false),
            };

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: SizedBox(
                          width: 40,
                          height: 56,
                          child: book.book.coverUrl == null
                              ? Container(color: AppColors.surface)
                              : Image.network(
                                  book.book.coverUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: AppColors.surface),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          book.book.title,
                          style: AppTypography.subheading,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 240,
                    height: 240,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      formatSessionDuration(elapsed),
                      style: AppTypography.displayLg,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (pauseCount > 0)
                    Text(
                      context.l10n.pausesSoFar(pauseCount),
                      style: AppTypography.caption,
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircularIconButton(
                        icon: isPaused ? Icons.play_arrow : Icons.pause,
                        backgroundColor: AppColors.berry,
                        iconColor: Colors.white,
                        onPressed: () => isPaused
                            ? context.read<SessionTimerCubit>().resume()
                            : context.read<SessionTimerCubit>().pause(),
                      ),
                      const SizedBox(width: 24),
                      _CircularIconButton(
                        icon: Icons.stop,
                        backgroundColor: AppColors.surface,
                        iconColor: AppColors.ink,
                        borderColor: AppColors.slate200,
                        onPressed: () => context.read<SessionTimerCubit>().stop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
    this.borderColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: CircleBorder(
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Icon(icon, color: iconColor, size: 32),
        ),
      ),
    );
  }
}
