import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../models/notification_item.dart';
import '../services/api_service.dart';

/// Thông báo in-app — nối BE thật (/notifications/me). Chưa có push ra máy (BE chưa có FCM);
/// badge chỉ cập nhật khi mở màn / kéo làm mới.
class NotificationProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  final List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  /// Tải danh sách (mới nhất trước). An toàn khi chưa đăng nhập: lỗi thì để rỗng.
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _api.get(
        ApiConstants.notifications,
        queryParams: {'size': 50},
        requiresAuth: true,
      );
      if (result is Map<String, dynamic> && result['content'] is List) {
        _notifications
          ..clear()
          ..addAll((result['content'] as List)
              .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)));
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      debugPrint('[NotificationProvider] fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Chỉ lấy số chưa đọc cho chấm đỏ (nhẹ hơn tải cả danh sách).
  Future<void> fetchUnreadCount() async {
    try {
      final r = await _api.get(ApiConstants.notificationsUnreadCount, requiresAuth: true);
      if (r is Map && r['unreadCount'] != null) {
        _unreadCount = (r['unreadCount'] as num).toInt();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] unread count error: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _api.patch(ApiConstants.notificationRead(id), requiresAuth: true);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1 && !_notifications[idx].isRead) {
        _notifications[idx].isRead = true;
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.patch(ApiConstants.notificationsReadAll, requiresAuth: true);
      for (final n in _notifications) {
        n.isRead = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('[NotificationProvider] markAllAsRead error: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _api.delete(ApiConstants.notificationById(id), requiresAuth: true);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        if (!_notifications[idx].isRead && _unreadCount > 0) _unreadCount--;
        _notifications.removeAt(idx);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] delete error: $e');
    }
  }

  /// Gọi sau khi đặt đơn. BE KHÔNG bắn thông báo lúc PENDING (doc §4.3) nên chỉ cần
  /// làm mới badge; thông báo thật sẽ tới khi đơn đổi trạng thái (CONFIRMED/SHIPPING...).
  Future<void> addOrderNotification(String orderId) => fetchUnreadCount();

  /// Dọn khi đăng xuất.
  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
}
