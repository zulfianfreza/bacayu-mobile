import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../../../shelf/domain/usecases/list_shelf.dart';
import '../../../stats/domain/entities/daily_stat.dart';
import '../../../stats/domain/usecases/get_heatmap.dart';
import 'home_state.dart';

/// Home has no domain/data of its own — presentation-only orchestration
/// over `auth`/`stats`/`shelf` usecases that already exist, same spirit as
/// `onboarding`. The activity list is not one of them: that is the social
/// feed, owned by `FeedCubit`, which Home renders and pages alongside this
/// state. No new backend endpoint for the 7-day strip either — `GetHeatmap`
/// already returns the full year, this just slices the last 7 days.
@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getCurrentUser, this._getHeatmap, this._listShelf)
    : super(const HomeInitial());

  final GetCurrentUser _getCurrentUser;
  final GetHeatmap _getHeatmap;
  final ListShelf _listShelf;

  Future<void> load() async {
    emit(const HomeLoading());

    // All 3 fired together — never awaited one at a time.
    final results = await Future.wait<dynamic>([
      _getCurrentUser(),
      _getHeatmap(DateTime.now().year),
      _listShelf(status: ShelfStatus.reading),
    ]);

    final userResult = results[0] as Either<Failure, User>;
    final heatmapResult = results[1] as Either<Failure, List<DailyStat>>;
    final shelfResult = results[2] as Either<Failure, List<UserBook>>;

    Failure? firstFailure;
    User? user;
    List<DailyStat>? heatmap;
    List<UserBook>? continueReading;

    userResult.fold((f) => firstFailure ??= f, (v) => user = v);
    heatmapResult.fold((f) => firstFailure ??= f, (v) => heatmap = v);
    shelfResult.fold((f) => firstFailure ??= f, (v) => continueReading = v);

    final failure = firstFailure;
    if (failure != null) {
      emit(HomeError(failure));
      return;
    }

    emit(
      HomeLoaded(
        userName: user!.name,
        avatarUrl: user!.avatarUrl,
        currentStreak: user!.currentStreak,
        longestStreak: user!.longestStreak,
        last7Days: _last7Days(heatmap!),
        continueReading: continueReading!,
      ),
    );
  }

  List<DailyStat> _last7Days(List<DailyStat> yearData) {
    final byDate = {
      for (final stat in yearData)
        DateTime(stat.date.year, stat.date.month, stat.date.day): stat,
    };
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return [
      for (var daysAgo = 6; daysAgo >= 0; daysAgo--)
        byDate[todayDate.subtract(Duration(days: daysAgo))] ??
            DailyStat(
              date: todayDate.subtract(Duration(days: daysAgo)),
              totalMinutes: 0,
              totalPages: 0,
              sessionCount: 0,
            ),
    ];
  }
}
