import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Auth token storage — deliberately separate from [AppDatabase] (Drift).
/// The token never touches the regular on-device SQLite database.
@lazySingleton
class SecureTokenStorage {
  SecureTokenStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<bool> hasToken() async => (await readToken()) != null;

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
