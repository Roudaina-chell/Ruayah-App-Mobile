import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../services/auth_service.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _authService = AuthService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loadingProfile = true;
  bool _savingInfo = false;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await _authService.getCurrentUserProfile();
    if (!mounted) return;
    setState(() {
      _firstNameController.text = profile?.firstName ?? '';
      _lastNameController.text = profile?.lastName ?? '';
      _phoneController.text = profile?.phone ?? '';
      _loadingProfile = false;
    });
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

  Future<void> _saveInfo() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      _showSnack('الرجاء ملء جميع الحقول');
      return;
    }

    setState(() => _savingInfo = true);
    try {
      await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      if (!mounted) return;
      _showSnack('تم حفظ المعلومات بنجاح ✅');
    } catch (e) {
      if (!mounted) return;
      _showSnack('حدث خطأ، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _savingInfo = false);
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnack('الرجاء ملء جميع الحقول');
      return;
    }
    if (newPass.length < 6) {
      _showSnack('كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    if (newPass != confirm) {
      _showSnack('كلمتا المرور الجديدتان غير متطابقتين');
      return;
    }

    setState(() => _savingPassword = true);
    try {
      await _authService.changePassword(
        currentPassword: current,
        newPassword: newPass,
      );
      if (!mounted) return;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _showSnack('تم تغيير كلمة المرور بنجاح ✅');
    } catch (e) {
      if (!mounted) return;
      _showSnack('كلمة المرور الحالية غير صحيحة، أو حدث خطأ آخر');
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.parchment,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text('الملف الشخصي', style: AppTextStyles.heading(size: 17)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loadingProfile
            ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(height: 28),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('المعلومات الشخصية', style: AppTextStyles.heading(size: 15)),
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      label: 'الاسم',
                      controller: _firstNameController,
                      hint: 'اسمك',
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'اللقب',
                      controller: _lastNameController,
                      hint: 'لقبك',
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'رقم الهاتف',
                      controller: _phoneController,
                      hint: 'رقم الهاتف',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),

                    Container(
                      height: 50,
                      decoration: AppDecorations.goldButton(radius: 14),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _savingInfo ? null : _saveInfo,
                          child: Center(
                            child: _savingInfo
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text('حفظ المعلومات', style: AppTextStyles.button(size: 14.5)),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),
                    Container(height: 1, color: AppColors.hairline),
                    const SizedBox(height: 28),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('تغيير كلمة المرور', style: AppTextStyles.heading(size: 15)),
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      label: 'كلمة المرور الحالية',
                      controller: _currentPasswordController,
                      hint: '••••••',
                      obscureText: true,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'كلمة المرور الجديدة',
                      controller: _newPasswordController,
                      hint: '6 أحرف على الأقل',
                      obscureText: true,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'تأكيد كلمة المرور الجديدة',
                      controller: _confirmPasswordController,
                      hint: '••••••',
                      obscureText: true,
                    ),
                    const SizedBox(height: 18),

                    Container(
                      height: 50,
                      decoration: AppDecorations.tealButton(radius: 14),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _savingPassword ? null : _changePassword,
                          child: Center(
                            child: _savingPassword
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text('تغيير كلمة المرور', style: AppTextStyles.button(size: 14.5)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}