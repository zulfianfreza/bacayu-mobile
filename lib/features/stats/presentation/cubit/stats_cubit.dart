import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/stats_summary.dart';
import '../../domain/usecases/get_heatmap.dart';
import '../../domain/usecases/get_stats_summary.dart';
import 'stats_state.dart';

/// Plain Cubit — no debounce needed (range changes are discrete taps, not
/// free text), per CLAUDE.md Section 5.2.
@injectable
class StatsCubit extends Cubit<StatsState> {
  StatsCubit(this._getSummary, this._getHeatmap)
      : super(const StatsInitial(range: StatsRange.week));

  final GetStatsSummary _getSummary;
  final GetHeatmap _getHeatmap;

  /// The heatmap is always the full current year regardless of [range] —
  /// only the summary metrics are range-scoped.
  Future<void> load({StatsRange range = StatsRange.week}) async {
    emit(StatsLoading(range: range));

    final summaryFuture = _getSummary(range);
    final heatmapFuture = _getHeatmap(DateTime.now().year);
    final summaryResult = await summaryFuture;
    final heatmapResult = await heatmapFuture;

    summaryResult.fold(
      (failure) => emit(StatsError(failure: failure, range: range)),
      (summary) => heatmapResult.fold(
        (failure) => emit(StatsError(failure: failure, range: range)),
        (heatmap) => emit(
          StatsLoaded(summary: summary, heatmap: heatmap, range: range),
        ),
      ),
    );
  }

  Future<void> changeRange(StatsRange range) => load(range: range);
}
