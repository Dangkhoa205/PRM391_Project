import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  // Coordinates for La Boutique Flagship (Le Thanh Ton, District 1, HCMC)
  final LatLng _storeLocation = const LatLng(10.7769, 106.7009);
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: const Text('HỆ THỐNG CỬA HÀNG'),
      ),
      body: Stack(
        children: [
          // OpenStreetMap with flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _storeLocation,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.laboutique.mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _storeLocation,
                    width: 60,
                    height: 60,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.clay500,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        CustomPaint(
                          size: const Size(10, 6),
                          painter: _TrianglePainter(color: AppColors.clay500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Map Control Buttons (Recenter)
          Positioned(
            right: 16,
            top: 16,
            child: FloatingActionButton.small(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.ink,
              onPressed: () {
                _mapController.move(_storeLocation, 16.0);
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          // Bottom Store Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sand200),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withOpacity(0.12),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.clay100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'FLAGSHIP STORE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.clay700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      const Text(
                        'Đang mở cửa',
                        style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'La Boutique Showroom - Quận 1',
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.clay500),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '72 Lê Thánh Tôn, Bến Nghé, Quận 1, TP. Hồ Chí Minh',
                          style: TextStyle(fontSize: 13, color: AppColors.mute),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: AppColors.clay500),
                      SizedBox(width: 6),
                      Text('09:00 - 22:00 (Tất cả các ngày trong tuần)', style: TextStyle(fontSize: 12, color: AppColors.mute)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: AppColors.clay500),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đang kết nối Hotline: 0901 234 567...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Gọi Hotline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã mở hướng dẫn chỉ đường đến showroom La Boutique'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions, size: 16),
                          label: const Text('Chỉ đường', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
