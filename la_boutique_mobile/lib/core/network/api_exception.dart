/// Lỗi API đã được chuẩn hoá để lớp UI/Provider xử lý thống nhất.
///
/// [statusCode] = HTTP status (0 nghĩa là lỗi mạng/không kết nối được).
/// [fieldErrors] chỉ có khi 400 validate — map "tên field" -> "câu lỗi" để tô đỏ đúng ô.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, String>? fieldErrors;

  ApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors,
  });

  bool get isNetwork => statusCode == 0;
  bool get isUnauthorized => statusCode == 401;
  bool get isRateLimited => statusCode == 429;
  bool get isServerBusy => statusCode == 503;

  @override
  String toString() => message;
}
