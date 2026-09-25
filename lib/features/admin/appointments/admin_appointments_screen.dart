import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';
import 'appointment_detail_screen.dart';

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AppointmentService();

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.parchment,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text('إدارة المواعيد', style: AppTextStyles.heading(size: 17)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<Appointment>>(
          stream: service.allAppointments(),
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

            if (appointments.isEmpty) {
              return const EmptyState(
                icon: Icons.calendar_month_rounded,
                message: 'لا توجد طلبات مواعيد حاليًا.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return _AdminAppointmentTile(
                  appointment: appointment,
                  onTap: () {
                    Navigator.of(context).push(
                      AppPageRoute(
                        builder: (_) =>
                            AppointmentDetailScreen(appointment: appointment),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AdminAppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const _AdminAppointmentTile({required this.appointment, required this.onTap});

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.gold.withValues(alpha: 0.1),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.card(radius: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.userName, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      appointment.userPhone,
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: status['bg'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status['label'],
                  style: AppTextStyles.label(
                    color: status['color'],
                    size: 12,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: AppColors.inkFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
