import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Sampled directly from the onboarding artwork's plain beige/cream area
  // (averaged across several clean regions of the image) so the page
  // background blends seamlessly with the bottom of the banner image,
  // with no visible seam or color boundary.
  static const Color _imageBackdropBeige = Color(0xFFF8F2E6);

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
    // Responsive image height so the full logo/banner fits, clamped so it
    // stays reasonable on short phones and large desktop/web screens.
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = (screenHeight * 0.48).clamp(300.0, 420.0);

    return Scaffold(
      // Matched exactly to the beige/cream tone in the artwork so the image
      // and the page background read as one continuous surface.
      backgroundColor: _imageBackdropBeige,
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
                    imagePath: 'assets/images/onboarding_1.jpg',
                    imageHeight: imageHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'مرحباً بك',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displaySmall(size: 26),
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
                    imagePath: 'assets/images/onboarding_2.jpg',
                    imageHeight: imageHeight,
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
                        const SizedBox(height: 20),
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
  final String imagePath;
  final double imageHeight;
  final Widget child;

  const _OnboardingPage({
    required this.imagePath,
    required this.imageHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top gap so the image section sits a bit lower instead of
          // touching the very top edge of the screen.
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Image.asset(
              imagePath,
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              // Anchors the crop to the top of the source image so the logo
              // and decorative elements at the top are never cut off.
              alignment: Alignment.topCenter,
            ),
          ),
          Padding(
            // Extra top padding for a clean gap between the image and the
            // text section below it.
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 4),
            child: child,
          ),
        ],
      ),
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
            decoration: const BoxDecoration(
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