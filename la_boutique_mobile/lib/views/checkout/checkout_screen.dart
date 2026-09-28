import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  String _paymentMethod = 'COD'; // 'COD' or 'BANKING'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    if (cart.cartItemsList.isEmpty) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final orderId = context.read<OrderProvider>().createOrder(
          customerName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
          items: cart.cartItemsList,
          subtotal: cart.subtotal,
          discount: cart.discountAmount,
          shippingFee: cart.shippingFee,
          total: cart.totalAmount,
          paymentMethod: _paymentMethod,
        );

    // Add in-app notification
    context.read<NotificationProvider>().addOrderNotification(orderId);

    final total = cart.totalAmount;
    final name = _nameController.text.trim();

    cart.clearCart();

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          orderId: orderId,
          totalAmount: total,
          customerName: name,
          paymentMethod: _paymentMethod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: const Text('THANH TOÁN ĐƠN HÀNG'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Info Section
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
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.clay500, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'THÔNG TIN GIAO HÀNG',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên người nhận *',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại liên hệ *',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (val.trim().length < 9) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ nhận hàng chi tiết *',
                        prefixIcon: Icon(Icons.home_outlined, size: 20),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú cho shipper (tùy chọn)',
                        prefixIcon: Icon(Icons.note_alt_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment Methods
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
                      children: [
                        const Icon(Icons.payment_outlined, color: AppColors.clay500, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'PHƯƠNG THỨC THANH TOÁN',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // COD Option
                    RadioListTile<String>(
                      value: 'COD',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                      activeColor: AppColors.clay500,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Thanh toán khi nhận hàng (COD)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Nàng kiểm tra hàng và thanh toán tiền mặt cho shipper', style: TextStyle(fontSize: 12, color: AppColors.mute)),
                    ),
                    const Divider(height: 12, color: AppColors.sand200),

                    // VietQR Option
                    RadioListTile<String>(
                      value: 'BANKING',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                      activeColor: AppColors.clay500,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Chuyển khoản VietQR 24/7', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Quét mã QR tự động điền số tiền và nội dung chuyển khoản', style: TextStyle(fontSize: 12, color: AppColors.mute)),
                    ),

                    // Dynamic VietQR Box
                    if (_paymentMethod == 'BANKING') ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.clay50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.clay200),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Quét mã QR để chuyển khoản nhanh:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.clay700),
                            ),
                            const SizedBox(height: 10),
                            // Simulated VietQR Image
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.sand300),
                              ),
                              child: Column(
                                children: [
                                  Image.network(
                                    'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=LA_BOUTIQUE_VN_ORDER_${cart.totalAmount.toInt()}',
                                    width: 140,
                                    height: 140,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.qr_code_2, size: 100, color: AppColors.ink),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text('Ngân hàng: MBBank', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  const Text('Số TK: 0901234567', style: TextStyle(fontSize: 11, color: AppColors.clay600, fontWeight: FontWeight.bold)),
                                  const Text('Chủ TK: LA BOUTIQUE VN', style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Order Summary Breakdown
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
                    Text(
                      'TỔNG KẾT ĐƠN HÀNG (${cart.itemCount} sản phẩm)',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tạm tính', style: TextStyle(color: AppColors.mute, fontSize: 13)),
                        Text(Formatters.formatCurrency(cart.subtotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (cart.discountAmount > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Voucher giảm giá', style: TextStyle(color: AppColors.success, fontSize: 13)),
                          Text('-${Formatters.formatCurrency(cart.discountAmount)}',
                              style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Phí giao hàng', style: TextStyle(color: AppColors.mute, fontSize: 13)),
                        Text(
                          cart.shippingFee == 0 ? 'MIỄN PHÍ' : Formatters.formatCurrency(cart.shippingFee),
                          style: TextStyle(
                            color: cart.shippingFee == 0 ? AppColors.success : AppColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.sand200),
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

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isSubmitting ? null : _submitOrder,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'XÁC NHẬN ĐẶT HÀNG (${Formatters.formatCurrency(cart.totalAmount)})',
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
