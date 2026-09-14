import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw Dio calls only — no error mapping, no token storage. Throws
/// [DioException] on failure; the repository is the only layer that catches
/// it (via `dioExceptionToEither`).
@injectable
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// POST /auth/register — returns the created user. NOTE: unlike login,
  /// the backend does NOT return an access token here (see
  /// `api/internal/features/auth/delivery/http/handler.go`), only the user.
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'email': email, 'password': password, 'name': name},
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// POST /auth/login — returns `{access_token, user}`.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// GET /users/me — returns the current user.
  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/users/me');
    return response.data!['data'] as Map<String, dynamic>;
  }
}
