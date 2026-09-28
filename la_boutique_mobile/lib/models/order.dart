import 'cart_item.dart';

class OrderModel {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final String? note;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double total;
  final String paymentMethod; // 'COD' or 'BANKING'
  final String status; // 'Chờ xác nhận', 'Đang xử lý', 'Đang giao', 'Hoàn thành'
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    this.note,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.shippingFee = 30000,
    required this.total,
    required this.paymentMethod,
    this.status = 'Đang xử lý',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'note': note,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'shippingFee': shippingFee,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      note: json['note'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num? ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] as num? ?? 30000).toDouble(),
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String? ?? 'Đang xử lý',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
