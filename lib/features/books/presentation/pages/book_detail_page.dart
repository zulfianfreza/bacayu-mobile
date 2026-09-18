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
import '../widgets/book_description.dart';

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
  late final Future<Either<Failure, Book>> _future = getIt<GetBookDetail>()
      .call(widget.bookId);

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
    final hasMeta =
        book.totalPages != null ||
        book.publishedDate.isNotEmpty ||
        book.genres.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        // Stretch so the header block can centre itself, while the description
        // still gets the full measure to wrap against.
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          Text(
            book.title,
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          if (book.authors.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l10n.byAuthor(book.authors.join(', ')),
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
          if (hasMeta) ...[
            const SizedBox(height: 16),
            // Facts first, tags after: one reader is scanning for "how long is
            // it", the other for "what kind of book is it", and both find their
            // row without reading the other one.
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (book.totalPages != null)
                  _FactChip(
                    icon: Icons.menu_book_outlined,
                    text: l10n.pagesCount(book.totalPages!),
                  ),
                if (book.publishedDate.isNotEmpty)
                  _FactChip(
                    icon: Icons.calendar_today_outlined,
                    text: book.publishedDate,
                  ),
                for (final genre in book.genres) _GenreChip(text: genre),
              ],
            ),
          ],
          if (book.description != null && book.description!.isNotEmpty) ...[
            const SizedBox(height: 24),
            BookDescription(html: book.description!),
          ],
        ],
      ),
    );
  }
}

/// A fact about this edition — page count, publication year.
class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _Chip(
      icon: icon,
      text: text,
      background: AppColors.line,
      foreground: AppColors.inkSoft,
    );
  }
}

/// A genre tag, tinted apart from the facts on purpose: a genre is a label the
/// reader scans for, not another number about this edition.
class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return _Chip(
      icon: Icons.local_offer_outlined,
      text: text,
      background: AppColors.tangerine50,
      // The 900 shade, not 700: 700 on this tint only reaches 3.9:1, and this
      // is caption-sized type.
      foreground: AppColors.tangerine900,
    );
  }
}

/// Shared pill — an icon and a label, sized to its content.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(text, style: AppTypography.caption.copyWith(color: foreground)),
        ],
      ),
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
      child: const Icon(
        Icons.menu_book,
        size: 40,
        color: AppColors.tangerine300,
      ),
    );
  }
}
