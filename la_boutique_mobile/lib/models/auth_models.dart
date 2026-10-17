/// Dữ liệu một lần đăng ký (giữ để gửi lại mã mà không bắt người dùng nhập lại).
class RegisterForm {
  final String email;
  final String password;
  final String fullName;
  final String phone;

  const RegisterForm({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
  });
}

/// Kết quả bước 1 (POST /auth/register) — CHƯA có token.
class RegistrationInit {
  final String registrationId;
  final String email;
  final int expiresIn;  // giây mã sống
  final int resendAfter; // giây khoá nút gửi lại

  RegistrationInit({
    required this.registrationId,
    required this.email,
    required this.expiresIn,
    required this.resendAfter,
  });

  factory RegistrationInit.fromJson(Map<String, dynamic> j) => RegistrationInit(
        registrationId: j['registrationId'].toString(),
        email: (j['email'] ?? '').toString(),
        expiresIn: (j['expiresIn'] as num?)?.toInt() ?? 600,
        resendAfter: (j['resendAfter'] as num?)?.toInt() ?? 20,
      );
}

/// Kết quả bước 2 (verify OTP) — để màn OTP biết phản ứng thế nào.
enum RegVerifyOutcome {
  success,       // tạo tài khoản + có token → vào Home
  wrongCode,     // sai mã, cho nhập lại (còn tối đa 5 lần)
  codeExpired,   // mã hết hạn nhưng hồ sơ còn → cho "Gửi lại"
  sessionExpired,// hồ sơ bay (quá 10 phút / email bị chiếm) → về màn Đăng ký
  rateLimited,   // sai 5 lần → huỷ → về màn Đăng ký
  error,         // lỗi khác
}

/// Kết quả verify OTP của luồng QUÊN MẬT KHẨU (bước 2). Dùng lại [RegVerifyOutcome]
/// (success/wrongCode/codeExpired/rateLimited/error) kèm [ticket] khi thành công.
class ResetOtpResult {
  final RegVerifyOutcome outcome;
  final String? ticket;
  ResetOtpResult(this.outcome, this.ticket);
}

/// Thông tin định danh tài khoản (GET /accounts/me) — khác với hồ sơ (/profiles/me).
/// Dùng để quyết định màn Bảo mật: tài khoản Google thuần `hasPassword=false` → "Đặt mật khẩu".
class AccountInfo {
  final String email;
  final String? roleName;
  final String provider; // 'LOCAL' | 'GOOGLE'
  final bool hasPassword;
  final String status;

  AccountInfo({
    required this.email,
    this.roleName,
    required this.provider,
    required this.hasPassword,
    required this.status,
  });

  bool get isGoogle => provider.toUpperCase() == 'GOOGLE';

  factory AccountInfo.fromJson(Map<String, dynamic> j) => AccountInfo(
        email: (j['email'] ?? '').toString(),
        roleName: j['roleName'] as String?,
        provider: (j['provider'] ?? 'LOCAL').toString(),
        hasPassword: j['hasPassword'] as bool? ?? true,
        status: (j['status'] ?? 'ACTIVE').toString(),
      );
}

/// Kết quả đăng nhập Google.
enum GoogleSignInOutcome {
  success,   // có token → vào Home
  cancelled, // người dùng tự huỷ popup chọn tài khoản → im lặng, không báo lỗi
  error,     // lỗi thật (sai cấu hình, mạng, BE từ chối...)
}

/// Kết quả bước 3 (đặt lại mật khẩu bằng ticket).
enum ResetPasswordOutcome {
  success,        // đổi xong → mọi phiên bị thu hồi → về Đăng nhập
  ticketExpired,  // vé hết hạn / đã dùng (401) → làm lại từ đầu
  forbidden,      // tài khoản bị khoá (403)
  weakPassword,   // mật khẩu không hợp lệ (400)
  error,
}
