import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/notes/data/datasources/note_remote_datasource.dart';
import 'package:mobile/features/notes/data/repositories/note_repository_impl.dart';
import 'package:mobile/features/notes/domain/entities/note.dart';
import 'package:mocktail/mocktail.dart';

class _MockNoteRemote extends Mock implements NoteRemoteDataSource {}

Map<String, dynamic> _noteJson({
  String id = 'n-1',
  int? page = 3,
  String? quote = 'A line worth keeping',
}) => {
  'id': id,
  'user_id': 'u1',
  'user_book_id': 'ub-1',
  'content': 'Remember this',
  'page': page,
  'quote': quote,
  'created_at': '2026-09-01T00:00:00Z',
  'updated_at': '2026-09-01T00:00:00Z',
};

void main() {
  late _MockNoteRemote remote;
  late NoteRepositoryImpl repository;

  setUp(() {
    remote = _MockNoteRemote();
    repository = NoteRepositoryImpl(remote);
  });

  test('listNotes maps the envelope and keeps the page scope', () async {
    when(
      () => remote.listNotes(userBookId: 'ub-1', page: 1),
    ).thenAnswer((_) async => [_noteJson()]);

    final result = await repository.listNotes(userBookId: 'ub-1');

    final notes = result.getOrElse(() => fail('expected notes'));
    expect(notes, hasLength(1));
    expect(notes.single.userBookId, 'ub-1');
    expect(notes.single.content, 'Remember this');
    expect(notes.single.page, 3);
    expect(notes.single.quote, 'A line worth keeping');
    expect(notes.single.createdAt, DateTime.utc(2026, 9, 1));
    verify(() => remote.listNotes(userBookId: 'ub-1', page: 1)).called(1);
  });

  test('createNote parses the created note', () async {
    when(
      () => remote.createNote(
        userBookId: 'ub-1',
        content: 'Remember this',
        page: 3,
        quote: 'A line worth keeping',
      ),
    ).thenAnswer((_) async => _noteJson());

    final result = await repository.createNote(
      userBookId: 'ub-1',
      content: 'Remember this',
      page: 3,
      quote: 'A line worth keeping',
    );

    expect(result.getOrElse(() => fail('expected a note')).id, 'n-1');
  });

  test('createNote keeps page and quote empty when the reader left them', () async {
    when(
      () => remote.createNote(
        userBookId: 'ub-1',
        content: 'Just a thought',
        page: null,
        quote: null,
      ),
    ).thenAnswer((_) async => _noteJson(page: null, quote: null));

    final result = await repository.createNote(
      userBookId: 'ub-1',
      content: 'Just a thought',
    );

    final note = result.getOrElse(() => fail('expected a note'));
    expect(note.page, isNull);
    expect(note.quote, isNull);
  });

  test('updateNote parses the patched note', () async {
    when(
      () => remote.updateNote(
        noteId: 'n-1',
        content: 'Edited',
        page: null,
        quote: null,
      ),
    ).thenAnswer((_) async => _noteJson()..['content'] = 'Edited');

    final result = await repository.updateNote(noteId: 'n-1', content: 'Edited');

    expect(result.getOrElse(() => fail('expected a note')).content, 'Edited');
  });

  test('deleteNote succeeds with an empty response', () async {
    when(() => remote.deleteNote('n-1')).thenAnswer((_) async {});

    final result = await repository.deleteNote('n-1');

    expect(result.isRight(), isTrue);
  });

  test('a network error becomes a failure, not an exception', () async {
    when(() => remote.listNotes(userBookId: 'ub-1', page: 1)).thenAnswer(
      (_) async => throw DioException(
        requestOptions: RequestOptions(path: '/notes'),
        type: DioExceptionType.connectionError,
      ),
    );

    final result = await repository.listNotes(userBookId: 'ub-1');

    expect(result, isA<Left<Failure, List<Note>>>());
  });
}
