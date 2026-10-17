import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/auth_models.dart';
import '../../providers/auth_provider.dart';
import '../widgets/top_notification.dart';
import 'reset_password_screen.dart';

/// Quên mật khẩu — bước 2: nhập OTP (sống 90 giây) để đổi lấy ticket.
class ForgotOtpScreen extends StatefulWidget {
  final String email;
  const ForgotOtpScreen({super.key, required this.email});

  @override
  State<ForgotOtpScreen> createState() => _ForgotOtpScreenState();
}

class _ForgotOtpScreenState extends State<ForgotOtpScreen> {
  final _otpController = TextEditingController();
  // OTP quên mật khẩu sống 90s; nút gửi lại khoá 20s (client tự tính, BE không trả 429).
  int _expiresLeft = 90;
  int _resendLeft = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_expiresLeft > 0) _expiresLeft--;
        if (_resendLeft > 0) _resendLeft--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  String _mmss(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final res = await auth.verifyResetOtp(email: widget.email, otp: _otpController.text.trim());
    if (!mounted) return;

    switch (res.outcome) {
      case RegVerifyOutcome.success:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ResetPasswordScreen(ticket: res.ticket!)),
        );
        break;
      case RegVerifyOutcome.wrongCode:
        _otpController.clear();
        TopNotification.show(context, auth.errorMessage ?? 'Mã xác minh không đúng', success: false);
        break;
      case RegVerifyOutcome.codeExpired:
        setState(() => _expiresLeft = 0);
        TopNotification.show(context, 'Mã đã hết hạn. Nhấn "Gửi lại mã".', success: false);
        break;
      case RegVerifyOutcome.rateLimited:
        TopNotification.show(context, auth.errorMessage ?? 'Sai quá nhiều lần. Vui lòng lấy mã mới.', success: false);
        Navigator.of(context).pop(); // về bước 1 (nhập email)
        break;
      case RegVerifyOutcome.sessionExpired:
      case RegVerifyOutcome.error:
        TopNotification.show(context, auth.errorMessage ?? 'Có lỗi xảy ra, thử lại.', success: false);
        break;
    }
  }

  Future<void> _resend() async {
    if (_resendLeft > 0) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.forgotPassword(widget.email);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _expiresLeft = 90;
        _resendLeft = 20;
        _otpController.clear();
      });
      _startTimer();
      TopNotification.show(context, 'Đã gửi lại mã (nếu email tồn tại).');
    } else {
      TopNotification.show(context, auth.errorMessage ?? 'Không gửi lại được mã.', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final expired = _expiresLeft <= 0;
    final canVerify = _otpController.text.trim().length == 6 && !expired && !isLoading;

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(title: const Text('NHẬP MÃ XÁC MINH'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 56, color: AppColors.clay500),
              const SizedBox(height: 16),
              Text('Xác minh email', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 13, color: AppColors.mute, height: 1.4),
                  children: [
                    const TextSpan(text: 'Nhập mã 6 số đã gửi tới\n'),
                    TextSpan(text: widget.email, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                onChanged: (_) => setState(() {}),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 28, letterSpacing: 10, fontWeight: FontWeight.bold, color: AppColors.ink),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  hintStyle: const TextStyle(letterSpacing: 10, color: AppColors.sand300),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.sand300)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                expired ? 'Mã đã hết hạn' : 'Mã hết hạn sau ${_mmss(_expiresLeft)}',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: expired ? Colors.red : AppColors.clay600),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.clay500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: canVerify ? _verify : null,
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('XÁC NHẬN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa nhận được mã? ', style: TextStyle(color: AppColors.mute, fontSize: 13)),
                  _resendLeft > 0
                      ? Text('Gửi lại sau ${_resendLeft}s', style: const TextStyle(color: AppColors.mute, fontSize: 13, fontWeight: FontWeight.w600))
                      : GestureDetector(
                          onTap: isLoading ? null : _resend,
                          child: const Text('Gửi lại mã', style: TextStyle(color: AppColors.clay600, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline)),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
