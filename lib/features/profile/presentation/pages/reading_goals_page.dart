import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/update_profile.dart';

/// Small dedicated page (not a bottom sheet — two independent steppers,
/// matches CLAUDE.md's explicit "halaman kecil" instruction) to edit
/// `yearlyGoalBooks`/`dailyGoalMinutes` — same stepper visual as
/// `OnboardingPreferencesStep`'s yearly goal control.
class ReadingGoalsPage extends StatefulWidget {
  const ReadingGoalsPage({super.key, required this.user});

  final User user;

  @override
  State<ReadingGoalsPage> createState() => _ReadingGoalsPageState();
}

class _ReadingGoalsPageState extends State<ReadingGoalsPage> {
  late int _yearlyGoal = widget.user.yearlyGoalBooks ?? 12;
  late int _dailyGoalMinutes = widget.user.dailyGoalMinutes ?? 20;
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final result = await getIt<UpdateProfile>().call(
      yearlyGoalBooks: _yearlyGoal,
      dailyGoalMinutes: _dailyGoalMinutes,
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _isSaving = false),
      (_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.goalsUpdated)));
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.readingGoals)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(l10n.yearlyReadingGoal, style: AppTypography.subheading),
            const SizedBox(height: 12),
            _Stepper(
              value: _yearlyGoal,
              label: l10n.booksPerYear(_yearlyGoal),
              onDecrement:
                  _yearlyGoal > 1 ? () => setState(() => _yearlyGoal--) : null,
              onIncrement: () => setState(() => _yearlyGoal++),
            ),
            const SizedBox(height: 32),
            Text(l10n.dailyReadingGoal, style: AppTypography.subheading),
            const SizedBox(height: 12),
            _Stepper(
              value: _dailyGoalMinutes,
              label: l10n.minutesPerDay(_dailyGoalMinutes),
              onDecrement: _dailyGoalMinutes > 5
                  ? () => setState(() => _dailyGoalMinutes -= 5)
                  : null,
              onIncrement: () => setState(() => _dailyGoalMinutes += 5),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.save),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.label,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final String label;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.tangerine500,
        ),
        SizedBox(
          width: 140,
          child: Text(label, style: AppTypography.bodyStrong, textAlign: TextAlign.center),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.tangerine500,
        ),
      ],
    );
  }
}
