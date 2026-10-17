/// Cấu hình tập trung các thông tin có thể thay đổi theo môi trường/shop.
///
/// KHÔNG hardcode rải rác trong widget. Mỗi giá trị đọc qua [String.fromEnvironment]
/// nên có thể override lúc build mà không sửa code, ví dụ:
///
/// ```
/// flutter run --dart-define=SUPPORT_HOTLINE=19001234 \
///             --dart-define=SUPPORT_ZALO_URL=https://zalo.me/0987654321
/// ```
///
/// Nếu không truyền gì thì dùng giá trị mặc định bên dưới (placeholder của dev).
class AppConfig {
  AppConfig._();

  /// Số hotline CSKH (dùng cho nút "Gọi hotline" -> tel:).
  static const String supportHotline = String.fromEnvironment(
    'SUPPORT_HOTLINE',
    defaultValue: '0901234567',
  );

  /// Link Zalo CSKH (dùng cho nút "Chat Zalo").
  static const String supportZaloUrl = String.fromEnvironment(
    'SUPPORT_ZALO_URL',
    defaultValue: 'https://zalo.me/0901234567',
  );

  /// Web client ID của Google — PHẢI trùng GOOGLE_CLIENT_ID của backend (dùng cho đăng nhập Google).
  /// Lấy từ backend và truyền lúc build: --dart-define=GOOGLE_CLIENT_ID=xxxx.apps.googleusercontent.com
  /// Rỗng = chưa cấu hình (ẩn nút đăng nhập Google).
  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID');

  static bool get isGoogleConfigured => googleServerClientId.isNotEmpty;
}
