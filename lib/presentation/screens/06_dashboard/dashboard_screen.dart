import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/information_extraction_service.dart';
import '../../../core/services/voice_assistant_service.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/screening_provider.dart';
import '../../widgets/ai_voice_assistant_sheet.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openAiAssistant(
    BuildContext context,
    OnboardingProvider onboardingProvider,
  ) {
    AiVoiceAssistantSheet.show(
      context: context,
      mode: AssistantMode.dashboard,
      initialLanguageCode: onboardingProvider.selectedLanguageCode,
      onLanguageSelected: (langCode) {
        onboardingProvider.selectLanguage(langCode);
      },
      onIntentDetected: (intent) {
        if (!context.mounted) return;
        switch (intent) {
          case ConversationalIntent.startScreening:
            Navigator.of(context).pushNamed(AppRoutes.cancerScreening);
            break;
          case ConversationalIntent.viewReports:
            Navigator.of(context).pushNamed(AppRoutes.reports);
            break;
          case ConversationalIntent.foodGuidance:
            Navigator.of(context).pushNamed(AppRoutes.foodGuidance);
            break;
          case ConversationalIntent.screeningHistory:
            Navigator.of(context).pushNamed(AppRoutes.screeningHistory);
            break;
          case ConversationalIntent.continueNext:
            Navigator.of(context).pushNamed(AppRoutes.cancerScreening);
            break;
          case ConversationalIntent.changeLanguage:
            Navigator.of(context).pushNamed(AppRoutes.languageSelection);
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final screeningProvider = Provider.of<ScreeningProvider>(context);

    final greeting = onboardingProvider.dynamicGreeting;
    final photoUrl = onboardingProvider.authPhotoUrl;
    final displayName = onboardingProvider.displayName;

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
              // CLINICAL DASHBOARD HEADER
              // ==================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: AppTypography.headingLarge.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHeading,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Your genomic insights for a healthier tomorrow.',
                            style: AppTypography.subtitle.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AiAssistantFab(
                          onTap: () => _openAiAssistant(
                            context,
                            onboardingProvider,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Profile Avatar Shortcut
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppGradients.tealMint,
                              border: Border.all(
                                color: AppColors.primaryTeal.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowTeal,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: photoUrl != null && photoUrl.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      photoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Center(
                                        child: Text(
                                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
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

              // ==================================================
              // CONTENT
              // ==================================================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // ==================================================
                      // HERO CANCER SCREENING CARD
                      // ==================================================
                      _buildHeroScreeningCard(context),

                      const SizedBox(height: 20),

                      // Section Title: Quick Actions
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Clinical Modules & Intelligence',
                          style: AppTypography.label.copyWith(
                            color: AppColors.textHeading,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ROW 1: Genomic Data & Medical Image Uploads
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              title: 'Genomic Data',
                              subtitle: 'TCGA RNA-Seq\nBiomarkers & XAI',
                              icon: Icons.biotech_rounded,
                              accentColor: AppColors.primaryTeal,
                              iconBackground: AppColors.surfaceMint,
                              onTap: () {
                                screeningProvider.setActiveInputType(ScreeningInputType.genomicData);
                                Navigator.of(context).pushNamed(AppRoutes.genomicDataUpload);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              title: 'Medical Vision',
                              subtitle: 'MRI / CT Scan\nGrad-CAM Diagnostics',
                              icon: Icons.image_search_rounded,
                              accentColor: AppColors.secondaryBlue,
                              iconBackground: AppColors.surfaceLightBlue,
                              onTap: () {
                                screeningProvider.setActiveInputType(ScreeningInputType.medicalImage);
                                Navigator.of(context).pushNamed(AppRoutes.medicalImageUpload);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ROW 2: Reports + History
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              title: 'Reports',
                              subtitle: 'Diagnostic summaries\n& clinical insights',
                              icon: Icons.description_outlined,
                              accentColor: AppColors.statusSuccess,
                              iconBackground: AppColors.surfaceMint,
                              onTap: () {
                                Navigator.of(context).pushNamed(AppRoutes.reports);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              title: 'History',
                              subtitle: 'Track previous\npan-cancer screenings',
                              icon: Icons.history_rounded,
                              accentColor: AppColors.primaryTeal,
                              iconBackground: AppColors.surfaceLightCyan,
                              onTap: () {
                                Navigator.of(context).pushNamed(AppRoutes.screeningHistory);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ROW 3: Notifications + Food Guidance
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              title: 'Notifications',
                              subtitle: 'Medicine alarms\n& daily reminders',
                              icon: Icons.notifications_active_outlined,
                              accentColor: const Color(0xFFF59E0B),
                              iconBackground: const Color(0xFFFEF3C7),
                              onTap: () {
                                Navigator.of(context).pushNamed(AppRoutes.notifications);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              title: 'Food Guidance',
                              subtitle: 'AI Oncology nutrition\n& medication rules',
                              icon: Icons.restaurant_menu_rounded,
                              accentColor: AppColors.secondaryBlue,
                              iconBackground: AppColors.surfaceLightBlue,
                              onTap: () {
                                Navigator.of(context).pushNamed(AppRoutes.foodGuidance);
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
              _buildBottomNavigationBar(context, screeningProvider),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CANCER SCREENING HERO CARD
  // ============================================================
  Widget _buildHeroScreeningCard(BuildContext context) {
    return GlowContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      backgroundColor: AppColors.surfaceCard,
      borderColor: AppColors.primaryTeal.withValues(alpha: 0.35),
      borderWidth: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.tealMint,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.biotech_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precision Oncology Screening',
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'TCGA Calibrated AI & Medical Vision',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Analyze liquid biopsy gene expression datasets or radiology scans using multiclass neural networks, biomarker XAI attributions, and simulated quantum machine learning.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(
            text: 'Start AI Screening',
            gradient: AppGradients.primaryButton,
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.cancerScreening);
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
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      backgroundColor: AppColors.surfaceCard,
      borderColor: AppColors.borderSubtle,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.headingSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isActive: screeningProvider.currentDashboardTab == 0,
            onTap: () => screeningProvider.setDashboardTab(0),
          ),
          _buildNavItem(
            icon: Icons.biotech_rounded,
            label: 'Screening',
            isActive: false,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.cancerScreening);
            },
          ),
          _buildNavItem(
            icon: Icons.description_rounded,
            label: 'Reports',
            isActive: false,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.reports);
            },
          ),
          _buildNavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            isActive: false,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.primaryTeal : AppColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isActive ? AppColors.primaryTeal : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
