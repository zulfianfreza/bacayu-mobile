import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_book.dart';
import '../repositories/shelf_repository.dart';

@injectable
class UpdateShelfStatus {
  UpdateShelfStatus(this._repository);

  final ShelfRepository _repository;

  Future<Either<Failure, UserBook>> call({
    required String userBookId,
    ShelfStatus? status,
    int? currentPage,
    int? rating,
  }) {
    return _repository.updateShelfStatus(
      userBookId: userBookId,
      status: status,
      currentPage: currentPage,
      rating: rating,
    );
  }
}
