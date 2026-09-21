import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../client/main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'رقم الهاتف هذا مسجل مسبقًا';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جدًا (6 أحرف على الأقل)';
      case 'invalid-email':
        return 'رقم الهاتف غير صالح';
      default:
        return 'حدث خطأ، حاول مرة أخرى';
    }
  }

  Future<void> _handleRegister() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty || password.isEmpty) {
      _showSnack('الرجاء ملء جميع الحقول');
      return;
    }
    if (password.length < 6) {
      _showSnack('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        password: password,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(_mapFirebaseError(e) ?? 'حدث خطأ');
    } catch (e) {
      _showSnack('حدث خطأ، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.40;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
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
              Stack(
                children: [
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
                  Positioned(
                    top: 8,
                    right: 4,
                    child: SafeArea(
                      bottom: false,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward,
                              color: AppColors.navy, size: 20),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'إنشاء حساب جديد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildUnderlineField(
                      controller: _firstNameController,
                      label: 'الاسم',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildUnderlineField(
                      controller: _lastNameController,
                      label: 'اللقب',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildUnderlineField(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      icon: Icons.phone_iphone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildUnderlineField(
                      controller: _passwordController,
                      label: 'كلمة المرور',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      onSuffixTap: () {
                        setState(
                            () => _obscurePassword = !_obscurePassword);
                      },
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'تسجيل',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'بإنشاء حسابك، فأنت توافق على سياسة الخصوصية والشروط والأحكام',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.5,
                        color: AppColors.navy.withValues(alpha: 0.4),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'لديك حساب؟ ',
                            style: TextStyle(
                              color: AppColors.navy.withValues(alpha: 0.55),
                              fontSize: 13.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
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
          style: TextStyle(
            fontSize: 12.5,
            color: AppColors.navy.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (suffixIcon != null)
              GestureDetector(
                onTap: onSuffixTap,
                child: Icon(
                  suffixIcon,
                  size: 19,
                  color: AppColors.navy.withValues(alpha: 0.35),
                ),
              ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 19, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: AppColors.navy.withValues(alpha: 0.15)),
      ],
    );
  }
}