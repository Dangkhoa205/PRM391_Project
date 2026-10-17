import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../widgets/top_notification.dart';
import 'forgot_otp_screen.dart';

/// Quên mật khẩu — bước 1: nhập email để nhận mã.
///
/// Khi [prefillEmail] có giá trị (vd tài khoản Google thuần bấm "Tạo mật khẩu"),
/// email được điền sẵn và khoá lại — KHÔNG bắt người dùng nhập lại (theo doc BE mục 4B).
class ForgotPasswordScreen extends StatefulWidget {
  final String? prefillEmail;
  final bool setPasswordMode; // true = ngữ cảnh "Tạo mật khẩu" cho tài khoản Google

  const ForgotPasswordScreen({
    super.key,
    this.prefillEmail,
    this.setPasswordMode = false,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  bool get _emailLocked => (widget.prefillEmail ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefillEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final ok = await auth.forgotPassword(email);
    if (!mounted) return;

    if (ok) {
      // BE luôn 200 dù email có thật hay không — cứ sang màn OTP.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ForgotOtpScreen(email: email)),
      );
    } else {
      TopNotification.show(context, auth.errorMessage ?? 'Không gửi được mã. Thử lại.', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: Text(widget.setPasswordMode ? 'TẠO MẬT KHẨU' : 'QUÊN MẬT KHẨU'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.setPasswordMode ? 'Tạo mật khẩu cho tài khoản' : 'Lấy lại mật khẩu',
                  style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                const SizedBox(height: 8),
                Text(
                  _emailLocked
                      ? 'Mã xác minh 6 số sẽ được gửi tới email tài khoản của bạn bên dưới.'
                      : 'Nhập email tài khoản. Nếu email đã đăng ký, chúng tôi sẽ gửi một mã xác minh 6 số tới đó.',
                  style: const TextStyle(fontSize: 13, color: AppColors.mute, height: 1.4),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: _emailLocked, // email tài khoản đã biết ⇒ không cho sửa
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ Email *',
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: _emailLocked ? const Icon(Icons.lock_outline, size: 18, color: AppColors.mute) : null,
                    filled: true,
                    fillColor: _emailLocked ? AppColors.sand100 : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.sand300)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.clay500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('GỬI MÃ XÁC MINH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
