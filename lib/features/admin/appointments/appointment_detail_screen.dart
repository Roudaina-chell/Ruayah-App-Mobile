import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
          content: Text('الرجاء اختيار التاريخ والساعة',
              textAlign: TextAlign.right),
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
        SnackBar(content: Text('حدث خطأ، حاول مرة أخرى', textAlign: TextAlign.right)),
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
        SnackBar(content: Text('حدث خطأ، حاول مرة أخرى', textAlign: TextAlign.right)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.navy),
        title: Text(
          'تفاصيل الموعد',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                _infoRow('التاريخ الحالي', appointment.appointmentDate ?? '-'),
                const SizedBox(height: 14),
                _infoRow('الساعة الحالية', appointment.appointmentTime ?? '-'),
              ],

              const SizedBox(height: 32),

              Text(
                'تحديد موعد جديد',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
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

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'تأكيد الموعد',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _cancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    side: const BorderSide(color: Color(0xFFE53935)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'إلغاء الموعد',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.navy.withValues(alpha: 0.5),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.navy,
          ),
        ),
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
            color: const Color(0xFFF5F8FC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(color: AppColors.navy, fontSize: 14.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}