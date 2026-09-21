import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/appointment_service.dart';
import '../../../services/auth_service.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  final _noteController = TextEditingController();
  final _appointmentService = AppointmentService();
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    try {
      // نجيب بيانات المستخدم الحالي من Firestore
      final currentUser = AuthService().currentUser;
      final phone = currentUser?.email?.split('@').first ?? '';

      await _appointmentService.requestAppointment(
        userName: currentUser?.displayName ?? 'مستخدم',
        userPhone: phone,
        note: _noteController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال طلب الموعد بنجاح ✅', textAlign: TextAlign.right)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ، حاول مرة أخرى', textAlign: TextAlign.right)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.navy),
        title: Text(
          'طلب حجز موعد',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'يمكنك كتابة ملاحظة أو سبب طلب الموعد (اختياري)',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 6,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: AppColors.navy, fontSize: 14.5),
                  decoration: InputDecoration(
                    hintText: 'اكتب ملاحظتك هنا...',
                    hintStyle:
                        TextStyle(color: AppColors.navy.withValues(alpha: 0.35)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'إرسال الطلب',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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