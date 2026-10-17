import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/auth_models.dart';
import '../../providers/auth_provider.dart';
import '../widgets/top_notification.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController(text: 'user@example.com');
  final _passwordController = TextEditingController(text: 'User@12345');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _accountController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Banner trên đầu, hiện đè lên trang vừa quay về (không bị pop che mất như SnackBar).
      TopNotification.show(
        context,
        'Xin chào trở lại, ${authProvider.currentUser?.name ?? "Nàng thơ"}! ✨',
      );
      Navigator.of(context).pop(true);
    } else {
      final msg = authProvider.errorMessage ?? 'Tên đăng nhập hoặc mật khẩu không chính xác';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final outcome = await authProvider.signInWithGoogle();
    if (!mounted) return;

    switch (outcome) {
      case GoogleSignInOutcome.success:
        TopNotification.show(context, 'Đăng nhập Google thành công! ✨');
        Navigator.of(context).pop(true);
        break;
      case GoogleSignInOutcome.cancelled:
        break; // người dùng tự huỷ, không báo gì
      case GoogleSignInOutcome.error:
        TopNotification.show(context, authProvider.errorMessage ?? 'Đăng nhập Google thất bại', success: false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: const Text('ĐĂNG NHẬP TÀI KHOẢN'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Brand Logo / Icon
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.clay500,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.clay500.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'LB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'LA BOUTIQUE VN',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Thời Trang Thiết Kế Hè • BST Sunset SS26',
                  style: TextStyle(fontSize: 12, color: AppColors.mute, letterSpacing: 0.5),
                ),
                const SizedBox(height: 32),

                // Username / Email field
                TextFormField(
                  controller: _accountController,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    hintText: 'Nhập email đăng nhập',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.sand300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.sand300),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu *',
                    hintText: 'Nhập mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.sand300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.sand300),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
                    return null;
                  },
                ),
                const SizedBox(height: 4),

                // Quên mật khẩu
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(color: AppColors.clay600, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Demo accounts hint
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.clay50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.clay200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.clay600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tài khoản BE mẫu (đăng nhập bằng email):\n• Khách hàng: user@example.com / User@12345\n• Quản trị viên: admin@example.com / Admin@12345',
                          style: TextStyle(fontSize: 11, color: Colors.brown.shade800, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
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
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'ĐĂNG NHẬP',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Đăng nhập Google (ẩn nếu chưa cấu hình GOOGLE_CLIENT_ID)
                if (AppConfig.isGoogleConfigured) ...[
                  Row(
                    children: const [
                      Expanded(child: Divider(color: AppColors.sand300)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('hoặc', style: TextStyle(color: AppColors.mute, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: AppColors.sand300)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.sand300),
                        foregroundColor: AppColors.ink,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isLoading ? null : _handleGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 30, color: Color(0xFF4285F4)),
                      label: const Text('Tiếp tục với Google', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Register Link (Dedicated Page Navigation)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Nàng chưa có tài khoản? ', style: TextStyle(color: AppColors.mute, fontSize: 13)),
                    GestureDetector(
                      onTap: () {
                        // Navigate to dedicated RegisterScreen page
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: AppColors.clay600,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Guest browse button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.sand300),
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tiếp tục duyệt với tư cách Khách', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
