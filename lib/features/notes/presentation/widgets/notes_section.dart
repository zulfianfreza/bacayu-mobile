import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/build_context_extension.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../../domain/entities/note.dart';
import '../cubit/notes_cubit.dart';
import '../cubit/notes_state.dart';
import 'note_editor_sheet.dart';

/// The reader's notes on one read, shown in the book-detail page.
///
/// [userBook] is the active shelf entry: notes attach to `user_book_id`, so a
/// reread has its own set. The host page only renders this when the book is on
/// the caller's shelf at all (the backend 404s otherwise).
class NotesSection extends StatelessWidget {
  const NotesSection({super.key, required this.userBook});

  final UserBook userBook;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotesCubit>()..load(userBook.id),
      child: const _NotesView(),
    );
  }
}

class _NotesView extends StatelessWidget {
  const _NotesView();

  Future<void> _openEditor(BuildContext context, {Note? note}) async {
    final cubit = context.read<NotesCubit>();
    final l10n = context.l10n;

    final outcome = await NoteEditorSheet.show(context, note: note);
    if (outcome == null) return;

    final Failure? failure;
    final String message;
    switch (outcome) {
      case NoteSavedOutcome(:final content, :final page, :final quote):
        failure = note == null
            ? await cubit.add(content: content, page: page, quote: quote)
            : await cubit.update(
                noteId: note.id,
                content: content,
                page: page,
                quote: quote,
              );
        message = l10n.noteSaved;
      case NoteDeletedOutcome():
        failure = await cubit.delete(note!.id);
        message = l10n.noteDeleted;
    }

    if (!context.mounted) return;
    if (failure != null) {
      context.showFailureSnackBar(failure);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        // Nothing to say while loading, and a failed fetch stays silent: the
        // shelf entry still has an "add note" affordance below.
        if (state is NotesLoading) return const SizedBox.shrink();

        final notes = state.items;
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: BorderedCard(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.notesTitle, style: AppTypography.heading),
                    ),
                    TextButton.icon(
                      onPressed: () => _openEditor(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.addNote),
                    ),
                  ],
                ),
                if (notes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    child: Text(
                      l10n.notesEmptyBody,
                      style: context.captionStyle,
                    ),
                  )
                else
                  for (var i = 0; i < notes.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: context.colors.hairline),
                    _NoteTile(
                      note: notes[i],
                      onTap: () => _openEditor(context, note: notes[i]),
                    ),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One note row: the quote (when there is one) leads, the note body follows,
/// then page and when it was written.
class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.onTap});

  final Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.quote != null) ...[
              Text(
                note.quote!,
                style: AppTypography.bodyStrong,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Text(
              note.content,
              style: AppTypography.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (note.page != null) ...[
                  Text(
                    l10n.notePageShort(note.page!),
                    style: context.captionStyle,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  formatRelativeTime(
                    l10n: l10n,
                    locale: locale,
                    occurredAt: note.updatedAt,
                  ),
                  style: context.captionStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
