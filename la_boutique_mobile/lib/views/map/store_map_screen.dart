import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../models/store.dart';
import '../../providers/store_provider.dart';

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  // Tâm mặc định TP.HCM khi chưa tải xong cửa hàng (hiển thị bao quát các chi nhánh).
  static const LatLng _hcmCenter = LatLng(10.782, 106.695);
  static const double _overviewZoom = 11.5;
  static const double _focusZoom = 16.0;

  late final MapController _mapController;
  String? _selectedId; // id cửa hàng đang chọn (hiện card dưới)
  bool _locating = false; // đang lấy vị trí (hiện spinner trên nút "Gần tôi")

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Tải danh sách, rồi tự định vị "êm" nếu người dùng đã cấp quyền từ trước.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<StoreProvider>();
      await provider.fetchStores();
      if (!mounted) return;
      final located = await provider.locateSilently();
      if (!mounted) return;
      if (located) {
        final nearest = provider.nearestStore();
        if (nearest != null) _selectStore(nearest);
      }
    });
  }

  void _selectStore(StoreModel store, {bool moveCamera = true}) {
    setState(() => _selectedId = store.id);
    if (moveCamera) {
      _mapController.move(LatLng(store.latitude, store.longitude), _focusZoom);
    }
  }

  /// Nút "Gần tôi": xin quyền + lấy vị trí + nhảy tới chi nhánh gần nhất.
  Future<void> _locateNearest() async {
    final provider = context.read<StoreProvider>();
    setState(() => _locating = true);
    final outcome = await provider.locateUser();
    if (!mounted) return;
    setState(() => _locating = false);

    switch (outcome) {
      case LocateOutcome.success:
        final nearest = provider.nearestStore();
        if (nearest != null) {
          _selectStore(nearest);
          final d = provider.distanceMetersTo(nearest);
          _toast('Chi nhánh gần bạn nhất: ${nearest.storeName}'
              '${d != null ? ' · ${_fmtDistance(d)}' : ''}');
        }
        break;
      case LocateOutcome.serviceDisabled:
        _toast('GPS đang tắt. Vui lòng bật định vị rồi thử lại.');
        break;
      case LocateOutcome.denied:
        _toast('Bạn chưa cấp quyền vị trí.');
        break;
      case LocateOutcome.deniedForever:
        _toast('Quyền vị trí đã bị chặn. Vào Cài đặt để bật lại.');
        break;
      case LocateOutcome.error:
        _toast('Không lấy được vị trí. Vui lòng thử lại.');
        break;
    }
  }

  Future<void> _callHotline(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      _toast('Không mở được trình gọi điện cho số $phone');
    }
  }

  Future<void> _openDirections(StoreModel store) async {
    // Mở app Google Maps / trình duyệt để chỉ đường tới toạ độ cửa hàng.
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${store.latitude},${store.longitude}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _toast('Không mở được ứng dụng bản đồ');
    }
  }

  static String _fmtDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(title: const Text('HỆ THỐNG CỬA HÀNG')),
      body: Consumer<StoreProvider>(
        builder: (context, provider, _) {
          final stores = provider.stores;

          // Đồng bộ lựa chọn: lần đầu có dữ liệu thì chọn chi nhánh đầu tiên.
          if (_selectedId == null && stores.isNotEmpty) {
            _selectedId = stores.first.id;
          }
          final selected = stores
              .cast<StoreModel?>()
              .firstWhere((s) => s?.id == _selectedId, orElse: () => null);
          final selectedDistance =
              selected == null ? null : provider.distanceMetersTo(selected);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _hcmCenter,
                  initialZoom: _overviewZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.laboutique.mobile',
                  ),
                  MarkerLayer(
                    markers: [
                      // Chấm vị trí người dùng (nếu đã định vị).
                      if (provider.hasUserPosition)
                        Marker(
                          point: LatLng(
                            provider.userPosition!.latitude,
                            provider.userPosition!.longitude,
                          ),
                          width: 24,
                          height: 24,
                          child: const _UserDot(),
                        ),
                      for (final store in stores)
                        Marker(
                          point: LatLng(store.latitude, store.longitude),
                          width: 60,
                          height: 60,
                          child: _StoreMarker(
                            selected: store.id == _selectedId,
                            onTap: () => _selectStore(store),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Cụm nút điều khiển: "Gần tôi" + recenter.
              Positioned(
                right: 16,
                top: 16,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'near_me',
                      backgroundColor: AppColors.clay500,
                      foregroundColor: AppColors.white,
                      onPressed: _locating ? null : _locateNearest,
                      child: _locating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.near_me),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton.small(
                      heroTag: 'recenter',
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.ink,
                      onPressed: selected == null
                          ? null
                          : () => _mapController.move(
                                LatLng(selected.latitude, selected.longitude),
                                _focusZoom,
                              ),
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),

              // Lớp trạng thái: loading / lỗi / rỗng.
              if (provider.isLoading && stores.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (provider.errorMessage != null && stores.isEmpty)
                _ErrorBox(
                  message: provider.errorMessage!,
                  onRetry: () => provider.fetchStores(),
                )
              else if (stores.isEmpty)
                const _ErrorBox(message: 'Chưa có cửa hàng nào.'),

              // Card chi nhánh đang chọn.
              if (selected != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: _StoreCard(
                    store: selected,
                    distanceLabel: selectedDistance == null
                        ? null
                        : _fmtDistance(selectedDistance),
                    onCall: () => _callHotline(selected.phone),
                    onDirections: () => _openDirections(selected),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Chấm tròn xanh thể hiện vị trí hiện tại của người dùng.
class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }
}

/// Ghim cửa hàng trên bản đồ; chi nhánh đang chọn to & đậm hơn.
class _StoreMarker extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  const _StoreMarker({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.clay500 : AppColors.ink;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(selected ? 7 : 5),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.storefront, color: Colors.white, size: selected ? 24 : 18),
          ),
          CustomPaint(
            size: Size(selected ? 10 : 8, selected ? 6 : 5),
            painter: _TrianglePainter(color: color),
          ),
        ],
      ),
    );
  }
}

/// Card thông tin cửa hàng ở đáy màn.
class _StoreCard extends StatelessWidget {
  final StoreModel store;
  final String? distanceLabel; // "Cách bạn X" — null nếu chưa định vị
  final VoidCallback onCall;
  final VoidCallback onDirections;
  const _StoreCard({
    required this.store,
    required this.distanceLabel,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sand200.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.12),
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
                  'CHI NHÁNH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.clay700,
                  ),
                ),
              ),
              if (distanceLabel != null) ...[
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Icon(Icons.directions_walk, size: 14, color: AppColors.clay500),
                    const SizedBox(width: 2),
                    Text(
                      'Cách bạn $distanceLabel',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.clay700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              if (store.isOpen) ...[
                const Icon(Icons.access_time, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                const Text(
                  'Đang mở cửa',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            store.storeName,
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.clay500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  store.address,
                  style: const TextStyle(fontSize: 13, color: AppColors.mute),
                ),
              ),
            ],
          ),
          if (store.openingHours.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.clay500),
                const SizedBox(width: 6),
                Text(
                  store.openingHours,
                  style: const TextStyle(fontSize: 12, color: AppColors.mute),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: AppColors.clay500),
                  ),
                  onPressed: store.phone.isEmpty ? null : onCall,
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text(
                    'Gọi Hotline',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: onDirections,
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text(
                    'Chỉ đường',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Hộp báo lỗi / rỗng giữa màn, có nút thử lại tuỳ chọn.
class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorBox({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.12),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 36, color: AppColors.mute),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.ink),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
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
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => oldDelegate.color != color;
}
