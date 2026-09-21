import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user_book.dart';
import '../../domain/usecases/list_shelf.dart';
import '../../domain/usecases/start_reread.dart';
import '../../domain/usecases/update_shelf_status.dart';
import 'shelf_state.dart';

/// Plain Cubit — no debounce/event complexity needed here (contrast with
/// `BookSearchBloc`), per CLAUDE.md Section 5.2.
@injectable
class ShelfCubit extends Cubit<ShelfState> {
  ShelfCubit(this._listShelf, this._updateShelfStatus, this._startReread)
    : super(const ShelfInitial());

  final ListShelf _listShelf;
  final UpdateShelfStatus _updateShelfStatus;
  final StartReread _startReread;

  Future<void> loadShelf({ShelfStatus? filter}) async {
    emit(ShelfLoading(activeFilter: filter));
    final result = await _listShelf(status: filter);
    result.fold(
      (failure) => emit(ShelfError(failure: failure, activeFilter: filter)),
      (items) => emit(ShelfLoaded(items: items, activeFilter: filter)),
    );
  }

  /// Re-fetches with the new filter — CATATAN UX doesn't apply here (this
  /// is just a query param, no badge expectations involved).
  Future<void> changeFilter(ShelfStatus? filter) => loadShelf(filter: filter);

  /// Patches the single updated entry into the current list in place —
  /// no refetch of the whole shelf. NOTE: even when [status] is `finished`,
  /// the response never carries `badges_unlocked` (that's sessions-only,
  /// see CLAUDE.md Section 6/backend Section 8.4) — don't wait for one.
  Future<void> updateStatus({
    required String userBookId,
    required ShelfStatus status,
  }) async {
    final filter = state.activeFilter;
    final items = state.items;

    final result = await _updateShelfStatus(
      userBookId: userBookId,
      status: status,
    );
    result.fold(
      (failure) => emit(
        ShelfUpdateError(items: items, failure: failure, activeFilter: filter),
      ),
      (updated) {
        final next = [
          for (final item in items)
            if (item.id == updated.id)
              // The write response is flat and has no read_count; keep the one
              // the list gave us, or the reread badge would vanish on any
              // status change.
              updated.copyWith(readCount: item.readCount)
            else
              item,
        ];
        emit(ShelfLoaded(items: next, activeFilter: filter));
      },
    );
  }

  /// Starts a reread and refreshes the shelf: the book's representative card
  /// changes row (new `is_reread` entry, status `reading`, page 0), so patching
  /// in place is not enough — the whole page is re-fetched.
  Future<void> startReread({required String bookId}) async {
    final filter = state.activeFilter;
    final items = state.items;

    final result = await _startReread(bookId);
    await result.fold(
      (failure) async => emit(
        ShelfUpdateError(items: items, failure: failure, activeFilter: filter),
      ),
      (_) async => loadShelf(filter: filter),
    );
  }
}
