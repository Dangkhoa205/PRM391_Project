import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';
import '../chat/chat_screen.dart';
import '../map/store_map_screen.dart';
import '../notification/notification_screen.dart';
import '../product/product_list_screen.dart';
import '../profile/profile_screen.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onExplorePressed() {
    setState(() => _currentIndex = 1); // Switch to Product Catalog tab
  }

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotificationProvider>();

    final tabs = [
      _HomeTab(onExplore: _onExplorePressed),
      const ProductListScreen(),
      const StoreMapScreen(),
      const NotificationScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.sand50,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.clay500,
        unselectedItemColor: AppColors.mute,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Sản phẩm',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Cửa hàng',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (notif.unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.clay500,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '${notif.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.clay500,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
              child: const Icon(Icons.chat_bubble_outline),
            )
          : null,
    );
  }
}

class _HomeTab extends StatefulWidget {
  final VoidCallback onExplore;

  const _HomeTab({required this.onExplore});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final PageController _heroController = PageController();
  int _currentHeroSlide = 0;
  Timer? _heroTimer;

  final List<String> _heroSlides = [
    'assets/images/products/sunset-main-1.jpg',
    'assets/images/products/sunset-main-3.jpg',
    'assets/images/products/sunset-main-4.jpg',
    'assets/images/products/sunset-main-5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _heroTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_heroController.hasClients) {
        final next = (_currentHeroSlide + 1) % _heroSlides.length;
        _heroController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
    final sunsetList = productProvider.sunsetCollection;
    final allProducts = productProvider.allProducts;

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'LA BOUTIQUE',
              style: GoogleFonts.playfairDisplay(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: AppColors.ink,
              ),
            ),
            const Text(
              'V I E T N A M',
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 3.5,
                fontWeight: FontWeight.w600,
                color: AppColors.clay600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            tooltip: 'Tư vấn trực tuyến',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                tooltip: 'Giỏ hàng',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
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
            // 1. Hero Auto Carousel (Matches Hero.tsx)
            SizedBox(
              height: 400,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _heroController,
                    itemCount: _heroSlides.length,
                    onPageChanged: (idx) => setState(() => _currentHeroSlide = idx),
                    itemBuilder: (context, index) {
                      return Image.asset(
                        _heroSlides[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
                  // Dark Vignette Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.ink.withValues(alpha: 0.95),
                            AppColors.ink.withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Hero Content Overlay
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tag Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 12),
                              SizedBox(width: 6),
                              Text(
                                'BỘ SƯU TẬP HÈ 2026 • SIGNATURE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'LA BOUTIQUE SUNSET',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Hành trình mùa hè của người nữ du mục — tự do, bản năng và đầy khao khát khám phá những bờ biển mới cùng lụa tơ tằm & linen tự nhiên.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        // CTA Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.clay500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          onPressed: widget.onExplore,
                          icon: const Text(
                            'KHÁM PHÁ BỘ SƯU TẬP',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8),
                          ),
                          label: const Icon(Icons.arrow_forward, size: 14),
                        ),
                        const SizedBox(height: 12),
                        // Carousel Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _heroSlides.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentHeroSlide == i ? 18 : 6,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _currentHeroSlide == i ? AppColors.clay500 : Colors.white54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. ValueStrip 4 Commitments (Matches ValueStrip.tsx)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              color: AppColors.sand100,
              child: Column(
                children: [
                  Row(
                    children: const [
                      Expanded(child: _ValueItem(icon: Icons.local_shipping_outlined, title: 'Freeship quét QR', desc: 'Chuyển khoản QR miễn phí ship')),
                      Expanded(child: _ValueItem(icon: Icons.cached, title: 'Đổi trả 7 ngày', desc: 'Hỗ trợ đổi size tận tâm')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Expanded(child: _ValueItem(icon: Icons.verified_user_outlined, title: 'Thanh toán linh hoạt', desc: 'QR freeship hoặc COD tận tay')),
                      Expanded(child: _ValueItem(icon: Icons.support_agent_outlined, title: 'Tư vấn chọn size 24/7', desc: 'Hotline & Zalo: 0901 234 567')),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Sunset Collection Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BST SUNSET SS26',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const Text(
                        '3 Thiết kế biểu tượng phiên bản giới hạn',
                        style: TextStyle(fontSize: 12, color: AppColors.mute),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductListScreen(initialCategory: 'sunset'),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text('Xem tất cả', style: TextStyle(color: AppColors.clay600, fontSize: 12, fontWeight: FontWeight.bold)),
                        Icon(Icons.chevron_right, size: 16, color: AppColors.clay600),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Sunset Items
            SizedBox(
              height: 290,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: sunsetList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 175,
                    child: ProductCard(product: sunsetList[index]),
                  );
                },
              ),
            ),

            // 4. Brand Story Section (Matches BrandStory.tsx)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.ink,
                image: const DecorationImage(
                  image: AssetImage('assets/images/products/sunset-main-4.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'CÂU CHUYỆN THƯƠNG HIỆU',
                    style: TextStyle(
                      color: AppColors.clay300,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tinh Thần La Boutique',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'LA BOUTIQUE VN sinh ra từ tình yêu với những bờ biển rực rỡ và ánh hoàng hôn ấm áp. Mỗi thiết kế là lời mời gọi nàng cất bước — tự do, bản năng và đầy khao khát khám phá những chân trời mới.',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _StatItem(value: '10+', label: 'Thiết kế độc quyền'),
                      _StatItem(value: 'COD', label: 'Thanh toán tận tay'),
                      _StatItem(value: '7 Ngày', label: 'Hỗ trợ đổi size'),
                    ],
                  ),
                ],
              ),
            ),

            // 5. All Products Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TẤT CẢ THIẾT KẾ',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const Text(
                        'Đầy đủ các mẫu áo yếm, đầm lụa và chân váy mùa hè',
                        style: TextStyle(fontSize: 12, color: AppColors.mute),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Grid of all products
            GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: allProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: allProducts[index]);
              },
            ),

            // 6. Customer Reviews Section (Matches ReviewsBoard.tsx)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              color: AppColors.sand100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NÀNG THƠ CHIA SẺ',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const Text(
                    'Những đánh giá chân thực từ khách hàng La Boutique',
                    style: TextStyle(fontSize: 12, color: AppColors.mute),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 130,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _ReviewCard(
                          name: 'Minh Anh',
                          rating: 5,
                          time: '2 tuần trước',
                          text: 'Váy lụa mặc đi biển quá đã, mát mẻ và lên form cực kỳ tôn dáng. Mình đã giới thiệu cho cả hội bạn!',
                        ),
                        SizedBox(width: 12),
                        _ReviewCard(
                          name: 'Khánh Linh',
                          rating: 5,
                          time: '1 tháng trước',
                          text: 'Chất linen thoáng mát, giặt máy nhiều lần vẫn giữ form. Màu sắc chuẩn y hình shop nhé.',
                        ),
                        SizedBox(width: 12),
                        _ReviewCard(
                          name: 'Thu Hà',
                          rating: 5,
                          time: '3 tuần trước',
                          text: 'Đầm đẹp, đường may chỉn chu. Giao hàng nhanh, đóng hộp sang xịn mịn như mua quà tặng.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ValueItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _ValueItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.clay50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.clay500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink)),
              Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.mute), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: AppColors.clay300, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String time;
  final String text;

  const _ReviewCard({
    required this.name,
    required this.rating,
    required this.time,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
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
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: List.generate(
                  rating,
                  (index) => const Icon(Icons.star, size: 12, color: Colors.amber),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(time, style: const TextStyle(fontSize: 10, color: AppColors.mute)),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, height: 1.3, color: AppColors.ink),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
