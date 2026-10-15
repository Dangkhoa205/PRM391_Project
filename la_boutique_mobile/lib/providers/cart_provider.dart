import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// Thông tin hiển thị của một voucher để dựng "vé giảm giá" trong UI.
/// Mã thật và cách tính giảm vẫn nằm trong [CartProvider.applyVoucher].
class VoucherInfo {
  final String code;
  final String title;
  final String description;
  final String badge; // nhãn ngắn hiển thị trên cuống vé, vd "-10%", "-50K", "SHIP"

  const VoucherInfo({
    required this.code,
    required this.title,
    required this.description,
    required this.badge,
  });
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  String? _appliedVoucher;
  double _voucherDiscount = 0;

  /// Danh sách voucher đang phát hành (hardcode phía app vì BE chưa có bảng voucher).
  /// Mỗi mã ở đây phải khớp một nhánh trong [applyVoucher].
  static const List<VoucherInfo> availableVouchers = [
    VoucherInfo(
      code: 'SUNSET10',
      title: 'Giảm 10% toàn bộ đơn',
      description: 'Ưu đãi BST Sunset SS26 • Không giới hạn giá trị đơn',
      badge: '-10%',
    ),
    VoucherInfo(
      code: 'LABOUTIQUE50',
      title: 'Giảm 50.000₫',
      description: 'Áp dụng cho đơn hàng từ 50.000₫',
      badge: '-50K',
    ),
    VoucherInfo(
      code: 'FREESHIP',
      title: 'Miễn phí vận chuyển',
      description: 'Giao hàng miễn phí cho mọi đơn hàng',
      badge: 'SHIP',
    ),
  ];

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
