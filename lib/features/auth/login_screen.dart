import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../services/auth_service.dart';
import '../admin/main_navigation.dart';
import '../client/main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'رقم الهاتف أو كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'رقم الهاتف غير صالح';
      default:
        return 'حدث خطأ، حاول مرة أخرى';
    }
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showSnack('الرجاء إدخال رقم الهاتف وكلمة المرور');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appUser = await _authService.login(
        phone: phone,
        password: password,
      );

      if (!mounted) return;

      if (appUser.role == 'admin') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminMainNavigation()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(_mapFirebaseError(e));
    } catch (e) {
      _showSnack('حدث خطأ، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(message, textAlign: TextAlign.right),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.40;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصورة — بلا أي تعديل
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: Image.asset(
                  'assets/images/auth_hero.png',
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'سجل الدخول للمتابعة',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displaySmall(size: 21),
                    ),

                    const SizedBox(height: 26),

                    _buildUnderlineField(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      icon: Icons.phone_iphone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    _buildUnderlineField(
                      controller: _passwordController,
                      label: 'كلمة المرور',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      onSuffixTap: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),

                    const SizedBox(height: 28),

                    Container(
                      height: 54,
                      decoration: AppDecorations.goldButton(radius: 27),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(27),
                          onTap: _isLoading ? null : _handleLogin,
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'دخول',
                                    style: AppTextStyles.button(size: 16),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'ليس لديك حساب؟ ',
                            style: AppTextStyles.body(
                              color: AppColors.inkMuted,
                              size: 13.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                            child: Text(
                              'سجل الآن',
                              style: AppTextStyles.label(
                                color: AppColors.teal,
                                size: 13.5,
                              ).copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnderlineField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label(color: AppColors.inkFaint, size: 12.5),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (suffixIcon != null)
              GestureDetector(
                onTap: onSuffixTap,
                child: Icon(suffixIcon, size: 19, color: AppColors.inkFaint),
              ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                textAlign: TextAlign.right,
                style: AppTextStyles.body(
                  size: 15.5,
                ).copyWith(fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 19, color: AppColors.teal),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: AppColors.hairline),
      ],
    );
  }
}
