import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/auth_models.dart';
import '../../providers/auth_provider.dart';
import '../widgets/top_notification.dart';

/// Quên mật khẩu — bước 3: đặt mật khẩu mới bằng [ticket].
class ResetPasswordScreen extends StatefulWidget {
  final String ticket;
  const ResetPasswordScreen({super.key, required this.ticket});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 8 || v.length > 100) return 'Mật khẩu từ 8 đến 100 ký tự';
    if (!RegExp(r'[A-Z]').hasMatch(v) || !RegExp(r'[a-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Cần có chữ hoa, chữ thường và số';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final outcome = await auth.resetPassword(ticket: widget.ticket, newPassword: _passwordController.text);
    if (!mounted) return;

    switch (outcome) {
      case ResetPasswordOutcome.success:
        TopNotification.show(context, 'Đặt lại mật khẩu thành công. Vui lòng đăng nhập lại.');
        Navigator.of(context).popUntil((route) => route.isFirst); // về Home; người dùng đăng nhập lại
        break;
      case ResetPasswordOutcome.ticketExpired:
        TopNotification.show(context, 'Phiên đặt lại đã hết hạn. Vui lòng làm lại.', success: false);
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case ResetPasswordOutcome.forbidden:
        TopNotification.show(context, auth.errorMessage ?? 'Tài khoản đang bị hạn chế.', success: false);
        break;
      case ResetPasswordOutcome.weakPassword:
        TopNotification.show(context, auth.errorMessage ?? 'Mật khẩu chưa đạt yêu cầu.', success: false);
        break;
      case ResetPasswordOutcome.error:
        TopNotification.show(context, auth.errorMessage ?? 'Có lỗi xảy ra, thử lại.', success: false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(title: const Text('ĐẶT LẠI MẬT KHẨU'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tạo mật khẩu mới', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
                const SizedBox(height: 8),
                const Text(
                  'Sau khi đổi, mọi thiết bị đang đăng nhập sẽ bị đăng xuất để bảo đảm an toàn.',
                  style: TextStyle(fontSize: 13, color: AppColors.mute, height: 1.4),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới *',
                    hintText: '≥ 8 ký tự, có hoa + thường + số',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.sand300)),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới *',
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.sand300)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                    if (v != _passwordController.text) return 'Mật khẩu xác nhận không khớp';
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
                        : const Text('ĐẶT LẠI MẬT KHẨU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
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
