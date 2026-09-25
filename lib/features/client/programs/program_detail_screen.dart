import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/geometric_pattern.dart';
import '../../../models/program.dart';

class ProgramDetailScreen extends StatelessWidget {
  final Program program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 260,
            backgroundColor: AppColors.tealDeep,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const GeometricPatternBackground(
                      color: Colors.white,
                      opacity: 0.07,
                    ),
                    SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 108,
                              height: 108,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 108,
                                    height: 108,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 82,
                                    height: 82,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppColors.goldGradient,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.gold.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.menu_book_rounded,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 13,
                              color: AppColors.goldDeep,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'برنامج علاجي',
                              style: AppTextStyles.label(
                                color: AppColors.goldDeep,
                                size: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      program.title,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.displaySmall(size: 25),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      program.shortDescription,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body(color: AppColors.inkMuted),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          color: AppColors.gold,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text('محتوى البرنامج', style: AppTextStyles.heading()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            program.content,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.body(
                              color: AppColors.ink.withValues(alpha: 0.82),
                              size: 14.5,
                            ).copyWith(height: 2.0),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: 3,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          constraints: const BoxConstraints(minHeight: 60),
                        ),
                      ],
                    ),

                    const SizedBox(height: 34),

                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: AppColors.heroGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal.withValues(alpha: 0.22),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          splashColor: Colors.white.withValues(alpha: 0.15),
                          onTap: () => Navigator.of(context).pop(),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Text('رجوع', style: AppTextStyles.button()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
