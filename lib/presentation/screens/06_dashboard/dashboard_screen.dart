import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';

import '../../providers/onboarding_provider.dart';
import '../../providers/screening_provider.dart';

import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ============================================================
  // DYNAMIC PERSONALIZED GREETING
  // ============================================================

  String _getDynamicGreeting(String? rawName) {
    final hour = DateTime.now().hour;

    String timeSalutation;

    if (hour >= 5 && hour < 12) {
      timeSalutation = 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      timeSalutation = 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      timeSalutation = 'Good Evening';
    } else {
      timeSalutation = 'Good Night';
    }

    final trimmedName = rawName?.trim();

    if (trimmedName != null && trimmedName.isNotEmpty) {
      // If user enters "Charan Teja",
      // display only "Charan".
      final firstName = trimmedName.split(RegExp(r'\s+')).first;

      return '$timeSalutation 👋 $firstName';
    }

    // Fallback if the user hasn't entered a name.
    return '$timeSalutation 👋';
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider =
        Provider.of<OnboardingProvider>(context);

    final screeningProvider =
        Provider.of<ScreeningProvider>(context);

    // Get the name saved during Basic Information.
    final userName =
        onboardingProvider.profile.name;

    final greeting =
        _getDynamicGreeting(userName);

    return Scaffold(
      backgroundColor: AppColors.background,

      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundAura,
        ),

        child: SafeArea(
          child: Column(
            children: [

              // ==================================================
              // DASHBOARD HEADER
              // ==================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            greeting,

                            style:
                                AppTypography.headingLarge.copyWith(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Your health is our priority.',

                            style:
                                AppTypography.subtitle.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // NOTIFICATION BELL
                    // ==================================================

                    Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,

                          decoration: BoxDecoration(
                            color:
                                AppColors.surfaceElevated,

                            borderRadius:
                                BorderRadius.circular(14),

                            border: Border.all(
                              color:
                                  AppColors.borderSubtle,

                              width: 1,
                            ),
                          ),

                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,

                              color: Colors.white,

                              size: 22,
                            ),

                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(
                                AppRoutes.notifications,
                              );
                            },
                          ),
                        ),

                        if (screeningProvider.hasUnreadNotifications)
                          Positioned(
                            top: 10,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.neonPink,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // ==================================================
              // CONTENT
              // ==================================================

              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),

                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // ==================================================
                      // CANCER SCREENING CARD
                      // ==================================================

                      _buildHeroScreeningCard(context),

                      const SizedBox(height: 24),

                      // ==================================================
                      // ROW 1
                      // REPORTS + HISTORY
                      // ==================================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _buildQuickActionCard(
                              title: 'Reports',

                              subtitle:
                                  'View & download\nyour reports',

                              icon:
                                  Icons.description_outlined,

                              accentColor:
                                  AppColors.neonGreen,

                              iconBackground:
                                  const Color(0xFF0F382B),

                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(
                                  AppRoutes.reports,
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child:
                                _buildQuickActionCard(
                              title: 'History',

                              subtitle:
                                  'Track your\nscreenings',

                              icon:
                                  Icons.history_rounded,

                              accentColor:
                                  AppColors.neonCyan,

                              iconBackground:
                                  const Color(0xFF0C2B4E),

                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(
                                  AppRoutes.screeningHistory,
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // ROW 2
                      // NOTIFICATIONS + FOOD GUIDANCE
                      // ==================================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _buildQuickActionCard(
                              title: 'Notifications',

                              subtitle:
                                  'View reminders\n& alerts',

                              icon:
                                  Icons.notifications_active_outlined,

                              accentColor:
                                  AppColors.neonPink,

                              iconBackground:
                                  const Color(0xFF381428),

                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(
                                  AppRoutes.notifications,
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child:
                                _buildQuickActionCard(
                              title: 'Food Guidance',

                              subtitle:
                                  'AI nutrition\n& medicine',

                              icon:
                                  Icons.restaurant_menu_rounded,

                              accentColor:
                                  AppColors.neonBlue,

                              iconBackground:
                                  const Color(0xFF132B5C),

                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(
                                  AppRoutes.foodGuidance,
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // BOTTOM NAVIGATION
              // ==================================================

              _buildBottomNavigationBar(
                context,
                screeningProvider,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CANCER SCREENING HERO CARD
  // ============================================================

  Widget _buildHeroScreeningCard(
    BuildContext context,
  ) {
    return GlowContainer(
      borderRadius: 22,

      padding:
          const EdgeInsets.all(20),

      backgroundGradient:
          AppGradients.heroCard,

      borderGradient:
          AppGradients.neonBorderBluePurple,

      glowColor:
          AppColors.neonBlue,

      glowRadius: 16,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color:
                      AppColors.neonBlue.withValues(
                    alpha: 0.2,
                  ),

                  border: Border.all(
                    color:
                        AppColors.neonBlue.withValues(
                      alpha: 0.8,
                    ),

                    width: 1.5,
                  ),
                ),

                child: const Icon(
                  Icons.biotech_rounded,

                  color:
                      AppColors.neonCyan,

                  size: 26,
                ),
              ),

              const Spacer(),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color:
                      AppColors.neonPurple.withValues(
                    alpha: 0.25,
                  ),

                  borderRadius:
                      BorderRadius.circular(20),

                  border: Border.all(
                    color:
                        AppColors.neonPurple.withValues(
                      alpha: 0.6,
                    ),

                    width: 1,
                  ),
                ),

                child: Text(
                  'UC-001 QML',

                  style:
                      AppTypography.bodySmall.copyWith(
                    color:
                        AppColors.neonPurple,

                    fontWeight:
                        FontWeight.w700,

                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Cancer Screening',

            style:
                AppTypography.headingMedium.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Take control of your health with AI-powered screening.',

            style:
                AppTypography.subtitle.copyWith(
              fontSize: 13,
              color:
                  AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 18),

          GradientButton(
            text: 'Start Screening',

            height: 48,

            borderRadius: 12,

            onPressed: () {
              Navigator.of(context)
                  .pushNamed(
                AppRoutes.cancerScreening,
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTION CARD
  // ============================================================

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return GlowContainer(
      borderRadius: 18,

      padding:
          const EdgeInsets.all(16),

      backgroundColor:
          AppColors.surfaceCard,

      onTap: onTap,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: iconBackground,

              borderRadius:
                  BorderRadius.circular(12),

              border: Border.all(
                color:
                    accentColor.withValues(
                  alpha: 0.4,
                ),

                width: 1,
              ),
            ),

            child: Icon(
              icon,

              color: accentColor,

              size: 20,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,

            style:
                AppTypography.headingSmall.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,

            style:
                AppTypography.bodySmall.copyWith(
              fontSize: 11,

              color:
                  AppColors.textSecondary,

              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION BAR
  // ============================================================

  Widget _buildBottomNavigationBar(
    BuildContext context,
    ScreeningProvider screeningProvider,
  ) {
    final items = [
      _NavItem(
        Icons.home_filled,
        'Home',
        AppRoutes.dashboard,
      ),

      _NavItem(
        Icons.science_outlined,
        'Screening',
        AppRoutes.cancerScreening,
      ),

      _NavItem(
        Icons.article_outlined,
        'Reports',
        AppRoutes.reports,
      ),

      _NavItem(
        Icons.history_rounded,
        'History',
        AppRoutes.screeningHistory,
      ),

      _NavItem(
        Icons.notifications_none_rounded,
        'Notifications',
        AppRoutes.notifications,
      ),
    ];

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color:
            AppColors.surface.withValues(
          alpha: 0.95,
        ),

        border: const Border(
          top: BorderSide(
            color:
                AppColors.borderSubtle,

            width: 1,
          ),
        ),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,

        children:
            List.generate(
          items.length,
          (index) {
            final item =
                items[index];

            final isSelected =
                screeningProvider
                    .currentDashboardTab ==
                    index;

            return GestureDetector(
              onTap: () {
                screeningProvider
                    .setDashboardTab(index);

                if (index != 0) {
                  Navigator.of(context)
                      .pushNamed(
                    item.route,
                  );
                }
              },

              behavior:
                  HitTestBehavior.opaque,

              child: Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  Icon(
                    item.icon,

                    size: 22,

                    color: isSelected
                        ? AppColors.neonCyan
                        : AppColors.textMuted,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item.label,

                    style: TextStyle(
                      fontSize: 10,

                      fontWeight:
                          isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,

                      color: isSelected
                          ? AppColors.neonCyan
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// NAVIGATION ITEM MODEL
// ============================================================

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  _NavItem(
    this.icon,
    this.label,
    this.route,
  );
}

