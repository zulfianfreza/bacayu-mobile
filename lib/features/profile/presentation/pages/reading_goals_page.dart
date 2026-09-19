import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/number_stepper.dart';
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
    result.fold((failure) => setState(() => _isSaving = false), (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.goalsUpdated)));
      Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.readingGoals)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _GoalCard(
                title: l10n.yearlyReadingGoal,
                value: l10n.booksPerYear(_yearlyGoal),
                onDecrement: _yearlyGoal > 1
                    ? () => setState(() => _yearlyGoal--)
                    : null,
                onIncrement: () => setState(() => _yearlyGoal++),
              ),
              const SizedBox(height: 16),
              _GoalCard(
                title: l10n.dailyReadingGoal,
                value: l10n.minutesPerDay(_dailyGoalMinutes),
                onDecrement: _dailyGoalMinutes > 5
                    ? () => setState(() => _dailyGoalMinutes -= 5)
                    : null,
                onIncrement: () => setState(() => _dailyGoalMinutes += 5),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: l10n.save,
                  onPressed: _isSaving ? null : _save,
                  isLoading: _isSaving,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// One goal: its name, and a chunky minus/value/plus row that reads as a
/// single physical control rather than three loose widgets.
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String title;
  final String value;

  /// Null at the goal's floor — the minus tile goes flat instead of
  /// disappearing, so the row keeps its shape as the value changes.
  final VoidCallback? onDecrement;

  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return BorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.subheading),
          const SizedBox(height: 16),
          NumberStepper(
            value: value,
            onDecrement: onDecrement,
            onIncrement: onIncrement,
          ),
        ],
      ),
    );
  }
}
