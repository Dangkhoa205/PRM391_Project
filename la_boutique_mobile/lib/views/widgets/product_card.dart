import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../product/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  Widget _buildProductImage() {
    final path = product.assetPath;
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');

    return Hero(
      tag: 'product_img_${product.id}',
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: SizedBox.expand(
          child: isNetwork
              ? Image.network(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.sand200,
                    child: const Icon(Icons.image_not_supported_outlined, color: AppColors.mute),
                  ),
                )
              : Image.asset(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.sand200,
                    child: const Icon(Icons.image_not_supported_outlined, color: AppColors.mute),
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final isFav = productProvider.isFavorite(product.id);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.sand200, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack with Badges (Takes flexible available height)
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.tag == 'Signature'
                              ? AppColors.clay500
                              : (product.tag == 'Hot' ? Colors.red.shade700 : AppColors.ink),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.tag!.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: AppColors.white.withValues(alpha: 0.85),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => productProvider.toggleFavorite(product.id),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? Colors.red : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(8),
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
                            style: const TextStyle(
                              color: AppColors.mute,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Quick Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: AppColors.clay500, width: 0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: AppColors.sand50,
                      ),
                      onPressed: () {
                        context.read<CartProvider>().addToCart(product, size: 'M');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm "${product.name}" (Size M) vào giỏ'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.ink,
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'XEM GIỎ',
                              textColor: AppColors.clay300,
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 12, color: AppColors.clay500),
                          SizedBox(width: 4),
                          Text(
                            'Thêm vào giỏ',
                            style: TextStyle(
                              fontSize: 10,
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
