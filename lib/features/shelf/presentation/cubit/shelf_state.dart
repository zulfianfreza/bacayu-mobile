import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/user_book.dart';

sealed class ShelfState extends Equatable {
  const ShelfState({required this.activeFilter});

  /// `null` means the "All" tab.
  final ShelfStatus? activeFilter;

  List<UserBook> get items => const [];

  @override
  List<Object?> get props => [activeFilter];
}

class ShelfInitial extends ShelfState {
  const ShelfInitial({super.activeFilter});
}

class ShelfLoading extends ShelfState {
  const ShelfLoading({super.activeFilter});
}

class ShelfLoaded extends ShelfState {
  const ShelfLoaded({required this.items, super.activeFilter});

  @override
  final List<UserBook> items;

  @override
  List<Object?> get props => [activeFilter, items];
}

class ShelfError extends ShelfState {
  const ShelfError({required this.failure, super.activeFilter});

  final Failure failure;

  @override
  List<Object?> get props => [activeFilter, failure];
}

/// A single `updateShelfStatus` call failed — [items] is the untouched list
/// from before the attempt, so the UI doesn't lose the whole shelf over one
/// failed update.
class ShelfUpdateError extends ShelfState {
  const ShelfUpdateError({
    required this.items,
    required this.failure,
    super.activeFilter,
  });

  @override
  final List<UserBook> items;
  final Failure failure;

  @override
  List<Object?> get props => [activeFilter, items, failure];
}
