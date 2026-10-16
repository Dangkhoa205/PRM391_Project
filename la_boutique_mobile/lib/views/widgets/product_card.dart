import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Cần thiết cho ImageFilter (nếu muốn làm mờ ảnh)

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';
import '../product/product_detail_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final String? heroPrefix;

  const ProductCard({
    super.key,
    required this.product,
    this.heroPrefix,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _showSizeOverlay = false;

  void _toggleSizeOverlay() {
    setState(() {
      _showSizeOverlay = !_showSizeOverlay;
    });
  }

  void _addToCart(String size) {
    HapticFeedback.mediumImpact();

    // 1. Thêm vào giỏ hàng với đúng size được chọn
    context.read<CartProvider>().addToCart(widget.product, size: size);

    // 2. Tắt bảng chọn size
    setState(() {
      _showSizeOverlay = false;
    });

    // 3. Xóa thông báo cũ ngay lập tức (nếu đang hiển thị) để hiện thông báo mới
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 4. Hiển thị thông báo mới với size ĐỘNG ($size)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Sửa chữ (Size M) thành (Size $size) ở dòng dưới này:
        content: Text('Đã thêm "${widget.product.name}" (Size $size) vào giỏ'),
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
  }
  Widget _buildProductImage() {
    final path = widget.product.assetPath;
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    final heroTag = widget.heroPrefix != null
        ? '${widget.heroPrefix}_${widget.product.id}'
        : 'product_img_${widget.product.id}';

    final placeholder = Container(
      color: AppColors.sand100,
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
      child: SizedBox.expand(
        child: isNetwork
            ? Image.network(path, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder)
            : Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final isFav = productProvider.isFavorite(widget.product.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. IMAGE SECTION (Ảnh, Tag, Nút Thêm Nhanh/Size)
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Bấm vào ảnh để vào trang chi tiết
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: widget.product),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh gốc
                  _buildProductImage(),

                  // Lớp phủ đen mờ khi mở bảng chọn Size
                  if (_showSizeOverlay)
                    Container(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),

                  // Tag (MỚI / SIGNATURE / HOT)
                  if (widget.product.tag != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.product.tag == 'Signature'
                              ? const Color(0xFFE88A1A) // Màu cam vàng như thiết kế
                              : (widget.product.tag == 'Mới' ? const Color(0xFFD6734D) : AppColors.ink),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.product.tag!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                  // Nút thả tim (Favorite)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          productProvider.toggleFavorite(widget.product.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? const Color(0xFFD32F2F) : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Phần Control bên dưới ảnh (Thêm Nhanh HOẶC Chọn Size)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _showSizeOverlay ? _buildSizeSelector() : _buildQuickAddButton(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 2. INFO SECTION (Chữ bên dưới ảnh)
        Text(
          'ÁO & ĐẦM', // Bạn có thể thay bằng widget.product.category nếu có
          style: TextStyle(
            color: AppColors.mute.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),

        Text(
          widget.product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),

        // Pricing
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Formatters.formatCurrency(widget.product.price),
              style: const TextStyle(
                color: Color(0xFFA55142), // Màu đỏ nâu gạch giống thiết kế
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.product.originalPrice != null &&
                widget.product.originalPrice! > widget.product.price) ...[
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  Formatters.formatCurrency(widget.product.originalPrice!),
                  style: TextStyle(
                    color: AppColors.mute.withValues(alpha: 0.6),
                    fontSize: 11,
                    decoration: TextDecoration.lineThrough,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // Widget Nút "THÊM NHANH"
  Widget _buildQuickAddButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _toggleSizeOverlay();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.black87),
            SizedBox(width: 6),
            Text(
              'THÊM NHANH',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Bảng chọn Size (S M L) và ĐÓNG SIZE
  Widget _buildSizeSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Khung chọn size
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF332B27), // Màu nâu đen giống thiết kế
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ['S', 'M', 'L'].map((size) {
              return GestureDetector(
                onTap: () => _addToCart(size),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    size,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        // Nút Đóng Size
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _toggleSizeOverlay();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, size: 12, color: Colors.black87),
                SizedBox(width: 6),
                Text(
                  'ĐÓNG SIZE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}