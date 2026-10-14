import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const String _keyUserData = 'app_user_data';

  AuthProvider() {
    _initSession();
  }

  Future<void> _initSession() async {
    _isLoading = true;
    notifyListeners();

    await _api.init();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonStr = prefs.getString(_keyUserData);
      if (userJsonStr != null && userJsonStr.isNotEmpty) {
        _currentUser = UserModel.fromJson(jsonDecode(userJsonStr));
      }

      // If token exists, refresh profile from BE in background
      if (_api.hasToken) {
        await fetchProfile();
      }
    } catch (e) {
      debugPrint('[AuthProvider] Session load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.post(
        ApiConstants.login,
        body: {
          'usernameOrEmail': usernameOrEmail.trim(),
          'password': password,
        },
        requiresAuth: false,
      );

      if (result != null && result['accessToken'] != null) {
        await _api.setTokens(
          accessToken: result['accessToken'] as String,
          refreshToken: (result['refreshToken'] as String?) ?? '',
        );

        // Fetch full profile from BE
        await fetchProfile();

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      debugPrint('[AuthProvider] Login failed: ${e.message}');
    } catch (e) {
      _errorMessage = 'Lỗi kết nối máy chủ. Vui lòng kiểm tra kết nối mạng hoặc thử lại.';
      debugPrint('[AuthProvider] Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Create account on BE
      await _api.post(
        ApiConstants.accounts,
        body: {
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
        },
        requiresAuth: false,
      );

      // 2. Automatically log in after registration
      final loginSuccess = await login(username.trim(), password);

      // 3. If extra profile info was provided, update profile
      if (loginSuccess && (fullName != null || phone != null || address != null)) {
        await updateProfile(
          fullName: fullName ?? username,
          phone: phone ?? '',
          address: address ?? '',
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      debugPrint('[AuthProvider] Registration failed: ${e.message}');
    } catch (e) {
      _errorMessage = 'Lỗi tạo tài khoản. Vui lòng thử lại.';
      debugPrint('[AuthProvider] Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchProfile() async {
    try {
      final result = await _api.get(ApiConstants.profileMe, requiresAuth: true);
      if (result != null && result is Map<String, dynamic>) {
        _currentUser = UserModel.fromJson(result);
        await _saveUserToPrefs(_currentUser!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AuthProvider] fetchProfile error: $e');
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String address,
    DateTime? birthDate,
    String? gender,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{
        'fullName': fullName.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
      };
      if (birthDate != null) {
        body['birthDate'] = birthDate.toIso8601String().split('T').first;
      }
      if (gender != null && gender.isNotEmpty) {
        body['gender'] = gender;
      }
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        body['avatarUrl'] = avatarUrl;
      }

      final result = await _api.patch(ApiConstants.profileMe, body: body);
      if (result != null && result is Map<String, dynamic>) {
        _currentUser = UserModel.fromJson(result);
        await _saveUserToPrefs(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Không thể cập nhật hồ sơ lúc này.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.patch(
        ApiConstants.changePassword,
        body: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Đổi mật khẩu thất bại. Vui lòng thử lại.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await _api.post(
        ApiConstants.logout,
        body: {'refreshToken': _api.refreshToken},
      );
    } catch (e) {
      debugPrint('[AuthProvider] Logout BE error (ignored): $e');
    }

    await _api.clearTokens();
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserData);
    notifyListeners();
  }

  Future<void> logoutAll() async {
    try {
      await _api.post(
        ApiConstants.logoutAll,
        body: {'refreshToken': _api.refreshToken},
      );
    } catch (e) {
      debugPrint('[AuthProvider] LogoutAll BE error (ignored): $e');
    }

    await _api.clearTokens();
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserData);
    notifyListeners();
  }

  Future<void> _saveUserToPrefs(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserData, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('[AuthProvider] _saveUserToPrefs error: $e');
    }
  }
}
