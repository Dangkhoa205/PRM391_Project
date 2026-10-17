import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_config.dart';
import '../core/network/api_exception.dart';
import '../models/auth_models.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  UserModel? _currentUser;
  AccountInfo? _accountInfo;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  AccountInfo? get accountInfo => _accountInfo;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const String _keyUserData = 'app_user_data';

  AuthProvider() {
    // Khi phiên bị thu hồi (refresh thất bại / đổi mật khẩu ở nơi khác / admin khoá),
    // ApiService đã xoá token — ở đây dọn luôn user để UI về trạng thái khách.
    _api.onSessionExpired = _handleSessionExpired;
    _initSession();
  }

  void _handleSessionExpired() {
    _currentUser = null;
    _accountInfo = null;
    SharedPreferences.getInstance().then((p) => p.remove(_keyUserData));
    notifyListeners();
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

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.post(
        ApiConstants.login,
        body: {
          'email': email.trim(),
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

  /// Bước 1 đăng ký: gửi hồ sơ → BE gửi OTP qua email, trả [RegistrationInit].
  /// CHƯA tạo tài khoản, CHƯA có token. Trả null nếu lỗi (đọc [errorMessage]).
  /// Dùng lại hàm này cho nút "Gửi lại mã" — nhớ ghi đè registrationId mới.
  Future<RegistrationInit?> registerInit(RegisterForm form) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.post(
        ApiConstants.register,
        body: {
          'email': form.email.trim(),
          'password': form.password,
          'fullName': form.fullName.trim(),
          'phone': form.phone.trim(),
        },
        requiresAuth: false,
      );

      _isLoading = false;
      notifyListeners();
      if (result is Map<String, dynamic>) {
        return RegistrationInit.fromJson(result);
      }
      _errorMessage = 'Phản hồi không hợp lệ từ máy chủ.';
      return null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Lỗi kết nối máy chủ. Vui lòng thử lại.';
      debugPrint('[AuthProvider] registerInit error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  /// Bước 2 đăng ký: xác minh OTP → nếu đúng, BE tạo tài khoản + trả token.
  /// Trả [RegVerifyOutcome] để màn OTP biết nên làm gì (ở lại / gửi lại / về màn đăng ký).
  Future<RegVerifyOutcome> verifyRegistration({
    required String registrationId,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.post(
        ApiConstants.verifyRegistration,
        body: {'registrationId': registrationId, 'otp': otp.trim()},
        requiresAuth: false,
      );

      if (result is Map<String, dynamic> && result['accessToken'] != null) {
        await _api.setTokens(
          accessToken: result['accessToken'] as String,
          refreshToken: (result['refreshToken'] as String?) ?? '',
        );
        await fetchProfile(); // BE đã lưu fullName/phone lúc đăng ký nên hồ sơ có sẵn
        _isLoading = false;
        notifyListeners();
        return RegVerifyOutcome.success;
      }

      _isLoading = false;
      _errorMessage = 'Phản hồi không hợp lệ từ máy chủ.';
      notifyListeners();
      return RegVerifyOutcome.error;
    } on ApiException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      final m = e.message.toLowerCase();
      if (e.statusCode == 429 || m.contains('too many')) return RegVerifyOutcome.rateLimited;
      if (m.contains('registration session has expired')) return RegVerifyOutcome.sessionExpired;
      if (e.statusCode == 409) return RegVerifyOutcome.sessionExpired;
      if (m.contains('verification code has expired')) return RegVerifyOutcome.codeExpired;
      if (m.contains('incorrect verification code')) return RegVerifyOutcome.wrongCode;
      return RegVerifyOutcome.error;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi kết nối máy chủ. Vui lòng thử lại.';
      notifyListeners();
      return RegVerifyOutcome.error;
    }
  }

  /// Đăng nhập bằng Google: mở popup chọn tài khoản → lấy idToken → gửi BE (/auth/google).
  /// Toàn bộ tương tác với Google gói trong provider để UI chỉ cần gọi 1 hàm.
  Future<GoogleSignInOutcome> signInWithGoogle() async {
    if (!AppConfig.isGoogleConfigured) {
      _errorMessage = 'Ứng dụng chưa cấu hình Google (thiếu GOOGLE_CLIENT_ID).';
      notifyListeners();
      return GoogleSignInOutcome.error;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gsi = GoogleSignIn(
        serverClientId: AppConfig.googleServerClientId, // Web client ID, để lấy idToken cho BE
        scopes: const ['email', 'profile'],
      );
      await gsi.signOut(); // luôn hiện màn chọn tài khoản, tránh dính account cũ

      final account = await gsi.signIn();
      if (account == null) {
        _isLoading = false;
        notifyListeners();
        return GoogleSignInOutcome.cancelled; // người dùng tự huỷ
      }

      final gAuth = await account.authentication;
      final idToken = gAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        _isLoading = false;
        _errorMessage = 'Không lấy được idToken từ Google.';
        notifyListeners();
        return GoogleSignInOutcome.error;
      }

      final result = await _api.post(
        ApiConstants.google,
        body: {'idToken': idToken},
        requiresAuth: false,
      );

      if (result is Map<String, dynamic> && result['accessToken'] != null) {
        await _api.setTokens(
          accessToken: result['accessToken'] as String,
          refreshToken: (result['refreshToken'] as String?) ?? '',
        );
        await fetchProfile();
        _isLoading = false;
        notifyListeners();
        return GoogleSignInOutcome.success;
      }

      _isLoading = false;
      _errorMessage = 'Phản hồi không hợp lệ từ máy chủ.';
      notifyListeners();
      return GoogleSignInOutcome.error;
    } on ApiException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return GoogleSignInOutcome.error;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Đăng nhập Google thất bại. Vui lòng thử lại.';
      debugPrint('[AuthProvider] googleSignIn error: $e');
      notifyListeners();
      return GoogleSignInOutcome.error;
    }
  }

  /// Quên mật khẩu — bước 1. BE LUÔN trả 200 (không lộ email có tồn tại hay không).
  /// Trả true nghĩa là "đã nhận yêu cầu" → cứ sang màn nhập OTP.
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _api.post(ApiConstants.forgotPassword, body: {'email': email.trim()}, requiresAuth: false);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Lỗi kết nối máy chủ. Vui lòng thử lại.';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Quên mật khẩu — bước 2. Đổi OTP lấy "vé" (ticket) sống 5 phút.
  Future<ResetOtpResult> verifyResetOtp({required String email, required String otp}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _api.post(
        ApiConstants.verifyOtp,
        body: {'email': email.trim(), 'otp': otp.trim()},
        requiresAuth: false,
      );
      _isLoading = false;
      notifyListeners();
      if (result is Map<String, dynamic> && result['ticket'] != null) {
        return ResetOtpResult(RegVerifyOutcome.success, result['ticket'] as String);
      }
      _errorMessage = 'Phản hồi không hợp lệ từ máy chủ.';
      return ResetOtpResult(RegVerifyOutcome.error, null);
    } on ApiException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      final m = e.message.toLowerCase();
      if (e.statusCode == 429 || m.contains('too many')) return ResetOtpResult(RegVerifyOutcome.rateLimited, null);
      if (m.contains('expired')) return ResetOtpResult(RegVerifyOutcome.codeExpired, null);
      if (m.contains('incorrect')) return ResetOtpResult(RegVerifyOutcome.wrongCode, null);
      return ResetOtpResult(RegVerifyOutcome.error, null);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi kết nối máy chủ. Vui lòng thử lại.';
      notifyListeners();
      return ResetOtpResult(RegVerifyOutcome.error, null);
    }
  }

  /// Quên mật khẩu — bước 3. Đặt mật khẩu mới bằng vé. Thành công ⇒ BE thu hồi mọi phiên.
  Future<ResetPasswordOutcome> resetPassword({required String ticket, required String newPassword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _api.post(
        ApiConstants.resetPassword,
        body: {'ticket': ticket, 'newPassword': newPassword},
        requiresAuth: false,
      );
      // Mọi phiên bị thu hồi — dọn luôn token/user nếu đang có.
      await _api.clearTokens();
      _currentUser = null;
      _accountInfo = null;
      _isLoading = false;
      notifyListeners();
      return ResetPasswordOutcome.success;
    } on ApiException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      if (e.statusCode == 401) return ResetPasswordOutcome.ticketExpired;
      if (e.statusCode == 403) return ResetPasswordOutcome.forbidden;
      if (e.statusCode == 400) return ResetPasswordOutcome.weakPassword;
      return ResetPasswordOutcome.error;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi kết nối máy chủ. Vui lòng thử lại.';
      notifyListeners();
      return ResetPasswordOutcome.error;
    }
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
    // Thông tin tài khoản (provider, hasPassword) cho màn Bảo mật.
    await _fetchAccountInfo();
  }

  Future<void> _fetchAccountInfo() async {
    try {
      final r = await _api.get(ApiConstants.accountMe, requiresAuth: true);
      if (r is Map<String, dynamic>) {
        _accountInfo = AccountInfo.fromJson(r);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AuthProvider] fetchAccountMe error: $e');
    }
  }

  /// Đổi email — cần xác minh mật khẩu hiện tại. Thành công ⇒ BE thu hồi mọi phiên ⇒
  /// dọn token/user để buộc đăng nhập lại bằng email mới.
  Future<bool> changeEmail({required String email, required String currentPassword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _api.patch(
        ApiConstants.accountMe,
        body: {'email': email.trim(), 'currentPassword': currentPassword},
      );
      await _api.clearTokens();
      _currentUser = null;
      _accountInfo = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Đổi email thất bại. Vui lòng thử lại.';
    }
    _isLoading = false;
    notifyListeners();
    return false;
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
          // Backend đổi mật khẩu xác minh bằng mật khẩu hiện tại (field 'currentPassword').
          // 'confirmPassword' chỉ kiểm khớp ở client, KHÔNG gửi lên BE.
          'currentPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
      // Đổi mật khẩu thành công ⇒ BE thu hồi MỌI phiên ⇒ dọn token/user, buộc đăng nhập lại.
      await _api.clearTokens();
      _currentUser = null;
      _accountInfo = null;
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
        body: {'token': _api.refreshToken},
      );
    } catch (e) {
      debugPrint('[AuthProvider] Logout BE error (ignored): $e');
    }

    await _api.clearTokens();
    _currentUser = null;
    _accountInfo = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserData);
    notifyListeners();
  }

  Future<void> logoutAll() async {
    try {
      await _api.post(
        ApiConstants.logoutAll,
        body: {'token': _api.refreshToken},
      );
    } catch (e) {
      debugPrint('[AuthProvider] LogoutAll BE error (ignored): $e');
    }

    await _api.clearTokens();
    _currentUser = null;
    _accountInfo = null;
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
