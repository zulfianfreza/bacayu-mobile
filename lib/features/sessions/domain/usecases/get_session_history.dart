import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/reading_session.dart';
import '../repositories/session_repository.dart';

@injectable
class GetSessionHistory {
  GetSessionHistory(this._repository);

  final SessionRepository _repository;

  Future<Either<Failure, List<ReadingSession>>> call({int page = 1}) {
    return _repository.getHistory(page: page);
  }
}
