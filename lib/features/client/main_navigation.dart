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
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: _currentIndex == 0
            ? null
            : Text(
                _titles[_currentIndex],
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: AppColors.navy),
            onPressed: () {
              // سنربطها بصفحة Profile لاحقًا
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.navy),
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

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.navy.withValues(alpha: 0.4),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'البرامج',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.headphones_outlined),
                activeIcon: Icon(Icons.headphones),
                label: 'الرقيات',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  Icons.calendar_today_outlined,
                  showBadge: hasUnseenUpdate,
                ),
                activeIcon: _buildNavIcon(
                  Icons.calendar_today,
                  showBadge: hasUnseenUpdate,
                ),
                label: 'المواعيد',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'الحالات',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, {required bool showBadge}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (showBadge)
          Positioned(
            top: -2,
            right: -4,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final String message;

  const _PlaceholderTab({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}