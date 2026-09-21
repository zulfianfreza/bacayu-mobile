import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_remote_datasource.dart';
import '../models/note_model.dart';

@LazySingleton(as: NoteRepository)
class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl(this._remote);

  final NoteRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Note>>> listNotes({
    String? userBookId,
    int page = 1,
  }) async {
    try {
      final items = await _remote.listNotes(userBookId: userBookId, page: page);
      return Right(
        items.cast<Map<String, dynamic>>().map(NoteModel.fromJson).toList(),
      );
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, Note>> createNote({
    required String userBookId,
    required String content,
    int? page,
    String? quote,
  }) async {
    try {
      final json = await _remote.createNote(
        userBookId: userBookId,
        content: content,
        page: page,
        quote: quote,
      );
      return Right(NoteModel.fromJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, Note>> updateNote({
    required String noteId,
    required String content,
    int? page,
    String? quote,
  }) async {
    try {
      final json = await _remote.updateNote(
        noteId: noteId,
        content: content,
        page: page,
        quote: quote,
      );
      return Right(NoteModel.fromJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      await _remote.deleteNote(noteId);
      return const Right(null);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }
}
