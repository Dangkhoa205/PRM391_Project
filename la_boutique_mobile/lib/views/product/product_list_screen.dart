import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  final String? initialCategory;

  const ProductListScreen({super.key, this.initialCategory});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProductProvider>().setCategory(widget.initialCategory!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final products = productProvider.filteredProducts;

    final categories = [
      {'id': 'all', 'label': 'Tất cả'},
      {'id': 'sunset', 'label': 'Sunset SS26 🌅'},
      {'id': 'ao', 'label': 'Áo thiết kế'},
      {'id': 'quan', 'label': 'Quần & Váy'},
    ];

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: const Text('LA BOUTIQUE VN'),
        actions: [
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
      body: Column(
        children: [
          // Search Bar & Sort
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => productProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm đầm, áo yếm, chân váy...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.mute, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                productProvider.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: AppColors.sand200),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.sand200),
                    ),
                    child: const Icon(Icons.sort, color: AppColors.ink, size: 20),
                  ),
                  tooltip: 'Sắp xếp',
                  initialValue: productProvider.sortBy,
                  onSelected: (val) => productProvider.setSortBy(val),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'newest', child: Text('Mới nhất')),
                    const PopupMenuItem(value: 'price_asc', child: Text('Giá: Thấp đến Cao')),
                    const PopupMenuItem(value: 'price_desc', child: Text('Giá: Cao đến Thấp')),
                  ],
                ),
              ],
            ),
          ),

          // Category Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: categories.map((cat) {
                final isSelected = productProvider.selectedCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat['label']!),
                    selected: isSelected,
                    onSelected: (_) => productProvider.setCategory(cat['id']!),
                    selectedColor: AppColors.clay500,
                    backgroundColor: AppColors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.ink,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.clay500 : AppColors.sand200,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          // Product Count Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${products.length} sản phẩm',
                  style: const TextStyle(fontSize: 13, color: AppColors.mute, fontWeight: FontWeight.w500),
                ),
                Text(
                  productProvider.sortBy == 'price_asc'
                      ? 'Giá: Thấp → Cao'
                      : (productProvider.sortBy == 'price_desc' ? 'Giá: Cao → Thấp' : 'Mới nhất'),
                  style: const TextStyle(fontSize: 12, color: AppColors.clay600, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Product Grid
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: AppColors.sand300),
                        const SizedBox(height: 12),
                        const Text(
                          'Không tìm thấy sản phẩm nào phù hợp',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Thử tìm từ khóa khác hoặc xóa bộ lọc',
                          style: TextStyle(fontSize: 13, color: AppColors.mute),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            productProvider.setSearchQuery('');
                            productProvider.setCategory('all');
                          },
                          child: const Text('Xem tất cả sản phẩm', style: TextStyle(color: AppColors.clay600)),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
