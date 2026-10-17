import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/auth_models.dart';
import '../../providers/auth_provider.dart';
import '../widgets/top_notification.dart';

/// Màn nhập OTP (bước 2 đăng ký). Nhận [init] (có registrationId + thời gian) và [form]
/// (để gửi lại mã mà không bắt nhập lại).
class OtpScreen extends StatefulWidget {
  final RegistrationInit init;
  final RegisterForm form;

  const OtpScreen({super.key, required this.init, required this.form});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  late String _registrationId;
  late int _expiresLeft;   // giây còn lại của mã
  late int _resendLeft;    // giây còn lại trước khi được gửi lại
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _registrationId = widget.init.registrationId;
    _expiresLeft = widget.init.expiresIn;
    _resendLeft = widget.init.resendAfter;
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

  String _mmss(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final outcome = await auth.verifyRegistration(
      registrationId: _registrationId,
      otp: _otpController.text.trim(),
    );
    if (!mounted) return;

    switch (outcome) {
      case RegVerifyOutcome.success:
        TopNotification.show(context, 'Đăng ký thành công! Chào mừng nàng đến với La Boutique ✨');
        Navigator.of(context).popUntil((route) => route.isFirst); // về Home
        break;
      case RegVerifyOutcome.wrongCode:
        _otpController.clear();
        TopNotification.show(context, auth.errorMessage ?? 'Mã xác minh không đúng', success: false);
        break;
      case RegVerifyOutcome.codeExpired:
        setState(() => _expiresLeft = 0);
        TopNotification.show(context, 'Mã đã hết hạn. Nhấn "Gửi lại mã".', success: false);
        break;
      case RegVerifyOutcome.sessionExpired:
      case RegVerifyOutcome.rateLimited:
        TopNotification.show(
          context,
          auth.errorMessage ?? 'Phiên đăng ký đã hết. Vui lòng đăng ký lại.',
          success: false,
        );
        Navigator.of(context).pop(); // quay lại màn Đăng ký
        break;
      case RegVerifyOutcome.error:
        TopNotification.show(context, auth.errorMessage ?? 'Có lỗi xảy ra, thử lại.', success: false);
        break;
    }
  }

  Future<void> _resend() async {
    if (_resendLeft > 0) return;
    final auth = context.read<AuthProvider>();
    final init = await auth.registerInit(widget.form);
    if (!mounted) return;

    if (init != null) {
      setState(() {
        _registrationId = init.registrationId; // 🔴 ghi đè registrationId mới
        _expiresLeft = init.expiresIn;
        _resendLeft = init.resendAfter;
        _otpController.clear();
      });
      _startTimer();
      TopNotification.show(context, 'Đã gửi lại mã xác minh tới email của nàng.');
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
      appBar: AppBar(title: const Text('XÁC MINH EMAIL'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 56, color: AppColors.clay500),
              const SizedBox(height: 16),
              Text(
                'Nhập mã xác minh',
                style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 13, color: AppColors.mute, height: 1.4),
                  children: [
                    const TextSpan(text: 'Mã gồm 6 chữ số đã được gửi tới\n'),
                    TextSpan(text: widget.init.email, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Ô nhập OTP
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

              // Đếm ngược hạn mã
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
                    elevation: 2,
                  ),
                  onPressed: canVerify ? _verify : null,
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('XÁC NHẬN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                ),
              ),
              const SizedBox(height: 16),

              // Gửi lại mã
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa nhận được mã? ', style: TextStyle(color: AppColors.mute, fontSize: 13)),
                  _resendLeft > 0
                      ? Text('Gửi lại sau ${_resendLeft}s', style: const TextStyle(color: AppColors.mute, fontSize: 13, fontWeight: FontWeight.w600))
                      : GestureDetector(
                          onTap: isLoading ? null : _resend,
                          child: const Text(
                            'Gửi lại mã',
                            style: TextStyle(color: AppColors.clay600, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline),
                          ),
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
