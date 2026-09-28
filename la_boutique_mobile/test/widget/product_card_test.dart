import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:la_boutique_mobile/models/product.dart';
import 'package:la_boutique_mobile/providers/cart_provider.dart';
import 'package:la_boutique_mobile/providers/product_provider.dart';
import 'package:la_boutique_mobile/views/widgets/product_card.dart';

void main() {
  testWidgets('ProductCard Widget Test validates UI rendering and action', (WidgetTester tester) async {
    final testProduct = Product(
      id: 99,
      name: 'Váy Lụa Hoàng Hôn',
      slug: 'vay-lua-hoang-hon',
      price: 550000,
      originalPrice: 650000,
      type: 'ao',
      collection: 'sunset',
      tag: 'Signature',
      img: 'assets/images/products/sunset-main-1.jpg',
      gallery: ['assets/images/products/sunset-main-1.jpg'],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ProductCard(product: testProduct),
          ),
        ),
      ),
    );

    // Verify product name is rendered
    expect(find.text('Váy Lụa Hoàng Hôn'), findsOneWidget);

    // Verify tag is rendered
    expect(find.text('SIGNATURE'), findsOneWidget);

    // Verify Add to cart button exists
    expect(find.text('Thêm vào giỏ'), findsOneWidget);
  });
}
