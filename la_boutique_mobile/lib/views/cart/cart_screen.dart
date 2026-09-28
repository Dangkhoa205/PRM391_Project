import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _voucherController = TextEditingController();

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Widget _buildItemThumbnail(String path) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    return isNetwork
        ? Image.network(path, fit: BoxFit.cover)
        : Image.asset(path, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.cartItemsList;

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: const Text('GIỎ HÀNG'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              tooltip: 'Xóa toàn bộ giỏ',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xóa giỏ hàng?'),
                    content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm khỏi giỏ hàng?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                      TextButton(
                        onPressed: () {
                          cart.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Xóa hết', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.sand100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.clay400),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Giỏ hàng của bạn đang trống',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy chọn cho mình những thiết kế nàng thơ ưng ý nhất!',
                    style: TextStyle(fontSize: 13, color: AppColors.mute),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('KHÁM PHÁ NGAY'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Free shipping notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.clay50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.clay200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, color: AppColors.clay500, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cart.subtotal >= 1000000
                                ? '🎉 Đơn hàng của bạn đã đủ điều kiện FREESHIP!'
                                : 'Mua thêm ${Formatters.formatCurrency(1000000 - cart.subtotal)} để được FREESHIP',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.clay700),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cart Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final key = item.uniqueKey;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.sand200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 75,
                                height: 95,
                                child: _buildItemThumbnail(item.product.assetPath),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 18, color: AppColors.mute),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => cart.removeItem(key),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // Selected Size Chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.sand100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Size: ${item.size}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Price & Quantity
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Formatters.formatCurrency(item.product.price),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.clay600,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.sand300),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () => cart.updateQuantity(key, item.quantity - 1),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Icon(Icons.remove, size: 14),
                                              ),
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            InkWell(
                                              onTap: () => cart.updateQuantity(key, item.quantity + 1),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Icon(Icons.add, size: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Voucher Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.sand200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MÃ GIẢM GIÁ / VOUCHER',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _voucherController,
                                textCapitalization: TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: 'Nhập SUNSET10 hoặc FREESHIP',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                final success = cart.applyVoucher(_voucherController.text);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã áp dụng mã "${_voucherController.text.toUpperCase()}"!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Mã giảm giá không hợp lệ. Thử: SUNSET10, FREESHIP'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: const Text('ÁP DỤNG'),
                            ),
                          ],
                        ),
                        if (cart.appliedVoucher != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đã áp dụng: ${cart.appliedVoucher}',
                                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              GestureDetector(
                                onTap: () => cart.removeVoucher(),
                                child: const Text('Gỡ bỏ', style: TextStyle(color: Colors.red, fontSize: 12, decoration: TextDecoration.underline)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Order Summary Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.sand200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tạm tính', style: TextStyle(color: AppColors.mute)),
                            Text(Formatters.formatCurrency(cart.subtotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (cart.discountAmount > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Giảm giá voucher', style: TextStyle(color: AppColors.success)),
                              Text('-${Formatters.formatCurrency(cart.discountAmount)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.success)),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Phí giao hàng', style: TextStyle(color: AppColors.mute)),
                            Text(
                              cart.shippingFee == 0 ? 'MIỄN PHÍ' : Formatters.formatCurrency(cart.shippingFee),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: cart.shippingFee == 0 ? AppColors.success : AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.sand200),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                              Formatters.formatCurrency(cart.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.clay600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(color: AppColors.ink.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3)),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tổng tiền', style: TextStyle(fontSize: 12, color: AppColors.mute)),
                        Text(
                          Formatters.formatCurrency(cart.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.clay600),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                          );
                        },
                        child: const Text('TIẾN HÀNH ĐẶT HÀNG', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
