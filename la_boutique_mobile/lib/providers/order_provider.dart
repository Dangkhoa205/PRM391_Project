import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  final List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => [..._orders];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrderProvider() {
    _initSampleOrders();
  }

  void _initSampleOrders() {
    _orders.addAll([
      OrderModel(
        id: 'LB-90214',
        orderNumber: 'LB-90214',
        customerName: 'Hoàng Lan',
        phone: '0901234567',
        address: '72 Lê Thánh Tôn, Bến Nghé, Quận 1, TP.HCM',
        note: 'Giao giờ hành chính giúp em',
        items: [],
        subtotal: 720000,
        discount: 72000,
        shippingFee: 0,
        total: 648000,
        totalItems: 1,
        paymentMethod: 'COD',
        status: 'SHIPPING',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      OrderModel(
        id: 'LB-88312',
        orderNumber: 'LB-88312',
        customerName: 'Minh Thư',
        phone: '0901234567',
        address: 'Tòa nhà Landmark 81, Bình Thạnh, TP.HCM',
        items: [],
        subtotal: 1000000,
        discount: 0,
        shippingFee: 0,
        total: 1000000,
        totalItems: 2,
        paymentMethod: 'BANK_TRANSFER',
        status: 'COMPLETED',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
  }

  Future<void> fetchMyOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.get(
        ApiConstants.myOrders,
        queryParams: {'size': 50, 'sort': 'createdAt,desc'},
        requiresAuth: true,
      );

      if (result != null && result is Map<String, dynamic> && result['content'] is List) {
        final list = (result['content'] as List)
            .map((o) => OrderModel.fromJson(o as Map<String, dynamic>))
            .toList();

        _orders.clear();
        _orders.addAll(list);
      }
    } catch (e) {
      debugPrint('[OrderProvider] fetchMyOrders fallback: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> fetchOrderDetail(String orderNumber) async {
    try {
      final result = await _api.get(
        ApiConstants.myOrderByNumber(orderNumber),
        requiresAuth: true,
      );

      if (result != null && result is Map<String, dynamic>) {
        final detailedOrder = OrderModel.fromJson(result);
        final index = _orders.indexWhere((o) => o.orderNumber == orderNumber);
        if (index != -1) {
          _orders[index] = detailedOrder;
          notifyListeners();
        }
        return detailedOrder;
      }
    } catch (e) {
      debugPrint('[OrderProvider] fetchOrderDetail error: $e');
    }

    return getOrderById(orderNumber);
  }

  Future<String> createOrder({
    required String customerName,
    required String phone,
    String? email,
    required String address,
    String? note,
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double shippingFee,
    required double total,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Map payment method to BE enum
    final bePaymentMethod = (paymentMethod == 'BANKING' || paymentMethod == 'BANK_TRANSFER')
        ? 'BANK_TRANSFER'
        : 'COD';

    // Format items for BE
    final itemsPayload = items.map((item) {
      return {
        'productId': item.product.id,
        'size': item.size.toUpperCase(),
        'quantity': item.quantity,
      };
    }).toList();

    final orderBody = {
      'receiverName': customerName.trim(),
      'phone': phone.trim(),
      'email': email != null && email.trim().isNotEmpty ? email.trim() : null,
      'address': address.trim(),
      'note': note != null && note.trim().isNotEmpty ? note.trim() : null,
      'paymentMethod': bePaymentMethod,
      'items': itemsPayload,
    };

    try {
      final result = await _api.post(
        ApiConstants.orders,
        body: orderBody,
        requiresAuth: true,
      );

      if (result != null && result is Map<String, dynamic>) {
        final createdOrder = OrderModel.fromJson(result);
        _orders.insert(0, createdOrder);
        _isLoading = false;
        notifyListeners();
        return createdOrder.orderNumber;
      }
    } catch (e) {
      debugPrint('[OrderProvider] BE createOrder failed, fallback to local: $e');
    }

    // Local fallback order creation
    final randomId = 'LB-${10000 + Random().nextInt(90000)}';
    final fallbackOrder = OrderModel(
      id: randomId,
      orderNumber: randomId,
      customerName: customerName,
      phone: phone,
      email: email,
      address: address,
      note: note,
      items: List.from(items),
      subtotal: subtotal,
      discount: discount,
      shippingFee: shippingFee,
      total: total,
      totalItems: items.length,
      paymentMethod: bePaymentMethod,
      status: 'PENDING',
      createdAt: DateTime.now(),
    );

    _orders.insert(0, fallbackOrder);
    _isLoading = false;
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
      return _orders.firstWhere((o) =>
          o.id.toUpperCase() == clean || o.orderNumber.toUpperCase() == clean);
    } catch (_) {
      return null;
    }
  }
}
