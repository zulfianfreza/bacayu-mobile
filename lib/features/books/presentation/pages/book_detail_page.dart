import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/get_book_detail.dart';

/// Read-only book detail — reached from a shelf card tap (reuses `books`'
/// `GetBookDetail`) or a search result. Plain `FutureBuilder` + `getIt`, no
/// Cubit — same one-shot-fetch pattern as `BookPickerBottomSheet`.
class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late final Future<Either<Failure, Book>> _future =
      getIt<GetBookDetail>().call(widget.bookId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: FutureBuilder<Either<Failure, Book>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            return snapshot.data!.fold(
              (failure) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    failure.localizedMessage(context),
                    style: AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              (book) => _BookDetailBody(book: book),
            );
          },
        ),
      ),
    );
  }
}

class _BookDetailBody extends StatelessWidget {
  const _BookDetailBody({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                width: 140,
                height: 200,
                child: book.coverUrl == null
                    ? const _CoverPlaceholder()
                    : Image.network(
                        book.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const _CoverPlaceholder(),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(book.title, style: AppTypography.heading),
          if (book.authors.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l10n.byAuthor(book.authors.join(', ')),
              style: AppTypography.body,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (book.totalPages != null)
                _MetaChip(text: l10n.pagesCount(book.totalPages!)),
              if (book.publishedDate.isNotEmpty)
                _MetaChip(text: book.publishedDate),
              for (final genre in book.genres) _MetaChip(text: genre),
            ],
          ),
          if (book.description != null && book.description!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(book.description!, style: AppTypography.body),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(text, style: AppTypography.caption),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.tangerine50,
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book, size: 40, color: AppColors.tangerine300),
    );
  }
}
