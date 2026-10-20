/// Khuôn phản hồi chung của backend (xem HUONG_DAN_FE_FLUTTER §0.3):
/// `{ code, message, result?, errors?, timestamp, path }`.
///
/// `result` và `errors` dùng NON_NULL ở backend ⇒ field vắng mặt hẳn khi null
/// (không phải `"result": null`), nên luôn kiểm tra null trước khi dùng.
class ApiResponse<T> {
  final int code;
  final String message;
  final T? result;
  final Map<String, String>? errors;
  final String? path;

  ApiResponse({
    required this.code,
    required this.message,
    this.result,
    this.errors,
    this.path,
  });

  /// [parse] chuyển `result` thô (Map/List) thành model T. Bỏ qua nếu không cần result.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, [
    T Function(dynamic raw)? parse,
  ]) {
    final rawResult = json['result'];
    return ApiResponse<T>(
      code: (json['code'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      result: (rawResult == null || parse == null) ? null : parse(rawResult),
      errors: (json['errors'] as Map?)
          ?.map((k, v) => MapEntry(k.toString(), v.toString())),
      path: json['path']?.toString(),
    );
  }
}
