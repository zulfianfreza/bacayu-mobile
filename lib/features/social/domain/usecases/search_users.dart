import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_search_results.dart';
import '../repositories/social_repository.dart';

/// `GET /social/users/search` — name substring match, excluding the caller.
///
/// The backend rejects a query shorter than 2 characters, so callers should
/// only reach this once there is something worth searching for.
@injectable
class SearchUsers {
  SearchUsers(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, UserSearchResults>> call({
    required String query,
    int page = 1,
  }) {
    return _repository.searchUsers(query: query, page: page);
  }
}
