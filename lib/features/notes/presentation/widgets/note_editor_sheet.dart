import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/build_context_extension.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/sheet_header.dart';
import '../../domain/entities/note.dart';

/// What the editor was closed with. `null` from [NoteEditorSheet.show] means
/// the reader dismissed it — nothing to write.
sealed class NoteEditorOutcome {
  const NoteEditorOutcome();
}

class NoteSavedOutcome extends NoteEditorOutcome {
  const NoteSavedOutcome({required this.content, this.page, this.quote});

  final String content;
  final int? page;
  final String? quote;
}

class NoteDeletedOutcome extends NoteEditorOutcome {
  const NoteDeletedOutcome();
}

/// Add/edit sheet for one note: the body (required), an optional page number
/// and an optional quote.
///
/// It only collects — the caller does the write, so `CreateNote`/`UpdateNote`
/// stay out of the sheet. Deleting lives here too because it is the same
/// "act on this one note" surface; it asks for confirmation before popping.
class NoteEditorSheet extends StatefulWidget {
  const NoteEditorSheet({super.key, this.note});

  /// `null` creates a new note on the read the caller passes on save.
  final Note? note;

  static Future<NoteEditorOutcome?> show(
    BuildContext context, {
    Note? note,
  }) {
    return showModalBottomSheet<NoteEditorOutcome>(
      context: context,
      useRootNavigator: true,
      // The keyboard and a multi-line body both need the sheet to grow.
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => NoteEditorSheet(note: note),
    );
  }

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late final _content = TextEditingController(text: widget.note?.content ?? '');
  late final _page = TextEditingController(
    text: widget.note?.page?.toString() ?? '',
  );
  late final _quote = TextEditingController(text: widget.note?.quote ?? '');

  @override
  void dispose() {
    _content.dispose();
    _page.dispose();
    _quote.dispose();
    super.dispose();
  }

  /// Empty page is fine (no page); a non-numeric one is a typo, not a silent
  /// drop.
  bool get _pageIsValid {
    final text = _page.text.trim();
    return text.isEmpty || int.tryParse(text) != null;
  }

  bool get _canSave => _content.text.trim().isNotEmpty && _pageIsValid;

  void _save() {
    final page = _page.text.trim();
    final quote = _quote.text.trim();
    Navigator.of(context).pop(
      NoteSavedOutcome(
        content: _content.text.trim(),
        // `null` means "leave unchanged" on the backend, so clearing a page
        // (or quote) can't erase it in v1 — it only stops updating it. Sending
        // the parsed value when present is the best the API allows.
        page: page.isEmpty ? null : int.parse(page),
        quote: quote.isEmpty ? null : quote,
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteNoteConfirmTitle),
        content: Text(l10n.deleteNoteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteNote),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const NoteDeletedOutcome());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditing = widget.note != null;

    return Padding(
      // Lift the sheet above the keyboard instead of letting it cover the
      // fields being typed into.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetHeader(
                title:
                    isEditing ? l10n.noteEditorTitleEdit : l10n.noteEditorTitleAdd,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _content,
                autofocus: !isEditing,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.noteContentLabel),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _page,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.notePageLabel,
                  errorText: _pageIsValid ? null : l10n.notePageInvalid,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _quote,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.noteQuoteLabel),
              ),
              const SizedBox(height: 20),
              ChunkyButton(
                label: l10n.save,
                onPressed: _canSave ? _save : null,
              ),
              if (isEditing) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _confirmDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.berry,
                  ),
                  child: Text(l10n.deleteNote),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
