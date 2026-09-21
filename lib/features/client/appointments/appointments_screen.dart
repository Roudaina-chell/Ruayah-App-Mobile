import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';
import '../../../services/auth_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _appointmentService = AppointmentService();
  final _authService = AuthService();
  bool _isSubmitting = false;

  Future<void> _confirmAndBook() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingConfirmSheet(),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      final profile = await _authService.getCurrentUserProfile();

      await _appointmentService.requestAppointment(
        userName: profile != null
            ? '${profile.firstName} ${profile.lastName}'
            : 'مستخدم',
        userPhone: profile?.phone ?? '',
        note: '',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال طلب الموعد بنجاح ✅',
              textAlign: TextAlign.right),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ، حاول مرة أخرى', textAlign: TextAlign.right),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBookButton(),
            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<List<Appointment>>(
                stream: _appointmentService.myAppointments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'حدث خطأ أثناء تحميل المواعيد',
                        style: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }

                  final appointments = snapshot.data ?? [];

                  // المواعيد اللي تغيرت حالتها وماشي مُطّلع عليها بعد
                  final unseenUpdates = appointments
                      .where((a) =>
                          !a.seenByClient &&
                          (a.status == 'confirmed' || a.status == 'cancelled'))
                      .toList();

                  if (appointments.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد مواعيد بعد.',
                        style: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      // البانرات الدائمة — تبقى بانة حتى يضغط العميل "تم الاطلاع"
                      ...unseenUpdates.map(
                        (appointment) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PersistentNotificationBanner(
                            appointment: appointment,
                            onDismiss: () {
                              _appointmentService.markAsSeen(appointment.id);
                            },
                          ),
                        ),
                      ),

                      if (unseenUpdates.isNotEmpty) const SizedBox(height: 4),

                      Text(
                        'مواعيدي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...appointments.map(
                        (appointment) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AppointmentCard(appointment: appointment),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primary,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isSubmitting ? null : _confirmAndBook,
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'حجز موعد',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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

/// بانر دائم يبقى بانًا حتى يضغط العميل "تم الاطلاع"
class _PersistentNotificationBanner extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onDismiss;

  const _PersistentNotificationBanner({
    required this.appointment,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmed = appointment.status == 'confirmed';
    final color = isConfirmed ? const Color(0xFF43A047) : const Color(0xFFE53935);
    final bg = isConfirmed ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    final message = isConfirmed
        ? 'تم تأكيد موعدك بتاريخ ${appointment.appointmentDate} الساعة ${appointment.appointmentTime}'
        : 'تم إلغاء طلب موعدك';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isConfirmed ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, color: color.withValues(alpha: 0.6), size: 18),
          ),
        ],
      ),
    );
  }
}

class _BookingConfirmSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.veryLightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_month_outlined,
                  color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'تأكيد طلب حجز موعد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم إرسال طلبك إلى الراقي، وسيقوم بتحديد التاريخ والساعة المناسبة لك.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.navy.withValues(alpha: 0.55),
            ),
          ),

          const SizedBox(height: 26),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'تأكيد الطلب',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  Map<String, dynamic> get _statusInfo {
    switch (appointment.status) {
      case 'confirmed':
        return {
          'label': 'مؤكد',
          'color': const Color(0xFF43A047),
          'bg': const Color(0xFFE8F5E9),
        };
      case 'cancelled':
        return {
          'label': 'ملغى',
          'color': const Color(0xFFE53935),
          'bg': const Color(0xFFFFEBEE),
        };
      default:
        return {
          'label': 'قيد الانتظار',
          'color': const Color(0xFFFB8C00),
          'bg': const Color(0xFFFFF3E0),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: status['bg'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status['label'],
                  style: TextStyle(
                    color: status['color'],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: AppColors.navy.withValues(alpha: 0.35)),
            ],
          ),
          const SizedBox(height: 12),

          if (appointment.status == 'confirmed' &&
              appointment.appointmentDate != null) ...[
            Text(
              'موعدك المؤكد',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${appointment.appointmentDate}   الساعة ${appointment.appointmentTime}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.navy.withValues(alpha: 0.6),
              ),
            ),
          ] else ...[
            Text(
              'بانتظار تحديد الراقي للموعد',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.navy.withValues(alpha: 0.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}