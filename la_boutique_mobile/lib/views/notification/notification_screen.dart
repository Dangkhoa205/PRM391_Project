import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _filter = 'all'; // 'all', 'order', 'promo'

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    var notifications = notifProvider.notifications;

    if (_filter != 'all') {
      notifications = notifications.where((n) => n.type == _filter).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: const Text('THÔNG BÁO'),
        actions: [
          if (notifProvider.unreadCount > 0)
            TextButton(
              onPressed: () => notifProvider.markAllAsRead(),
              child: const Text('Đọc tất cả', style: TextStyle(color: AppColors.clay600, fontSize: 12)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('all', 'Tất cả'),
                const SizedBox(width: 8),
                _buildFilterChip('order', 'Đơn hàng 📦'),
                const SizedBox(width: 8),
                _buildFilterChip('promo', 'Khuyến mãi 🎁'),
              ],
            ),
          ),

          // List
          Expanded(
            child: notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: AppColors.sand300),
                        SizedBox(height: 12),
                        Text(
                          'Không có thông báo mới',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return InkWell(
                        onTap: () => notifProvider.markAsRead(item.id),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item.isRead ? AppColors.white : AppColors.clay50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: item.isRead ? AppColors.sand200.withValues(alpha: 0.8) : AppColors.clay200,
                            ),
                            boxShadow: item.isRead ? AppColors.cardShadow : null,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: item.type == 'order'
                                      ? Colors.blue.shade50
                                      : AppColors.clay100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.type == 'order'
                                      ? Icons.local_shipping_outlined
                                      : Icons.local_offer_outlined,
                                  color: item.type == 'order'
                                      ? Colors.blue.shade700
                                      : AppColors.clay600,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                              fontSize: 13,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                        ),
                                        if (!item.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.clay500,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.message,
                                      style: const TextStyle(fontSize: 12, color: AppColors.mute, height: 1.4),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      Formatters.formatDate(item.timestamp),
                                      style: TextStyle(fontSize: 10, color: AppColors.mute.withValues(alpha: 0.8)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _filter = value);
      },
      selectedColor: AppColors.clay500,
      backgroundColor: AppColors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.ink,
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? AppColors.clay500 : AppColors.sand200),
      ),
      showCheckmark: false,
    );
  }
}
