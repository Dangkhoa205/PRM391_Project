import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  String? _appliedVoucher;
  double _voucherDiscount = 0;

  Map<String, CartItem> get items => {..._items};

  List<CartItem> get cartItemsList => _items.values.toList();

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  String? get appliedVoucher => _appliedVoucher;

  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get shippingFee {
    if (subtotal == 0) return 0;
    if (_appliedVoucher == 'FREESHIP' || subtotal >= 1000000) return 0;
    return 30000;
  }

  double get discountAmount => _voucherDiscount;

  double get totalAmount {
    if (subtotal == 0) return 0;
    final total = subtotal - discountAmount + shippingFee;
    return total > 0 ? total : 0;
  }

  void addToCart(Product product, {String size = 'M', int quantity = 1}) {
    final key = '${product.id}_$size';
    if (_items.containsKey(key)) {
      _items[key]!.quantity += quantity;
    } else {
      _items[key] = CartItem(
        product: product,
        size: size,
        quantity: quantity,
      );
    }
    _recalculateDiscount();
    notifyListeners();
  }

  void updateQuantity(String key, int newQuantity) {
    if (!_items.containsKey(key)) return;

    if (newQuantity <= 0) {
      _items.remove(key);
    } else {
      _items[key]!.quantity = newQuantity;
    }
    _recalculateDiscount();
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    _recalculateDiscount();
    notifyListeners();
  }

  bool applyVoucher(String code) {
    final upper = code.trim().toUpperCase();
    if (upper == 'SUNSET10') {
      _appliedVoucher = 'SUNSET10';
      _voucherDiscount = subtotal * 0.10;
      notifyListeners();
      return true;
    } else if (upper == 'FREESHIP') {
      _appliedVoucher = 'FREESHIP';
      _voucherDiscount = 0;
      notifyListeners();
      return true;
    } else if (upper == 'LABOUTIQUE50') {
      _appliedVoucher = 'LABOUTIQUE50';
      _voucherDiscount = subtotal >= 50000 ? 50000 : subtotal;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeVoucher() {
    _appliedVoucher = null;
    _voucherDiscount = 0;
    notifyListeners();
  }

  void _recalculateDiscount() {
    if (_appliedVoucher == 'SUNSET10') {
      _voucherDiscount = subtotal * 0.10;
    } else if (_appliedVoucher == 'LABOUTIQUE50') {
      _voucherDiscount = subtotal >= 50000 ? 50000 : subtotal;
    } else {
      _voucherDiscount = 0;
    }
  }

  void clearCart() {
    _items.clear();
    _appliedVoucher = null;
    _voucherDiscount = 0;
    notifyListeners();
  }
}
