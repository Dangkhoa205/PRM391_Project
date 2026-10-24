import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants/api_constants.dart';
import '../models/store.dart';
import '../services/api_service.dart';

/// Kết quả xin định vị — màn map dựa vào đây để báo đúng thông điệp cho người dùng.
enum LocateOutcome { success, denied, deniedForever, serviceDisabled, error }

/// Danh sách cửa hàng/chi nhánh cho màn bản đồ — nối BE thật (`GET /stores`, công khai).
///
/// BE đã seed sẵn 4 chi nhánh (Q1, Q3, Thủ Đức, Tân Bình). Chỉ có vài cửa hàng nên
/// tải hết một lần, không phân trang thêm; "cửa hàng gần nhất" (nếu làm) tính luôn ở FE.
class StoreProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  final List<StoreModel> _stores = [];
  bool _isLoading = false;
  String? _errorMessage;
  Position? _userPosition; // vị trí hiện tại của người dùng (null nếu chưa định vị)

  List<StoreModel> get stores => List.unmodifiable(_stores);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _stores.isNotEmpty;
  Position? get userPosition => _userPosition;
  bool get hasUserPosition => _userPosition != null;

  Future<void> fetchStores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _api.get(
        ApiConstants.stores,
        queryParams: {'size': 50},
        requiresAuth: false, // công khai
      );
      if (result is Map<String, dynamic> && result['content'] is List) {
        _stores
          ..clear()
          ..addAll((result['content'] as List)
              .map((e) => StoreModel.fromJson(e as Map<String, dynamic>)));
      }
    } catch (e) {
      _errorMessage = 'Không tải được danh sách cửa hàng. Vui lòng thử lại.';
      debugPrint('[StoreProvider] fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Nếu quyền vị trí ĐÃ được cấp từ trước thì lấy vị trí ngay mà KHÔNG hiện popup xin quyền.
  /// Dùng khi mở màn để tự nhảy tới chi nhánh gần nhất một cách "êm", không làm phiền.
  Future<bool> locateSilently() async {
    final perm = await Geolocator.checkPermission();
    if (perm != LocationPermission.always && perm != LocationPermission.whileInUse) {
      return false;
    }
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    return _readPosition();
  }

  /// Luồng đầy đủ khi người dùng bấm "Gần tôi": kiểm tra GPS + xin quyền + lấy vị trí.
  Future<LocateOutcome> locateUser() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocateOutcome.serviceDisabled;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) return LocateOutcome.denied;
    if (perm == LocationPermission.deniedForever) return LocateOutcome.deniedForever;

    final ok = await _readPosition();
    return ok ? LocateOutcome.success : LocateOutcome.error;
  }

  Future<bool> _readPosition() async {
    try {
      _userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[StoreProvider] read position error: $e');
      return false;
    }
  }

  /// Khoảng cách (mét) từ người dùng tới một cửa hàng; null nếu chưa định vị.
  double? distanceMetersTo(StoreModel store) {
    final p = _userPosition;
    if (p == null) return null;
    return Geolocator.distanceBetween(
      p.latitude, p.longitude, store.latitude, store.longitude,
    );
  }

  /// Cửa hàng gần người dùng nhất; null nếu chưa định vị hoặc chưa có cửa hàng nào.
  StoreModel? nearestStore() {
    if (_userPosition == null || _stores.isEmpty) return null;
    StoreModel? best;
    double bestDist = double.infinity;
    for (final s in _stores) {
      final d = distanceMetersTo(s)!;
      if (d < bestDist) {
        bestDist = d;
        best = s;
      }
    }
    return best;
  }
}
