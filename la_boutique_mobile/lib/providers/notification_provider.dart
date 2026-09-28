import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => [..._notifications];

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _initSampleNotifications();
  }

  void _initSampleNotifications() {
    _notifications.addAll([
      NotificationItem(
        id: 'notif_1',
        title: 'Đơn hàng #LB-90214 đang được giao 🚚',
        message:
            'Đơn hàng Set La Boutique Sunset của quý khách đã được chuyển tới đơn vị vận chuyển GHN. Dự kiến giao hôm nay.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'order',
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_2',
        title: 'Ra mắt BST Sunset SS26 🌅',
        message:
            'Khám phá ngay bộ sưu tập hoàng hôn với chất lụa và linen cao cấp. Nhập mã SUNSET10 giảm ngay 10%!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: 'promo',
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_3',
        title: 'Ưu đãi FREESHIP toàn quốc 🎁',
        message: 'Áp dụng mã FREESHIP cho mọi đơn hàng thời trang thiết kế mùa hè tuần này.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: 'promo',
        isRead: true,
      ),
      NotificationItem(
        id: 'notif_4',
        title: 'Đặt hàng thành công #LB-88312 ✨',
        message: 'Cảm ơn nàng thơ đã ủng hộ La Boutique VN. Đơn hàng đang được đóng gói cẩn thận.',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        type: 'order',
        isRead: true,
      ),
    ]);
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void addOrderNotification(String orderId) {
    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Đặt hàng thành công #$orderId ✨',
        message: 'Đơn hàng của bạn đã được ghi nhận vào hệ thống La Boutique.',
        timestamp: DateTime.now(),
        type: 'order',
        isRead: false,
      ),
    );
    notifyListeners();
  }
}
