import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../data/mock_data.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => [..._orders];

  OrderProvider() {
    _initSampleOrders();
  }

  void _initSampleOrders() {
    _orders.addAll([
      OrderModel(
        id: 'LB-90214',
        customerName: 'Hoàng Lan',
        phone: '0901234567',
        address: '72 Lê Thánh Tôn, Bến Nghé, Quận 1, TP.HCM',
        note: 'Giao giờ hành chính giúp em',
        items: [
          CartItem(
            product: MockData.initialProducts[0],
            size: 'M',
            quantity: 1,
          ),
        ],
        subtotal: 720000,
        discount: 72000,
        shippingFee: 0,
        total: 648000,
        paymentMethod: 'COD',
        status: 'Đang giao hàng',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      OrderModel(
        id: 'LB-88312',
        customerName: 'Minh Thư',
        phone: '0901234567',
        address: 'Tòa nhà Landmark 81, Bình Thạnh, TP.HCM',
        items: [
          CartItem(
            product: MockData.initialProducts[1],
            size: 'S',
            quantity: 1,
          ),
          CartItem(
            product: MockData.initialProducts[4],
            size: 'M',
            quantity: 1,
          ),
        ],
        subtotal: 1000000,
        discount: 0,
        shippingFee: 0,
        total: 1000000,
        paymentMethod: 'BANKING',
        status: 'Hoàn thành',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
  }

  String createOrder({
    required String customerName,
    required String phone,
    required String address,
    String? note,
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double shippingFee,
    required double total,
    required String paymentMethod,
  }) {
    final randomId = 'LB-${10000 + Random().nextInt(90000)}';
    final newOrder = OrderModel(
      id: randomId,
      customerName: customerName,
      phone: phone,
      address: address,
      note: note,
      items: List.from(items),
      subtotal: subtotal,
      discount: discount,
      shippingFee: shippingFee,
      total: total,
      paymentMethod: paymentMethod,
      status: 'Đang xử lý',
      createdAt: DateTime.now(),
    );

    _orders.insert(0, newOrder);
    notifyListeners();
    return randomId;
  }

  List<OrderModel> searchOrdersByPhone(String phone) {
    final clean = phone.trim().replaceAll(' ', '');
    return _orders.where((o) => o.phone.replaceAll(' ', '').contains(clean)).toList();
  }

  OrderModel? getOrderById(String orderId) {
    final clean = orderId.trim().toUpperCase();
    try {
      return _orders.firstWhere((o) => o.id.toUpperCase() == clean);
    } catch (_) {
      return null;
    }
  }
}
