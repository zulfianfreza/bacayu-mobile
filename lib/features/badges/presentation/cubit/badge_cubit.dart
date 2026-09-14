import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_all_badges.dart';
import 'badge_state.dart';

@injectable
class BadgeCubit extends Cubit<BadgeState> {
  BadgeCubit(this._getAllBadges) : super(const BadgeInitial());

  final GetAllBadges _getAllBadges;

  Future<void> load() async {
    emit(const BadgeLoading());
    final result = await _getAllBadges();
    result.fold(
      (failure) => emit(BadgeError(failure)),
      (badges) => emit(BadgeLoaded(badges)),
    );
  }
}
