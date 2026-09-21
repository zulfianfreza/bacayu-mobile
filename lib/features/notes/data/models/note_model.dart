import '../../domain/entities/note.dart';

/// Mirrors `NoteResponse` in
/// `api/internal/features/notes/delivery/http/response.go`.
class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.userBookId,
    required super.content,
    required super.page,
    required super.quote,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      userBookId: json['user_book_id'] as String,
      content: json['content'] as String,
      page: json['page'] as int?,
      quote: json['quote'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
