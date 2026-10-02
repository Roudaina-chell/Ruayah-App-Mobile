import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/widgets/geometric_pattern.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_currentPage == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _goToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroHeight = MediaQuery.of(context).size.height * 0.36;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _OnboardingPage(
                    heroHeight: heroHeight,
                    heroIcon: Icons.menu_book_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'مرحباً بك',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displaySmall(size: 27),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'في تطبيق محمد الراقي',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading(size: 15),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'رحلتك نحو الراحة النفسية والسكينة الروحية تبدأ من هنا',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(color: AppColors.inkMuted, size: 13.5)
                              .copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  _OnboardingPage(
                    heroHeight: heroHeight,
                    heroIcon: Icons.auto_awesome_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'خدماتنا من أجلك',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displaySmall(size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'تطبيق متكامل لمساعدتك في رحلتك الروحية والنفسية بإذن الله',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(color: AppColors.inkMuted, size: 13)
                              .copyWith(height: 1.6),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: _ServiceItem(
                                icon: Icons.calendar_month_rounded,
                                title: 'حجز مواعيد',
                                subtitle: 'اطلب موعدك وسيتم تأكيده',
                              ),
                            ),
                            Expanded(
                              child: _ServiceItem(
                                icon: Icons.headphones_rounded,
                                title: 'رقيات مسموعة',
                                subtitle: 'رقيات شرعية بأصوات مريحة',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _ServiceItem(
                                icon: Icons.menu_book_rounded,
                                title: 'برامج علاجية',
                                subtitle: 'برامج متنوعة لكل حالة',
                              ),
                            ),
                            Expanded(
                              child: _ServiceItem(
                                icon: Icons.chat_bubble_rounded,
                                title: 'متابعة الحالات',
                                subtitle: 'تواصل مع الإدارة',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== Shared bottom bar: dots + skip/next =====
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active ? AppColors.gold : AppColors.hairline,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (_currentPage == 1)
                        TextButton(
                          onPressed: _goToLogin,
                          child: Text(
                            'تخطي',
                            style: AppTextStyles.label(color: AppColors.inkMuted, size: 14),
                          ),
                        )
                      else
                        const SizedBox(width: 8),
                      const Spacer(),
                      Container(
                        height: 52,
                        constraints: const BoxConstraints(minWidth: 140),
                        decoration: AppDecorations.goldButton(radius: 26),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(26),
                            onTap: _next,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 26),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('التالي', style: AppTextStyles.button(size: 15)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final double heroHeight;
  final IconData heroIcon;
  final Widget child;

  const _OnboardingPage({
    required this.heroHeight,
    required this.heroIcon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Container(
              height: heroHeight,
              decoration: BoxDecoration(gradient: AppColors.heroGradient),
              child: Stack(
                children: [
                  const GeometricPatternBackground(
                    color: Colors.white,
                    opacity: 0.16,
                  ),
                  // inset ornamental frame
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(22),
                            bottomRight: Radius.circular(22),
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // corner star flourishes
                  const Positioned(top: 22, left: 26, child: _CornerStar()),
                  const Positioned(top: 22, right: 26, child: _CornerStar()),
                  // simple lanterns
                  const Positioned(top: 4, left: 44, child: _MiniLantern()),
                  const Positioned(top: 4, right: 44, child: _MiniLantern()),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.goldGradient,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(alpha: 0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(heroIcon, color: Colors.white, size: 32),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('محمد الراقي', style: AppTextStyles.display(size: 24)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 26, height: 1, color: AppColors.gold.withValues(alpha: 0.6)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                            ),
                            Container(width: 26, height: 1, color: AppColors.gold.withValues(alpha: 0.6)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 4),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CornerStar extends StatelessWidget {
  const _CornerStar();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star_rounded, size: 16, color: AppColors.gold.withValues(alpha: 0.55));
  }
}

class _MiniLantern extends StatelessWidget {
  const _MiniLantern();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 1.2, height: 16, color: Colors.white.withValues(alpha: 0.35)),
        Container(
          width: 22,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.55),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 1),
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
        ),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tealSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.teal, size: 21),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.label(color: AppColors.ink, size: 12).copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label(color: AppColors.inkFaint, size: 10.5),
          ),
        ],
      ),
    );
  }
}