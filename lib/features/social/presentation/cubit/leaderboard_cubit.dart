import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/usecases/get_leaderboard.dart';
import 'leaderboard_state.dart';

@injectable
class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit(this._getLeaderboard)
      : super(const LeaderboardInitial(range: LeaderboardRange.week));

  final GetLeaderboard _getLeaderboard;

  Future<void> load({LeaderboardRange range = LeaderboardRange.week}) async {
    emit(LeaderboardLoading(range: range));
    final result = await _getLeaderboard(range);
    result.fold(
      (failure) => emit(LeaderboardError(failure, range: range)),
      (leaderboard) => emit(LeaderboardLoaded(
        entries: leaderboard.entries,
        currentUser: leaderboard.currentUser,
        range: range,
      )),
    );
  }

  Future<void> changeRange(LeaderboardRange range) => load(range: range);
}
