import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/notes/domain/entities/note.dart';
import 'package:mobile/features/notes/domain/repositories/note_repository.dart';
import 'package:mobile/features/notes/domain/usecases/create_note.dart';
import 'package:mobile/features/notes/domain/usecases/delete_note.dart';
import 'package:mobile/features/notes/domain/usecases/list_notes.dart';
import 'package:mobile/features/notes/domain/usecases/update_note.dart';
import 'package:mobile/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:mobile/features/notes/presentation/cubit/notes_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockNoteRepository extends Mock implements NoteRepository {}

Note _note({String id = 'n-1', String content = 'Remember this'}) => Note(
  id: id,
  userBookId: 'ub-1',
  content: content,
  page: null,
  quote: null,
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

void main() {
  late _MockNoteRepository repository;
  late NotesCubit cubit;

  setUp(() {
    repository = _MockNoteRepository();
    cubit = NotesCubit(
      ListNotes(repository),
      CreateNote(repository),
      UpdateNote(repository),
      DeleteNote(repository),
    );
  });

  test('load lists the active read\'s notes', () async {
    when(
      () => repository.listNotes(userBookId: 'ub-1', page: 1),
    ).thenAnswer((_) async => Right([_note()]));

    await cubit.load('ub-1');

    final state = cubit.state;
    expect(state, isA<NotesLoaded>());
    expect((state as NotesLoaded).items.single.id, 'n-1');
  });

  test('a failed load emits NotesError so the section can stay quiet', () async {
    when(() => repository.listNotes(userBookId: 'ub-1', page: 1)).thenAnswer(
      (_) async => const Left(ServerFailure(code: 'X', message: 'boom')),
    );

    await cubit.load('ub-1');

    expect(cubit.state, isA<NotesError>());
  });

  test('add writes then re-fetches the list', () async {
    when(
      () => repository.listNotes(userBookId: 'ub-1', page: 1),
    ).thenAnswer((_) async => Right([_note(id: 'n-2', content: 'baru')]));
    when(
      () => repository.createNote(
        userBookId: 'ub-1',
        content: 'baru',
        page: null,
        quote: null,
      ),
    ).thenAnswer((_) async => Right(_note(id: 'n-2', content: 'baru')));

    await cubit.load('ub-1');
    final failure = await cubit.add(content: 'baru');

    expect(failure, isNull);
    expect((cubit.state as NotesLoaded).items.single.id, 'n-2');
    verify(
      () => repository.listNotes(userBookId: 'ub-1', page: 1),
    ).called(2);
  });

  test('a failed add returns the failure and keeps the list on screen', () async {
    when(
      () => repository.listNotes(userBookId: 'ub-1', page: 1),
    ).thenAnswer((_) async => Right([_note()]));
    when(
      () => repository.createNote(
        userBookId: 'ub-1',
        content: 'baru',
        page: null,
        quote: null,
      ),
    ).thenAnswer(
      (_) async => const Left(ServerFailure(code: 'X', message: 'boom')),
    );

    await cubit.load('ub-1');
    final failure = await cubit.add(content: 'baru');

    expect(failure, isA<ServerFailure>());
    expect((cubit.state as NotesLoaded).items.single.id, 'n-1');
  });

  test('update patches then re-fetches the list', () async {
    when(
      () => repository.listNotes(userBookId: 'ub-1', page: 1),
    ).thenAnswer((_) async => Right([_note(content: 'Edited')]));
    when(
      () => repository.updateNote(
        noteId: 'n-1',
        content: 'Edited',
        page: null,
        quote: null,
      ),
    ).thenAnswer((_) async => Right(_note(content: 'Edited')));

    await cubit.load('ub-1');
    final failure = await cubit.update(noteId: 'n-1', content: 'Edited');

    expect(failure, isNull);
    expect((cubit.state as NotesLoaded).items.single.content, 'Edited');
  });

  test('delete removes then re-fetches the list', () async {
    when(
      () => repository.listNotes(userBookId: 'ub-1', page: 1),
    ).thenAnswer((_) async => Right([_note()]));
    when(() => repository.deleteNote('n-1')).thenAnswer((_) async => Right(null));

    await cubit.load('ub-1');
    final failure = await cubit.delete('n-1');

    expect(failure, isNull);
    verify(() => repository.deleteNote('n-1')).called(1);
    verify(
      () => repository.listNotes(userBookId: 'ub-1', page: 1),
    ).called(2);
  });
}
