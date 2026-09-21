import '../../domain/entities/book_read.dart';
import 'user_book_model.dart';

/// Mirrors `ReadResponse` in
/// `api/internal/features/shelf/delivery/http/response.go`.
class BookReadModel extends BookRead {
  const BookReadModel({
    required super.id,
    required super.status,
    required super.currentPage,
    required super.rating,
    required super.isReread,
    required super.startedAt,
    required super.finishedAt,
    required super.createdAt,
  });

  factory BookReadModel.fromJson(Map<String, dynamic> json) {
    return BookReadModel(
      id: json['id'] as String,
      status: ShelfStatusWire.fromWire(json['status'] as String),
      currentPage: json['current_page'] as int? ?? 0,
      rating: json['rating'] as int?,
      isReread: json['is_reread'] as bool? ?? false,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      finishedAt: json['finished_at'] == null
          ? null
          : DateTime.parse(json['finished_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
