import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  String _selectedSize = 'M';
  int _quantity = 1;
  final PageController _pageController = PageController();

  final List<String> _sizes = ['S', 'M', 'L'];

  void _showSizeGuide() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.sand50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.straighten, color: AppColors.clay500),
            const SizedBox(width: 8),
            Text(
              'Bảng Quy Đổi Size',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bảng số đo chuẩn phom dáng nữ La Boutique:',
                style: TextStyle(fontSize: 13, color: AppColors.mute),
              ),
              const SizedBox(height: 12),
              Table(
                border: TableBorder.all(color: AppColors.sand300, width: 0.8),
                children: const [
                  TableRow(
                    decoration: BoxDecoration(color: AppColors.sand200),
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Cân nặng', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Vòng 1', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Vòng 2', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('S', style: TextStyle(fontWeight: FontWeight.w600))),
                      Padding(padding: EdgeInsets.all(8), child: Text('40 - 48 kg')),
                      Padding(padding: EdgeInsets.all(8), child: Text('< 84 cm')),
                      Padding(padding: EdgeInsets.all(8), child: Text('< 66 cm')),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('M', style: TextStyle(fontWeight: FontWeight.w600))),
                      Padding(padding: EdgeInsets.all(8), child: Text('48 - 54 kg')),
                      Padding(padding: EdgeInsets.all(8), child: Text('85 - 88 cm')),
                      Padding(padding: EdgeInsets.all(8), child: Text('67 - 72 cm')),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('L', style: TextStyle(fontWeight: FontWeight.w600))),
                      Padding(padding: EdgeInsets.all(8), child: Text('55 - 62 kg')),
                      Padding(padding: EdgeInsets.all(8), child: Text('89 - 94 cm')),
                      Padding(padding: EdgeInsets.all(8), child: Text('73 - 78 cm')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Lưu ý: Nếu số đo của nàng nằm giữa 2 size, nàng nên chọn size lớn hơn để mặc thoải mái và bay bổng hơn.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.mute),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ĐÃ HIỂU', style: TextStyle(color: AppColors.clay600, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(String path) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    return isNetwork
        ? Image.network(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.sand200,
              child: const Icon(Icons.image_not_supported_outlined, size: 40, color: AppColors.mute),
            ),
          )
        : Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.sand200,
              child: const Icon(Icons.image_not_supported_outlined, size: 40, color: AppColors.mute),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final gallery = p.assetGallery.isNotEmpty ? p.assetGallery : [p.assetPath];
    final cart = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
    final isFav = productProvider.isFavorite(p.id);

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : AppColors.ink,
            ),
            onPressed: () => productProvider.toggleFavorite(p.id),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.clay500,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gallery View with Carousel
            SizedBox(
              height: 380,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: gallery.length,
                    onPageChanged: (index) {
                      setState(() => _selectedImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: index == 0 ? 'product_img_${p.id}' : 'gallery_${p.id}_$index',
                        child: _buildImageItem(gallery[index]),
                      );
                    },
                  ),
                  if (gallery.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          gallery.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _selectedImageIndex == i ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _selectedImageIndex == i
                                  ? AppColors.clay500
                                  : AppColors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Thumbnails List
            if (gallery.length > 1)
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: gallery.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedImageIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedImageIndex = index);
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.clay500 : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _buildImageItem(gallery[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Product Details Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Collection tag
                  if (p.collection == 'sunset')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.clay100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🌅 BỘ SƯU TẬP SUNSET SS26',
                        style: TextStyle(
                          color: AppColors.clay700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    p.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        Formatters.formatCurrency(p.price),
                        style: const TextStyle(
                          color: AppColors.clay600,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (p.originalPrice != null && p.originalPrice! > p.price) ...[
                        const SizedBox(width: 10),
                        Text(
                          Formatters.formatCurrency(p.originalPrice!),
                          style: const TextStyle(
                            color: AppColors.mute,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${p.discountPercentage}%',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: AppColors.sand200),
                  const SizedBox(height: 10),

                  // Size Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KÍCH THƯỚC (SIZE)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppColors.ink,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showSizeGuide,
                        icon: const Icon(Icons.straighten, size: 14, color: AppColors.clay600),
                        label: const Text(
                          'Hướng dẫn chọn size',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.clay600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(size),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedSize = size);
                          },
                          selectedColor: AppColors.clay500,
                          backgroundColor: AppColors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.ink,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? AppColors.clay500 : AppColors.sand300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Quantity Selector
                  Row(
                    children: [
                      const Text(
                        'SỐ LƯỢNG',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.sand300),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Accordion
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.sand200),
                    ),
                    child: Column(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            title: const Text('Mô tả sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                child: Text(
                                  p.description ?? 'Thiết kế độc quyền từ thương hiệu La Boutique VN.',
                                  style: const TextStyle(height: 1.5, color: AppColors.mute),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.sand200),
                        Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: const Text('Chất liệu & Bảo quản', style: TextStyle(fontWeight: FontWeight.bold)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (p.material != null) ...[
                                      Text('• Chất liệu: ${p.material!}', style: const TextStyle(height: 1.4)),
                                      const SizedBox(height: 6),
                                    ],
                                    if (p.careInstructions != null)
                                      Text('• Hướng dẫn giặt: ${p.careInstructions!}', style: const TextStyle(height: 1.4)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.sand200),
                        Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: const ExpansionTile(
                            title: Text('Chính sách giao hàng & Đổi trả', style: TextStyle(fontWeight: FontWeight.bold)),
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• Giao hàng toàn quốc: 1-2 ngày đối với nội thành, 2-3 ngày với các tỉnh thành.', style: TextStyle(height: 1.4)),
                                    SizedBox(height: 6),
                                    Text('• Miễn phí giao hàng cho đơn từ 1.000.000₫ hoặc áp dụng mã FREESHIP.', style: TextStyle(height: 1.4)),
                                    SizedBox(height: 6),
                                    Text('• Đổi size miễn phí trong vòng 7 ngày kể từ khi nhận hàng.', style: TextStyle(height: 1.4)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reviews section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.sand200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ĐÁNH GIÁ (5.0 ★)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Viết đánh giá', style: TextStyle(color: AppColors.clay600, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.sand50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Bảo Ngọc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Spacer(),
                                  Text('5 ngày trước', style: TextStyle(fontSize: 10, color: AppColors.mute)),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 12, color: Colors.amber),
                                  Icon(Icons.star, size: 12, color: Colors.amber),
                                  Icon(Icons.star, size: 12, color: Colors.amber),
                                  Icon(Icons.star, size: 12, color: Colors.amber),
                                  Icon(Icons.star, size: 12, color: Colors.amber),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Form dáng chuẩn, vải cực kỳ mềm mát và bay bổng khi mặc dạo biển. Rất ưng ý!',
                                style: TextStyle(fontSize: 12, color: AppColors.ink, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // padding for sticky bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Add to Cart
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.clay500, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    context.read<CartProvider>().addToCart(
                          p,
                          size: _selectedSize,
                          quantity: _quantity,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm $_quantity x "${p.name}" (Size $_selectedSize) vào giỏ'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.ink,
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'XEM GIỎ',
                          textColor: AppColors.clay300,
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
                      Icon(Icons.add_shopping_cart, size: 18, color: AppColors.clay500),
                      SizedBox(width: 6),
                      Text('Thêm vào giỏ', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Buy Now
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    context.read<CartProvider>().addToCart(
                          p,
                          size: _selectedSize,
                          quantity: _quantity,
                        );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  child: const Text('MUA NGAY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
