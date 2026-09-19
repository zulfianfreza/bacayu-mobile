import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../badges/presentation/widgets/badge_unlocked_modal.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../../domain/entities/unlocked_badge.dart';
import '../cubit/manual_session_cubit.dart';
import '../cubit/manual_session_state.dart';
import '../widgets/session_book_header.dart';

/// Log a session by hand: which day, how long, and which pages. No clock time —
/// people don't remember when they started (the cubit derives it).
class ManualSessionPage extends StatelessWidget {
  const ManualSessionPage({super.key, required this.userBook});

  final UserBook userBook;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ManualSessionCubit>(),
      child: _ManualSessionView(userBook: userBook),
    );
  }
}

class _ManualSessionView extends StatefulWidget {
  const _ManualSessionView({required this.userBook});

  final UserBook userBook;

  @override
  State<_ManualSessionView> createState() => _ManualSessionViewState();
}

class _ManualSessionViewState extends State<_ManualSessionView> {
  final _formKey = GlobalKey<FormState>();
  late final _startPageController = TextEditingController(
    text: widget.userBook.currentPage.toString(),
  );
  final _endPageController = TextEditingController();
  final _durationController = TextEditingController();

  late DateTime _date = _today();

  /// The submit is offline-first, so the page leaves as soon as the local save
  /// lands — this only stops a late state emission popping it twice.
  bool _left = false;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _startPageController.dispose();
    _endPageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      // Backfilling older than this is not worth scrolling through; and a
      // session can't have happened tomorrow.
      firstDate: DateTime(_date.year - 5),
      lastDate: _today(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ManualSessionCubit>().submit(
      userBookId: widget.userBook.id,
      date: _date,
      durationMinutes: int.parse(_durationController.text.trim()),
      startPage: int.parse(_startPageController.text.trim()),
      endPage: int.parse(_endPageController.text.trim()),
      onBadges: _celebrateBadges,
    );
  }

  void _leave(BuildContext context) {
    if (_left) return;
    _left = true;
    Navigator.of(context).pop();
  }

  /// Celebrates on the ROOT navigator, not this page's: the badges come back
  /// from the best-effort remote send, which normally lands after this page has
  /// already popped (the local save is what closes it).
  Future<void> _celebrateBadges(List<UnlockedBadge> badges) async {
    final rootContext = getIt<GlobalKey<NavigatorState>>().currentContext;
    if (rootContext == null) return;

    for (final badge in badges) {
      if (!rootContext.mounted) return;
      await BadgeUnlockedModal.show(
        rootContext,
        name: badge.name,
        icon: badge.icon,
        description: badge.description,
      );
    }
  }

  String? _validateDuration(String? value) {
    final minutes = int.tryParse(value?.trim() ?? '');
    if (minutes == null || minutes <= 0) return context.l10n.invalidDuration;
    return null;
  }

  String? _validatePage(String? value) {
    final page = int.tryParse(value?.trim() ?? '');
    if (page == null || page < 0) return context.l10n.fieldRequired;
    return null;
  }

  /// The backend rejects an empty range (`end_page <= start_page`), so this is
  /// the same rule, just earlier.
  String? _validateEndPage(String? value) {
    final end = int.tryParse(value?.trim() ?? '');
    final start = int.tryParse(_startPageController.text.trim());
    if (end == null || start == null || end <= start) {
      return context.l10n.invalidPageRange;
    }
    return null;
  }

  String _dateLabel(BuildContext context) {
    if (_date == _today()) return context.l10n.todayLabel;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).format(_date);
  }

  OutlineInputBorder _border(Color color, {double width = 2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  InputDecoration _decoration(String label, {String? suffix}) {
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: _border(AppColors.slate200),
      enabledBorder: _border(AppColors.slate200),
      focusedBorder: _border(AppColors.tangerine, width: 2.5),
      errorBorder: _border(AppColors.danger),
      focusedErrorBorder: _border(AppColors.danger, width: 2.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manualSessionTitle)),
      body: SafeArea(
        child: BlocConsumer<ManualSessionCubit, ManualSessionState>(
          listener: (context, state) {
            switch (state) {
              case ManualSessionSubmitted():
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.sessionSaved)));
                _leave(context);
              case ManualSessionError(:final failure):
                context.showFailureSnackBar(failure);
              case ManualSessionIdle() || ManualSessionSubmitting():
                break;
            }
          },
          builder: (context, state) {
            final isSubmitting = state is ManualSessionSubmitting;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SessionBookHeader(userBook: widget.userBook),
                  const SizedBox(height: 20),
                  _DateField(
                    label: l10n.dateLabel,
                    value: _dateLabel(context),
                    onTap: isSubmitting ? null : _pickDate,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _durationController,
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.number,
                    validator: _validateDuration,
                    decoration: _decoration(
                      l10n.durationLabel,
                      suffix: l10n.minutesShort,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _startPageController,
                          enabled: !isSubmitting,
                          keyboardType: TextInputType.number,
                          validator: _validatePage,
                          decoration: _decoration(l10n.startPage),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _endPageController,
                          enabled: !isSubmitting,
                          keyboardType: TextInputType.number,
                          validator: _validateEndPage,
                          decoration: _decoration(l10n.endPage),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ChunkyButton(
                    label: l10n.saveSession,
                    onPressed: isSubmitting ? null : _submit,
                    isLoading: isSubmitting,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The day being logged, as a row you tap rather than a picker inline.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BorderedCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.inkFaint,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTypography.bodyStrong)),
            Text(
              value,
              style: AppTypography.bodyStrong.copyWith(
                color: AppColors.tangerine700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.inkFaint,
            ),
          ],
        ),
      ),
    );
  }
}
