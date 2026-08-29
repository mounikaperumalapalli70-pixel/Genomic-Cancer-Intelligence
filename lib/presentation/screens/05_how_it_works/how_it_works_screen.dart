import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundAura,
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                showBackButton: true,
                onBackPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Title & Subtitle
                      Text(
                        'How Our Genomic\nScreening Works',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingLarge.copyWith(height: 1.2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'From a simple blood sample to\npowerful AI analysis',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle,
                      ),

                      const SizedBox(height: 28),

                      // Step 1 Card: Blood / Liquid-Biopsy Genomic Data
                      _buildStepCard(
                        stepNumber: '1',
                        icon: Icons.science_outlined,
                        iconColor: const Color(0xFFEF4444),
                        iconBackground: const Color(0xFF3B1520),
                        title: 'Blood / Liquid-Biopsy\nGenomic Data',
                        description:
                            'We analyze cancer-related DNA and cell information from your blood sample.',
                      ),

                      const SizedBox(height: 16),

                      // Step 2 Card: AI Analysis
                      _buildStepCard(
                        stepNumber: '2',
                        icon: Icons.memory_rounded,
                        iconColor: AppColors.neonCyan,
                        iconBackground: const Color(0xFF0C2B4E),
                        title: 'AI Analysis',
                        description:
                            'Advanced AI models analyze the data to find cancer signals and patterns.',
                      ),

                      const SizedBox(height: 16),

                      // Step 3 Card: Early Cancer Risk / Detection
                      _buildStepCard(
                        stepNumber: '3',
                        icon: Icons.verified_user_outlined,
                        iconColor: AppColors.neonGreen,
                        iconBackground: const Color(0xFF0F382B),
                        title: 'Early Cancer Risk / Detection',
                        description:
                            'Get early risk assessment and detection results for better outcomes.',
                      ),

                      const SizedBox(height: 24),

                      // Disclaimer Banner
                      GlowContainer(
                        borderRadius: 14,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        backgroundColor: const Color(0xFF0E1A38),
                        borderGradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.neonBlue.withValues(alpha: 0.25),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: AppColors.neonCyan,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This screening is AI-assisted and not a definitive diagnosis.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button: Continue to Dashboard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: GradientButton(
                  text: 'Continue',
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.dashboard);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String description,
  }) {
    return GlowContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surfaceCard,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number Badge
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonBlue,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Step Icon Frame
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headingSmall.copyWith(
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


