/// Thông báo in-app, khớp NotificationResponse của BE:
/// { id, type, title, content, referenceId, isRead, createdAt }.
class NotificationItem {
  final String id;
  final String type;         // BE: ORDER_STATUS... (hiện chỉ có loại đơn hàng)
  final String title;
  final String message;      // BE: content
  final String? referenceId; // BE: id đơn hàng → bấm vào mở đơn
  final DateTime timestamp;  // BE: createdAt
  bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.referenceId,
    required this.timestamp,
    this.isRead = false,
  });

  /// Nhóm để lọc + chọn icon. Hiện BE chỉ bắn loại trạng thái đơn hàng.
  String get category => type.toUpperCase().contains('ORDER') ? 'order' : 'system';

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'content': message,
        'referenceId': referenceId,
        'isRead': isRead,
        'createdAt': timestamp.toIso8601String(),
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      type: (json['type'] ?? 'SYSTEM').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['content'] ?? json['message'] ?? '').toString(),
      referenceId: json['referenceId']?.toString(),
      // chấp nhận cả createdAt (BE) lẫn timestamp (dữ liệu cũ)
      timestamp: DateTime.tryParse((json['createdAt'] ?? json['timestamp'] ?? '').toString())?.toLocal() ??
          DateTime.now(),
      // Jackson đôi khi trả 'read' thay vì 'isRead' → nhận cả hai cho chắc.
      isRead: (json['isRead'] ?? json['read']) as bool? ?? false,
    );
  }
}
