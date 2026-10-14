import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../auth/login_screen.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<String> _tabs = [
    'Tất cả',
    'Chờ xác nhận',
    'Đang giao',
    'Hoàn thành',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<OrderProvider>().fetchMyOrders();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'HOÀN THÀNH':
        return AppColors.success;
      case 'SHIPPING':
      case 'ĐANG GIAO HÀNG':
        return Colors.blue.shade700;
      case 'CONFIRMED':
      case 'ĐÃ XÁC NHẬN':
      case 'PENDING':
      case 'CHỜ XÁC NHẬN':
        return Colors.amber.shade800;
      case 'CANCELLED':
      case 'ĐÃ HỦY':
        return Colors.red.shade700;
      default:
        return AppColors.mute;
    }
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders, int tabIndex) {
    if (tabIndex == 0) return orders;
    if (tabIndex == 1) {
      return orders.where((o) {
        final s = o.status.toUpperCase();
        return s == 'PENDING' || s == 'CHỜ XÁC NHẬN' || s == 'CONFIRMED' || s == 'ĐÃ XÁC NHẬN';
      }).toList();
    }
    if (tabIndex == 2) {
      return orders.where((o) => o.status.toUpperCase() == 'SHIPPING' || o.status.contains('GIAO')).toList();
    }
    if (tabIndex == 3) {
      return orders.where((o) => o.status.toUpperCase() == 'COMPLETED' || o.status.contains('HOÀN THÀNH')).toList();
    }
    if (tabIndex == 4) {
      return orders.where((o) => o.status.toUpperCase() == 'CANCELLED' || o.status.contains('HỦY')).toList();
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.sand50,
        appBar: AppBar(title: const Text('ĐƠN HÀNG CỦA TÔI')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.clay400),
                const SizedBox(height: 16),
                const Text(
                  'Vui lòng đăng nhập để xem đơn hàng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Danh sách đơn hàng của nàng được bảo mật và gắn liền với tài khoản.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.mute),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.clay500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  child: const Text('ĐĂNG NHẬP NGAY'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final allOrders = orderProvider.orders;

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: const Text('ĐƠN HÀNG CỦA TÔI'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.clay600,
          unselectedLabelColor: AppColors.mute,
          indicatorColor: AppColors.clay500,
          indicatorWeight: 2.5,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.clay500))
          : TabBarView(
              controller: _tabController,
              children: List.generate(_tabs.length, (tabIdx) {
                final orders = _filterOrders(allOrders, tabIdx);

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox_outlined, size: 56, color: AppColors.sand300),
                        const SizedBox(height: 12),
                        Text(
                          'Không có đơn hàng nào (${_tabs[tabIdx]})',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.mute),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.clay500,
                  onRefresh: () => orderProvider.fetchMyOrders(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final statusColor = _getStatusColor(order.status);

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailScreen(orderNumber: order.displayOrderNumber),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.sand200.withValues(alpha: 0.8)),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.tag, size: 16, color: AppColors.clay500),
                                      Text(
                                        order.displayOrderNumber,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ink),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      order.statusText,
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Ngày đặt: ${Formatters.formatDate(order.createdAt)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.mute),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Người nhận: ${order.customerName} (${order.phone})',
                                style: const TextStyle(fontSize: 12.5),
                              ),
                              const Divider(height: 20, color: AppColors.sand200),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${order.totalItems} sản phẩm • ${order.paymentMethodText}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.mute),
                                  ),
                                  Text(
                                    Formatters.formatCurrency(order.total),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.clay600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
    );
  }
}
