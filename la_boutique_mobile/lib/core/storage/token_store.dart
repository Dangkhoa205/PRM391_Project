import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lưu token trong bộ nhớ an toàn của HĐH (Keychain iOS / EncryptedSharedPreferences Android).
///
/// KHÔNG dùng SharedPreferences trần cho token: refresh token sống 7 ngày, để chỗ app khác
/// đọc được là mất toàn bộ ý nghĩa bảo mật.
class TokenStore {
  TokenStore._();
  static final TokenStore instance = TokenStore._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _kAccess = 'lb_access_token';
  static const String _kRefresh = 'lb_refresh_token';

  Future<String?> get accessToken => _storage.read(key: _kAccess);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);

  Future<bool> get hasSession async => (await refreshToken) != null;

  /// Luôn lưu CẢ HAI token sau mỗi lần login/refresh — refresh token xoay vòng nên phải ghi đè.
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}
