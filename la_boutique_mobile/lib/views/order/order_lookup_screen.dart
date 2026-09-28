import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class OrderLookupScreen extends StatefulWidget {
  const OrderLookupScreen({super.key});

  @override
  State<OrderLookupScreen> createState() => _OrderLookupScreenState();
}

class _OrderLookupScreenState extends State<OrderLookupScreen> {
  final TextEditingController _queryController = TextEditingController();
  List<OrderModel>? _searchResults;
  bool _hasSearched = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _performLookup() {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    final orderProvider = context.read<OrderProvider>();
    final results = <OrderModel>[];

    // Check by Order ID
    final singleOrder = orderProvider.getOrderById(query);
    if (singleOrder != null) {
      results.add(singleOrder);
    } else {
      // Check by Phone
      results.addAll(orderProvider.searchOrdersByPhone(query));
    }

    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Hoàn thành':
        return AppColors.success;
      case 'Đang giao hàng':
        return Colors.blue.shade700;
      case 'Đang xử lý':
        return Colors.amber.shade800;
      default:
        return AppColors.mute;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: const Text('TRA CỨU ĐƠN HÀNG'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Box
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
                  const Text(
                    'Nhập mã đơn hàng (VD: LB-90214) hoặc Số điện thoại đặt hàng:',
                    style: TextStyle(fontSize: 13, color: AppColors.mute, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _queryController,
                          decoration: InputDecoration(
                            hintText: 'VD: 0901234567 hoặc LB-90214',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onSubmitted: (_) => _performLookup(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _performLookup,
                        child: const Text('TRA CỨU', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search Results
            if (_hasSearched) ...[
              if (_searchResults == null || _searchResults!.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, size: 50, color: AppColors.sand300),
                        const SizedBox(height: 12),
                        const Text(
                          'Không tìm thấy đơn hàng nào',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Vui lòng kiểm tra lại mã đơn hàng hoặc số điện thoại',
                          style: TextStyle(fontSize: 13, color: AppColors.mute),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  'Tìm thấy ${_searchResults!.length} đơn hàng:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ink),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = _searchResults![index];
                    final statusColor = _getStatusColor(order.status);

                    return Container(
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
                              Text(
                                order.id,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.clay600),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: statusColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  order.status,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Người nhận: ${order.customerName} - ${order.phone}', style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Địa chỉ: ${order.address}', style: const TextStyle(fontSize: 12, color: AppColors.mute)),
                          const SizedBox(height: 6),
                          Text('Ngày đặt: ${Formatters.formatDate(order.createdAt)}', style: const TextStyle(fontSize: 12, color: AppColors.mute)),
                          const Divider(height: 16, color: AppColors.sand200),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${order.items.length} món sản phẩm', style: const TextStyle(fontSize: 12, color: AppColors.mute)),
                              Text(
                                Formatters.formatCurrency(order.total),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.clay600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
