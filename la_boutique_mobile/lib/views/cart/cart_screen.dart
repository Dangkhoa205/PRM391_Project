import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Bottom sheet liệt kê toàn bộ voucher dạng "vé" để người dùng bấm áp dụng ngay,
  /// không cần nhớ/gõ mã. Dữ liệu lấy từ [CartProvider.availableVouchers].
  void _showVoucherModal(BuildContext context, CartProvider cart) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sand50,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        // Consumer để trạng thái "đang áp dụng" cập nhật ngay trong sheet khi bấm.
        return Consumer<CartProvider>(
          builder: (context, cart, _) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.sand300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ưu Đãi Dành Cho Nàng 🎟️',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...CartProvider.availableVouchers.map((v) => _buildVoucherTicket(context, ctx, cart, v)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Một "vé" voucher: cuống trái màu đất mang nhãn giảm, thân phải là mô tả + nút áp dụng.
  Widget _buildVoucherTicket(BuildContext screenContext, BuildContext sheetContext, CartProvider cart, VoucherInfo v) {
    final isApplied = cart.appliedVoucher == v.code;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isApplied ? AppColors.clay500 : AppColors.sand200),
        boxShadow: AppColors.cardShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cuống vé bên trái
            Container(
              width: 82,
              decoration: const BoxDecoration(
                color: AppColors.clay500,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_offer, color: Colors.white, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      v.badge,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            // Thân vé bên phải
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.sand100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            v.code,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.clay700, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      v.title,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      v.description,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.mute, height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: isApplied
                          ? OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.clay600,
                                side: const BorderSide(color: AppColors.clay500),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                cart.removeVoucher();
                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(screenContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã gỡ mã "${v.code}"'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_circle, size: 16),
                              label: const Text('Đang áp dụng • Gỡ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.clay500,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                cart.applyVoucher(v.code);
                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(screenContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã áp dụng "${v.code}" 🎉'),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Text('Áp dụng ngay', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  // Free shipping notice with progress bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.clay50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.clay200),
                    ),
                    child: Column(
                      children: [
                        Row(
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
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (cart.subtotal / 1000000).clamp(0.0, 1.0),
                            backgroundColor: AppColors.sand200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.clay500),
                            minHeight: 4,
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
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final key = item.uniqueKey;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.sand200.withValues(alpha: 0.8)),
                          boxShadow: AppColors.cardShadow,
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
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          cart.removeItem(key);
                                        },
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
                                              onTap: () {
                                                HapticFeedback.selectionClick();
                                                cart.updateQuantity(key, item.quantity - 1);
                                              },
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
                                              onTap: () {
                                                HapticFeedback.selectionClick();
                                                cart.updateQuantity(key, item.quantity + 1);
                                              },
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

                        // Mở danh sách voucher có sẵn (dạng vé) để khỏi phải nhớ mã
                        InkWell(
                          onTap: () => _showVoucherModal(context, cart),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.clay50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.clay200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_offer_outlined, size: 18, color: AppColors.clay500),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Chọn từ ${CartProvider.availableVouchers.length} ưu đãi có sẵn',
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.clay700),
                                  ),
                                ),
                                const Icon(Icons.chevron_right, size: 20, color: AppColors.clay500),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _voucherController,
                                textCapitalization: TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: 'Hoặc nhập mã thủ công',
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.sand200.withValues(alpha: 0.8), width: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tổng thanh toán', style: TextStyle(fontSize: 11.5, color: AppColors.mute)),
                        Text(
                          Formatters.formatCurrency(cart.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.clay600),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.clay500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                          );
                        },
                        child: const Text('TIẾN HÀNH ĐẶT HÀNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
