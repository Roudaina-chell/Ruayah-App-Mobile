import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/geometric_pattern.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';
import 'widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenAppointments;

  const HomeScreen({super.key, required this.onOpenAppointments});

  @override
  Widget build(BuildContext context) {
    final appointmentService = AppointmentService();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Hero header =====
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
                child: Stack(
                  children: [
                    // the app's one signature ornament — quiet, never repeated elsewhere
                    const GeometricPatternBackground(
                      color: Colors.white,
                      opacity: 0.07,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 1.4,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    'assets/images/app_icon.png',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'محمد الراقي',
                                  style: AppTextStyles.heading(
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'مرحبًا بك',
                            style: AppTextStyles.display(size: 34),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'نسأل الله أن يمنحك الشفاء والراحة',
                            style: AppTextStyles.body(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== Appointments summary — overlaps the hero's curve =====
            Transform.translate(
              offset: const Offset(0, -26),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<List<Appointment>>(
                  stream: appointmentService.myAppointments(),
                  builder: (context, snapshot) {
                    final appointments = snapshot.data ?? [];
                    final confirmed = appointments
                        .where((a) => a.status == 'confirmed')
                        .toList();
                    final pending = appointments
                        .where((a) => a.status == 'pending')
                        .toList();
                    final hasUnseen = appointments.any(
                      (a) =>
                          !a.seenByClient &&
                          (a.status == 'confirmed' || a.status == 'cancelled'),
                    );

                    return _AppointmentsSummaryCard(
                      confirmedCount: confirmed.length,
                      pendingCount: pending.length,
                      nextConfirmed: confirmed.isNotEmpty
                          ? confirmed.first
                          : null,
                      hasUnseen: hasUnseen,
                      onTap: onOpenAppointments,
                    );
                  },
                ),
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                        Text('خدماتنا', style: AppTextStyles.heading()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FeatureCard(
                      icon: Icons.menu_book_rounded,
                      iconBackgroundColor: AppColors.tealSoft,
                      iconColor: AppColors.teal,
                      title: 'برامج علاجية',
                      subtitle: 'برامج متنوعة',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    FeatureCard(
                      icon: Icons.headphones_rounded,
                      iconBackgroundColor: AppColors.tealSoft,
                      iconColor: AppColors.teal,
                      title: 'رقيات مسموعة',
                      subtitle: 'رقيات من القرآن والسنة',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    FeatureCard(
                      icon: Icons.chat_bubble_rounded,
                      iconBackgroundColor: AppColors.tealSoft,
                      iconColor: AppColors.teal,
                      title: 'متابعة الحالات',
                      subtitle: 'تواصل مع الراقي',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsSummaryCard extends StatelessWidget {
  final int confirmedCount;
  final int pendingCount;
  final Appointment? nextConfirmed;
  final bool hasUnseen;
  final VoidCallback onTap;

  const _AppointmentsSummaryCard({
    required this.confirmedCount,
    required this.pendingCount,
    required this.nextConfirmed,
    required this.hasUnseen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        splashColor: AppColors.gold.withValues(alpha: 0.1),
        highlightColor: AppColors.gold.withValues(alpha: 0.05),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: AppDecorations.card(radius: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.tealSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.teal,
                          size: 22,
                        ),
                      ),
                      if (hasUnseen)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مواعيدي',
                          style: AppTextStyles.heading(size: 15.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          confirmedCount == 0 && pendingCount == 0
                              ? 'لا توجد مواعيد بعد'
                              : '$confirmedCount مؤكد · $pendingCount قيد الانتظار',
                          style: AppTextStyles.cardSubtitle,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14,
                    color: AppColors.inkFaint,
                  ),
                ],
              ),
              if (nextConfirmed != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.goldDeep,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'موعدك القادم: ${nextConfirmed!.appointmentDate} الساعة ${nextConfirmed!.appointmentTime}',
                          style: AppTextStyles.label(
                            color: AppColors.goldDeep,
                            size: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
