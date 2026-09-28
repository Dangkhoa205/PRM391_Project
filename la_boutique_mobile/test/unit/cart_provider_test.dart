import 'package:flutter_test/flutter_test.dart';
import 'package:la_boutique_mobile/models/product.dart';
import 'package:la_boutique_mobile/providers/cart_provider.dart';

void main() {
  group('CartProvider Unit Tests (PRM393 Business Logic)', () {
    late CartProvider cartProvider;
    late Product testProduct1;
    late Product testProduct2;

    setUp(() {
      cartProvider = CartProvider();
      testProduct1 = Product(
        id: 1,
        name: 'Set La Boutique Sunset',
        slug: 'set-la-boutique-sunset',
        price: 720000,
        originalPrice: 890000,
        type: 'ao',
        collection: 'sunset',
        img: 'assets/images/products/sunset-main-1.jpg',
        gallery: ['assets/images/products/sunset-main-1.jpg'],
      );
      testProduct2 = Product(
        id: 4,
        name: 'Áo Cổ Yếm tơ xốp',
        slug: 'ao-co-yem-to-xop',
        price: 310000,
        type: 'ao',
        collection: 'regular',
        img: 'assets/images/products/co-yem-to-xop-1.jpg',
        gallery: ['assets/images/products/co-yem-to-xop-1.jpg'],
      );
    });

    test('Initial cart is empty', () {
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.subtotal, 0.0);
      expect(cartProvider.totalAmount, 0.0);
    });

    test('Add product to cart updates quantity and subtotal', () {
      cartProvider.addToCart(testProduct1, size: 'M', quantity: 1);

      expect(cartProvider.itemCount, 1);
      expect(cartProvider.subtotal, 720000.0);
      expect(cartProvider.shippingFee, 30000.0); // Standard shipping
      expect(cartProvider.totalAmount, 750000.0);
    });

    test('Add duplicate product with same size increases quantity', () {
      cartProvider.addToCart(testProduct1, size: 'M', quantity: 1);
      cartProvider.addToCart(testProduct1, size: 'M', quantity: 2);

      expect(cartProvider.itemCount, 3);
      expect(cartProvider.subtotal, 720000.0 * 3);
    });

    test('Applying SUNSET10 discount voucher calculates 10% off subtotal', () {
      cartProvider.addToCart(testProduct1, size: 'M', quantity: 1); // 720,000
      final applied = cartProvider.applyVoucher('SUNSET10');

      expect(applied, true);
      expect(cartProvider.discountAmount, 72000.0);
      // Total = 720,000 - 72,000 + 30,000 = 678,000
      expect(cartProvider.totalAmount, 678000.0);
    });

    test('Order >= 1,000,000 qualifies for free shipping', () {
      cartProvider.addToCart(testProduct1, size: 'M', quantity: 1); // 720,000
      cartProvider.addToCart(testProduct2, size: 'S', quantity: 1); // 310,000
      // Subtotal = 1,030,000 >= 1,000,000
      expect(cartProvider.subtotal, 1030000.0);
      expect(cartProvider.shippingFee, 0.0);
      expect(cartProvider.totalAmount, 1030000.0);
    });

    test('Removing item updates cart correctly', () {
      cartProvider.addToCart(testProduct1, size: 'M', quantity: 1);
      final key = '${testProduct1.id}_M';
      cartProvider.removeItem(key);

      expect(cartProvider.itemCount, 0);
      expect(cartProvider.subtotal, 0.0);
    });
  });
}
