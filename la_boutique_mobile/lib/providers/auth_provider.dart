import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUserSession();
  }

  void _loadUserSession() {
    // Set default demo user for easy testing & demoing
    _currentUser = UserModel(
      id: 'usr_001',
      name: 'Nàng Thơ La Boutique',
      email: 'customer@laboutique.vn',
      phone: '0901234567',
      address: '72 Lê Thánh Tôn, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
    );
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600)); // Simulate API delay

    if (email.trim().isNotEmpty && password.length >= 4) {
      _currentUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@').first.toUpperCase(),
        email: email.trim(),
        phone: '0901234567',
        address: '72 Lê Thánh Tôn, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      address: address,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    if (_currentUser == null) return;
    _currentUser = UserModel(
      id: _currentUser!.id,
      name: name,
      email: _currentUser!.email,
      phone: phone,
      address: address,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }
}
