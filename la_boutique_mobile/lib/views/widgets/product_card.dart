import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';
import '../product/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String? heroPrefix;

  const ProductCard({
    super.key,
    required this.product,
    this.heroPrefix,
  });

  Widget _buildProductImage() {
    final path = product.assetPath;
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    final heroTag = heroPrefix != null ? '${heroPrefix}_${product.id}' : 'product_img_${product.id}';

    final placeholder = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.sand100, AppColors.sand200],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dry_cleaning_outlined, color: AppColors.clay400.withValues(alpha: 0.6), size: 30),
            const SizedBox(height: 4),
            Text(
              'LA BOUTIQUE',
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                color: AppColors.mute.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );

    return Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        child: SizedBox.expand(
          child: isNetwork
              ? Image.network(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => placeholder,
                )
              : Image.asset(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => placeholder,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final isFav = productProvider.isFavorite(product.id);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sand200.withValues(alpha: 0.8), width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack with Badges
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _buildProductImage()),

                  // Tag Badge (Signature / Mới / Hot)
                  if (product.tag != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: product.tag == 'Signature'
                              ? AppColors.clay500
                              : (product.tag == 'Hot' ? const Color(0xFFC84B31) : AppColors.ink),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          product.tag!.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: 0.15),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          productProvider.toggleFavorite(product.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.5),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 15,
                            color: isFav ? const Color(0xFFD32F2F) : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Discount percentage pill on image bottom right
                  if (product.discountPercentage > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${product.discountPercentage}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Pricing
                  Row(
                    children: [
                      Text(
                        Formatters.formatCurrency(product.price),
                        style: const TextStyle(
                          color: AppColors.clay600,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (product.originalPrice != null &&
                          product.originalPrice! > product.price) ...[
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            Formatters.formatCurrency(product.originalPrice!),
                            style: TextStyle(
                              color: AppColors.mute.withValues(alpha: 0.7),
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Quick Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(
                          color: AppColors.clay500.withValues(alpha: 0.7),
                          width: 0.8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        backgroundColor: AppColors.clay50.withValues(alpha: 0.5),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        context.read<CartProvider>().addToCart(product, size: 'M');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm "${product.name}" (Size M) vào giỏ'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.ink,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            action: SnackBarAction(
                              label: 'XEM GIỎ',
                              textColor: AppColors.sand300,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CartScreen()),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_shopping_cart, size: 12, color: AppColors.clay600),
                          SizedBox(width: 4),
                          Text(
                            'Thêm vào giỏ',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.clay600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
