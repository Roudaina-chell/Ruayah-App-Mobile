import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'home/home_screen.dart';
import 'appointments/appointments_screen.dart';
import 'programs/programs_screen.dart';
import 'ruqyahs/ruqyahs_screen.dart';
import 'cases/cases_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final AppointmentService _appointmentService = AppointmentService();

  late final List<Widget> _pages = [
    HomeScreen(
      onOpenAppointments: () => setState(() => _currentIndex = 3),
    ),
    const ProgramsScreen(),
    const RuqyahsScreen(),
    const AppointmentsScreen(),
    const CasesScreen(),
  ];

  final List<String> _titles = const [
    'محمد الراقي',
    'البرامج العلاجية',
    'الرقيات المسموعة',
    'حجز المواعيد',
    'متابعة الحالات',
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'البرامج'),
    _NavItem(icon: Icons.headphones_rounded, label: 'الرقيات'),
    _NavItem(icon: Icons.calendar_today_rounded, label: 'المواعيد'),
    _NavItem(icon: Icons.chat_bubble_rounded, label: 'الحالات'),
  ];

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBody: true,
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              centerTitle: true,
              title: Text(
                _titles[_currentIndex],
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.2,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.person_outline_rounded, color: AppColors.navy),
                  onPressed: () {
                    // سنربطها بصفحة Profile لاحقًا
                  },
                ),
                IconButton(
                  icon: Icon(Icons.logout_rounded, color: AppColors.navy),
                  onPressed: _logout,
                ),
              ],
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: StreamBuilder<List<Appointment>>(
        stream: _appointmentService.myAppointments(),
        builder: (context, snapshot) {
          final appointments = snapshot.data ?? [];
          final hasUnseenUpdate = appointments.any((a) =>
              !a.seenByClient &&
              (a.status == 'confirmed' || a.status == 'cancelled'));

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                height: 66,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.navy.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.08),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_navItems.length, (index) {
                    final isSelected = index == _currentIndex;
                    final showBadge = index == 3 && hasUnseenUpdate;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _currentIndex = index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              height: 3,
                              width: isSelected ? 20 : 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  _navItems[index].icon,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.navy.withValues(alpha: 0.3),
                                  size: 23,
                                ),
                                if (showBadge)
                                  Positioned(
                                    top: -3,
                                    right: -5,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE53935),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _navItems[index].label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.navy.withValues(alpha: 0.35),
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}