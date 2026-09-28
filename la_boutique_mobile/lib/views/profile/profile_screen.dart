import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../chat/chat_screen.dart';
import '../map/store_map_screen.dart';
import '../order/order_lookup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: const Text('TÀI KHOẢN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sand200),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.clay100,
                    child: Text(
                      user != null ? user.name.substring(0, 1).toUpperCase() : 'G',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.clay600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null ? user.name : 'Khách vãng lai',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user != null ? user.email : 'Đăng nhập để nhận ưu đãi',
                          style: const TextStyle(fontSize: 12, color: AppColors.mute),
                        ),
                        if (user != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.phone,
                            style: const TextStyle(fontSize: 12, color: AppColors.clay600, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (user == null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      child: const Text('Đăng nhập', style: TextStyle(fontSize: 11)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions List
            _buildSectionCard(
              title: 'QUẢN LÝ TIỆN ÍCH',
              children: [
                _buildMenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Tra cứu & Quản lý đơn hàng',
                  subtitle: 'Theo dõi hành trình đơn hàng theo SĐT / Mã đơn',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderLookupScreen()));
                  },
                ),
                _buildMenuItem(
                  icon: Icons.storefront_outlined,
                  title: 'Hệ thống showroom La Boutique',
                  subtitle: 'Xem vị trí bản đồ cửa hàng & chỉ đường',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreMapScreen()));
                  },
                ),
                _buildMenuItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Tư vấn viên trực tuyến (Live Chat)',
                  subtitle: 'Hỏi đáp kích thước và chất liệu thời trang',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Policies & Information
            _buildSectionCard(
              title: 'THÔNG TIN THƯƠNG HIỆU',
              children: [
                _buildMenuItem(
                  icon: Icons.straighten_outlined,
                  title: 'Bảng quy đổi kích cỡ (Size Guide)',
                  subtitle: 'Chuẩn số đo phom dáng nữ La Boutique',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Bảng chuẩn kích thước'),
                        content: const Text(
                          '• Size S: Dưới 48kg (Vòng 1 < 84cm, Vòng 2 < 66cm)\n'
                          '• Size M: 48 - 54kg (Vòng 1: 85-88cm, Vòng 2: 67-72cm)\n'
                          '• Size L: 55 - 62kg (Vòng 1: 89-94cm, Vòng 2: 73-78cm)',
                          style: TextStyle(height: 1.5),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
                        ],
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.verified_user_outlined,
                  title: 'Chính sách đổi trả trong 7 ngày',
                  subtitle: 'Đổi mới miễn phí với sản phẩm lỗi từ nhà sản xuất',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'Về La Boutique VN',
                  subtitle: 'Phiên bản Mobile v1.0.0 (Course PRM393 - FPTU)',
                  onTap: () {},
                ),
              ],
            ),

            if (user != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.red.shade300),
                    foregroundColor: Colors.red.shade700,
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('ĐĂNG XUẤT', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    auth.logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã đăng xuất tài khoản')),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sand200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.mute,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.sand100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.clay500, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.mute)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.mute),
      onTap: onTap,
    );
  }
}
