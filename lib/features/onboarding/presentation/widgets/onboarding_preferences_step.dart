import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/number_stepper.dart';
import '../../../../core/widgets/raised_box.dart';
import '../../../../l10n/app_localizations.dart';

const _genreSlugs = [
  'fiction',
  'non_fiction',
  'fantasy',
  'romance',
  'self_help',
  'comics',
  'mystery',
  'biography',
  'sci_fi',
  'poetry',
];

String _genreLabel(AppLocalizations l10n, String slug) => switch (slug) {
  'fiction' => l10n.genreFiction,
  'non_fiction' => l10n.genreNonFiction,
  'fantasy' => l10n.genreFantasy,
  'romance' => l10n.genreRomance,
  'self_help' => l10n.genreSelfHelp,
  'comics' => l10n.genreComics,
  'mystery' => l10n.genreMystery,
  'biography' => l10n.genreBiography,
  'sci_fi' => l10n.genreSciFi,
  'poetry' => l10n.genrePoetry,
  _ => slug,
};

class OnboardingPreferencesStep extends StatefulWidget {
  const OnboardingPreferencesStep({
    super.key,
    required this.onSubmit,
    required this.isSaving,
  });

  final void Function(List<String> genres, int yearlyGoal) onSubmit;
  final bool isSaving;

  @override
  State<OnboardingPreferencesStep> createState() =>
      _OnboardingPreferencesStepState();
}

class _OnboardingPreferencesStepState extends State<OnboardingPreferencesStep> {
  final Set<String> _selectedGenres = {};
  int _yearlyGoal = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(l10n.whatDoYouLoveReading, style: AppTypography.displaySm),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final slug in _genreSlugs)
                _GenreChip(
                  label: _genreLabel(l10n, slug),
                  selected: _selectedGenres.contains(slug),
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _selectedGenres.add(slug);
                    } else {
                      _selectedGenres.remove(slug);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 24),
          BorderedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.yearlyReadingGoal, style: AppTypography.subheading),
                const SizedBox(height: 16),
                NumberStepper(
                  value: l10n.booksPerYear(_yearlyGoal),
                  onDecrement: _yearlyGoal > 1
                      ? () => setState(() => _yearlyGoal--)
                      : null,
                  onIncrement: () => setState(() => _yearlyGoal++),
                ),
              ],
            ),
          ),
          const Spacer(),
          ChunkyButton(
            label: l10n.continueLabel,
            onPressed: widget.isSaving
                ? null
                : () => widget.onSubmit(_selectedGenres.toList(), _yearlyGoal),
            isLoading: widget.isSaving,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// One genre: a chunky pill on its own edge, filled in when picked — the same
/// control as the shelf's filter tabs, so a selectable chip looks the same
/// everywhere.
class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: () => onSelected(!selected),
        child: RaisedBox(
          color: selected ? AppColors.tangerine : AppColors.surface,
          radius: AppRadius.pill,
          edgeHeight: 3,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: AppTypography.button.copyWith(
              color: selected ? Colors.white : AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}
