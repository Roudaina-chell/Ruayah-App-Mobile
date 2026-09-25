import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final _service = AppointmentService();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _confirm() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء اختيار التاريخ والساعة',
            textAlign: TextAlign.right,
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _service.confirmAppointment(
        appointmentId: widget.appointment.id,
        date: _formatDate(_selectedDate!),
        time: _formatTime(_selectedTime!),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ، حاول مرة أخرى', textAlign: TextAlign.right),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancel() async {
    setState(() => _isLoading = true);
    try {
      await _service.cancelAppointment(widget.appointment.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ، حاول مرة أخرى', textAlign: TextAlign.right),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.parchment,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text('تفاصيل الموعد', style: AppTextStyles.heading(size: 17)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card(radius: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _infoRow('الاسم', appointment.userName),
                    const SizedBox(height: 14),
                    _infoRow('رقم الهاتف', appointment.userPhone),
                    const SizedBox(height: 14),
                    _infoRow(
                      'الحالة الحالية',
                      appointment.status == 'confirmed'
                          ? 'مؤكد'
                          : appointment.status == 'cancelled'
                          ? 'ملغى'
                          : 'قيد الانتظار',
                    ),
                    if (appointment.status == 'confirmed') ...[
                      const SizedBox(height: 14),
                      _infoRow(
                        'التاريخ الحالي',
                        appointment.appointmentDate ?? '-',
                      ),
                      const SizedBox(height: 14),
                      _infoRow(
                        'الساعة الحالية',
                        appointment.appointmentTime ?? '-',
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text('تحديد موعد جديد', style: AppTextStyles.heading(size: 15)),
              const SizedBox(height: 14),

              _pickerTile(
                icon: Icons.calendar_today_outlined,
                label: _selectedDate == null
                    ? 'اختر التاريخ'
                    : _formatDate(_selectedDate!),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              _pickerTile(
                icon: Icons.access_time_outlined,
                label: _selectedTime == null
                    ? 'اختر الساعة'
                    : _formatTime(_selectedTime!),
                onTap: _pickTime,
              ),

              const SizedBox(height: 28),

              Container(
                height: 52,
                decoration: AppDecorations.tealButton(radius: 14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _isLoading ? null : _confirm,
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'تأكيد الموعد',
                              style: AppTextStyles.button(size: 15),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _cancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'إلغاء الموعد',
                    style: AppTextStyles.label(
                      color: AppColors.danger,
                      size: 15,
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

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.cardSubtitle),
        const Spacer(),
        Text(value, style: AppTextStyles.heading(size: 14)),
      ],
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.tealSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.teal, size: 20),
              const SizedBox(width: 12),
              Text(label, style: AppTextStyles.body(size: 14.5)),
            ],
          ),
        ),
      ),
    );
  }
}
