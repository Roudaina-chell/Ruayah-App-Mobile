import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            'تم إرسال طلب الموعد بنجاح ✅',
            textAlign: TextAlign.right,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBookButton(),
            const SizedBox(height: 22),

            Expanded(
              child: StreamBuilder<List<Appointment>>(
                stream: _appointmentService.myAppointments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.teal),
                    );
                  }

                  if (snapshot.hasError) {
                    return const EmptyState(
                      icon: Icons.error_outline_rounded,
                      message: 'حدث خطأ أثناء تحميل المواعيد',
                    );
                  }

                  final appointments = snapshot.data ?? [];

                  // المواعيد اللي تغيرت حالتها وماشي مُطّلع عليها بعد
                  final unseenUpdates = appointments
                      .where(
                        (a) =>
                            !a.seenByClient &&
                            (a.status == 'confirmed' ||
                                a.status == 'cancelled'),
                      )
                      .toList();

                  if (appointments.isEmpty) {
                    return const EmptyState(
                      icon: Icons.calendar_month_rounded,
                      message: 'لا توجد مواعيد بعد.',
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
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

                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('مواعيدي', style: AppTextStyles.heading()),
                        ],
                      ),
                      const SizedBox(height: 14),

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
      height: 58,
      decoration: AppDecorations.tealButton(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withValues(alpha: 0.15),
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text('حجز موعد', style: AppTextStyles.button(size: 15.5)),
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
    final color = isConfirmed ? AppColors.success : AppColors.danger;
    final bg = isConfirmed ? AppColors.successSoft : AppColors.dangerSoft;

    final message = isConfirmed
        ? 'تم تأكيد موعدك بتاريخ ${appointment.appointmentDate} الساعة ${appointment.appointmentTime}'
        : 'تم إلغاء طلب موعدك';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isConfirmed ? Icons.check_rounded : Icons.close_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: AppTextStyles.label(
                color: color,
                size: 13.5,
              ).copyWith(height: 1.4),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close,
              color: color.withValues(alpha: 0.6),
              size: 18,
            ),
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
      decoration: AppDecorations.sheet(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.hairline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.tealSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.teal,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'تأكيد طلب حجز موعد',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading(size: 17),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم إرسال طلبك إلى الراقي، وسيقوم بتحديد التاريخ والساعة المناسبة لك.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.inkMuted, size: 13),
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text('تأكيد الطلب', style: AppTextStyles.button(size: 15)),
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'إلغاء',
                style: AppTextStyles.body(color: AppColors.inkMuted, size: 14),
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
          'color': AppColors.success,
          'bg': AppColors.successSoft,
        };
      case 'cancelled':
        return {
          'label': 'ملغى',
          'color': AppColors.danger,
          'bg': AppColors.dangerSoft,
        };
      default:
        return {
          'label': 'قيد الانتظار',
          'color': AppColors.pending,
          'bg': AppColors.pendingSoft,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: status['bg'],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status['label'],
                  style: AppTextStyles.label(
                    color: status['color'],
                    size: 12,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppColors.inkFaint,
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (appointment.status == 'confirmed' &&
              appointment.appointmentDate != null) ...[
            Text(
              'موعدك المؤكد',
              style: AppTextStyles.label(color: AppColors.ink, size: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '${appointment.appointmentDate}   الساعة ${appointment.appointmentTime}',
              style: AppTextStyles.body(color: AppColors.inkMuted, size: 13),
            ),
          ] else ...[
            Text(
              'بانتظار تحديد الراقي للموعد',
              style: AppTextStyles.body(color: AppColors.inkFaint, size: 13),
            ),
          ],
        ],
      ),
    );
  }
}
