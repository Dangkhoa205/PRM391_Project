import 'product.dart';

class CartItem {
  final Product product;
  final String size; // S, M, L
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  String get uniqueKey => '${product.id}_$size';

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'size': size,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      size: json['size'] as String,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}
