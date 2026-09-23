import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';
import 'appointment_detail_screen.dart';

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AppointmentService();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.ink),
        title: Text(
          'إدارة المواعيد',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<Appointment>>(
          stream: service.allAppointments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ أثناء تحميل المواعيد',
                  style: TextStyle(color: AppColors.ink.withValues(alpha: 0.5)),
                ),
              );
            }

            final appointments = snapshot.data ?? [];

            if (appointments.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد طلبات مواعيد حاليًا.',
                  style: TextStyle(
                    color: AppColors.ink.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
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
                      MaterialPageRoute(
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

  const _AdminAppointmentTile({
    required this.appointment,
    required this.onTap,
  });

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.userName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.userPhone,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.ink.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              const SizedBox(width: 8),
              Icon(Icons.arrow_back_ios_new,
                  size: 14, color: AppColors.ink.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}