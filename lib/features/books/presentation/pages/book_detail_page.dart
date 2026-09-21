import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../shelf/domain/entities/book_read.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../../../shelf/domain/usecases/get_book_card.dart';
import '../../../shelf/domain/usecases/get_book_reads.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/get_book_detail.dart';
import '../widgets/book_description.dart';
import '../../../notes/presentation/widgets/notes_section.dart';
import '../../../../core/theme/build_context_extension.dart';

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

  /// Read history is a *shelf* concern, fetched separately from the book itself
  /// and only rendered when there is more than one read to tell.
  late final Future<Either<Failure, List<BookRead>>> _readsFuture =
      getIt<GetBookReads>().call(widget.bookId);

  /// The active shelf entry for this book — the `user_book_id` notes attach
  /// to. 404 (not on the shelf) hides the whole notes section.
  late final Future<Either<Failure, UserBook>> _cardFuture =
      getIt<GetBookCard>().call(widget.bookId);

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
              (failure) => _LoadFailure(failure: failure),
              (book) => _BookDetailBody(
                book: book,
                reads: _readsFuture,
                card: _cardFuture,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The book could not be loaded — an icon and the reason, centred.
class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 40,
              color: AppColors.tangerine300,
            ),
            const SizedBox(height: 12),
            Text(
              failure.localizedMessage(context),
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookDetailBody extends StatelessWidget {
  const _BookDetailBody({
    required this.book,
    required this.reads,
    required this.card,
  });

  final Book book;
  final Future<Either<Failure, List<BookRead>>> reads;
  final Future<Either<Failure, UserBook>> card;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasMeta =
        book.totalPages != null ||
        book.publishedDate.isNotEmpty ||
        book.genres.isNotEmpty;
    final hasDescription =
        book.description != null && book.description!.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // The book's identity in one card: the cover, then everything that
        // names it. Kept apart from the synopsis below, which is prose rather
        // than a label you scan.
        BorderedCard(
          padding: const EdgeInsets.all(20),
          child: Column(
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
              const SizedBox(height: 20),
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
                // Facts first, tags after: one reader is scanning for "how long
                // is it", the other for "what kind of book is it", and both
                // find their row without reading the other one.
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
            ],
          ),
        ),
        if (hasDescription) ...[
          const SizedBox(height: 16),
          BorderedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.bookSynopsis, style: AppTypography.heading),
                const SizedBox(height: 12),
                BookDescription(html: book.description!),
              ],
            ),
          ),
        ],
        _ReadingHistory(future: reads),
        _NotesGate(future: card),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// The caller's read history for this book, from `GET /shelf/books/:id/reads`.
///
/// Renders nothing until it resolves, on failure, or with a single read: a book
/// with one read has no history, and the shelf card already tells that story.
class _ReadingHistory extends StatelessWidget {
  const _ReadingHistory({required this.future});

  final Future<Either<Failure, List<BookRead>>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<Failure, List<BookRead>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final reads = snapshot.data!.fold(
          (_) => const <BookRead>[],
          (reads) => reads,
        );
        if (reads.length < 2) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: BorderedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.readingHistory, style: AppTypography.heading),
                const SizedBox(height: 12),
                for (final read in reads) _ReadRow(read: read),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Notes need a shelf entry to hang off; without one (not on the shelf, or the
/// fetch failed) the section is simply absent.
class _NotesGate extends StatelessWidget {
  const _NotesGate({required this.future});

  final Future<Either<Failure, UserBook>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<Failure, UserBook>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final entry = snapshot.data!.fold((_) => null, (entry) => entry);
        if (entry == null) return const SizedBox.shrink();

        return NotesSection(userBook: entry);
      },
    );
  }
}

/// One read cycle in [_ReadingHistory]: which read it was, when, and the rating
/// if the reader left one.
class _ReadRow extends StatelessWidget {
  const _ReadRow({required this.read});

  final BookRead read;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthYear = DateFormat.yMMMM(locale);
    final started = monthYear.format(
      (read.startedAt ?? read.createdAt).toLocal(),
    );
    final ended = read.finishedAt != null
        ? l10n.readFinishedOn(monthYear.format(read.finishedAt!.toLocal()))
        : l10n.readInProgress;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  read.isReread ? l10n.readReread : l10n.readOriginal,
                  style: AppTypography.bodyStrong,
                ),
                const SizedBox(height: 2),
                Text('$started · $ended', style: context.captionStyle),
              ],
            ),
          ),
          if (read.rating != null) ...[
            const SizedBox(width: 8),
            Text(l10n.ratingStars(read.rating!), style: AppTypography.body),
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
      background: context.colors.hairline,
      foreground: context.colors.textSecondary,
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
      background: context.colors.tangerineWash,
      // The 900 shade, not 700: 700 on this tint only reaches 3.9:1, and this
      // is caption-sized type.
      foreground: context.colors.tangerineAccent,
    );
  }
}

/// Shared pill — an icon and a label, sized to its content.
///
/// The label is [Flexible] rather than a bare `Text`: in a `Row`, a
/// non-flexible child is laid out with unbounded width, so a long genre (Google
/// Books really does send "Foreign Language Study / English as a Second
/// Language") would push the pill past the screen. Flexible lets it wrap to a
/// second line instead.
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // Keeps the glyph on the first line's centre once the label wraps.
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 14, color: foreground),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(color: foreground),
            ),
          ),
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
      color: context.colors.tangerineWash,
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book,
        size: 40,
        color: AppColors.tangerine300,
      ),
    );
  }
}
