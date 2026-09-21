import 'package:equatable/equatable.dart';

/// A reader's annotation on one shelf entry (one read) — mirrors
/// `NoteResponse` in `api/internal/features/notes/delivery/http/response.go`.
///
/// It hangs off [userBookId], not the book id: notes are per-reading by
/// design, so a reread gets its own notes and book master data stays clean.
class Note extends Equatable {
  const Note({
    required this.id,
    required this.userBookId,
    required this.content,
    required this.page,
    required this.quote,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userBookId;
  final String content;

  /// Page the note refers to, when the reader set one.
  final int? page;

  /// Excerpt the note is about, when the reader set one.
  final String? quote;

  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        userBookId,
        content,
        page,
        quote,
        createdAt,
        updatedAt,
      ];
}
