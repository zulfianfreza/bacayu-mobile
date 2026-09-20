import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../../core/widgets/sheet_header.dart';
import '../../domain/entities/book_input.dart';
import '../../domain/usecases/add_manual_book.dart';

/// Bottom sheet for books not found via Google Books. Only adds the book
/// (`AddManualBook`) and pops with it — same boundary as `BookSearchBloc`:
/// this widget doesn't add-to-shelf itself, the caller does.
class AddManualBookSheet extends StatefulWidget {
  const AddManualBookSheet({super.key});

  @override
  State<AddManualBookSheet> createState() => _AddManualBookSheetState();
}

class _AddManualBookSheetState extends State<AddManualBookSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorsController = TextEditingController();
  final _pagesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorsController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final input = BookInput(
      title: _titleController.text.trim(),
      authors: _authorsController.text.trim().isEmpty
          ? const []
          : _authorsController.text
              .split(',')
              .map((a) => a.trim())
              .where((a) => a.isNotEmpty)
              .toList(),
      totalPages: int.tryParse(_pagesController.text.trim()),
      genres: const [],
      language: '',
      coverUrl: null,
      description: null,
      publishedDate: '',
    );

    final result = await getIt<AddManualBook>().call(input);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => context.showFailureSnackBar(failure),
      (book) => Navigator.of(context).pop(book),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetHeader(title: l10n.addManually),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.bookTitle),
                validator: (value) =>
                    (value == null || value.isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorsController,
                decoration: InputDecoration(labelText: l10n.bookAuthors),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pagesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.bookTotalPages),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
