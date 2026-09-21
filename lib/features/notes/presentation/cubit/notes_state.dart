import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/note.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  List<Note> get items => const [];

  @override
  List<Object?> get props => [];
}

class NotesLoading extends NotesState {
  const NotesLoading();
}

class NotesLoaded extends NotesState {
  const NotesLoaded({required this.items});

  @override
  final List<Note> items;

  @override
  List<Object?> get props => [items];
}

/// The list could not be fetched. The section stays empty rather than showing a
/// broken card — a book with no readable notes looks the same as a book with
/// none, and the reader is not blocked from reading.
class NotesError extends NotesState {
  const NotesError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
