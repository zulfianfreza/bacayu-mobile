import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/book.dart';
import '../entities/book_input.dart';
import '../repositories/book_repository.dart';

@injectable
class AddManualBook {
  AddManualBook(this._repository);

  final BookRepository _repository;

  Future<Either<Failure, Book>> call(BookInput input) =>
      _repository.addManual(input);
}
