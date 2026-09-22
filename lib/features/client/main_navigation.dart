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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          padding: EdgeInsets.symmetric(
                              horizontal: isSelected ? 12 : 0, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [AppColors.primary, AppColors.navy],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    _navItems[index].icon,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.navy.withValues(alpha: 0.35),
                                    size: 22,
                                  ),
                                  if (showBadge)
                                    Positioned(
                                      top: -3,
                                      right: -5,
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE53935),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Colors.white,
                                              width: 1.5),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _navItems[index].label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
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