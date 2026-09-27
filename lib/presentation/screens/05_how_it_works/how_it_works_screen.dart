import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarding = Provider.of<OnboardingProvider>(context, listen: false);

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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Step 4 Progress Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLightBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          'Step 4 of 4 • Overview',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Title & Subtitle
                      Text(
                        'How Our Genomic\nScreening Works',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingLarge.copyWith(height: 1.2, fontSize: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'From a simple blood sample or scan to\npowerful precision oncology intelligence',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle,
                      ),

                      const SizedBox(height: 24),

                      // Step 1 Card
                      _buildStepCard(
                        stepNumber: '1',
                        icon: Icons.science_outlined,
                        iconColor: AppColors.primaryTeal,
                        iconBackground: AppColors.surfaceMint,
                        title: 'Blood / Liquid-Biopsy Genomic Data',
                        description:
                            'We analyze 2,000+ cancer-related RNA-seq gene expression biomarkers from your blood sample.',
                      ),

                      const SizedBox(height: 14),

                      // Step 2 Card
                      _buildStepCard(
                        stepNumber: '2',
                        icon: Icons.memory_rounded,
                        iconColor: AppColors.secondaryBlue,
                        iconBackground: AppColors.surfaceLightBlue,
                        title: 'Calibrated Multimodal AI Pipeline',
                        description:
                            'TCGA-trained machine learning classifiers analyze pan-cancer signatures and compute biomarker attributions (XAI).',
                      ),

                      const SizedBox(height: 14),

                      // Step 3 Card
                      _buildStepCard(
                        stepNumber: '3',
                        icon: Icons.verified_user_outlined,
                        iconColor: AppColors.statusSuccess,
                        iconBackground: AppColors.surfaceMint,
                        title: 'Targeted Rx & Quantum Verification',
                        description:
                            'Receive NCCN guideline evidence-based targeted therapies and 4-qubit simulated statevector calculations.',
                      ),

                      const SizedBox(height: 20),

                      // Safety Notice Banner
                      GlowContainer(
                        borderRadius: 14,
                        padding: const EdgeInsets.all(14),
                        backgroundColor: AppColors.surfaceLightBlue,
                        borderColor: AppColors.borderTeal.withValues(alpha: 0.3),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryTeal.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This platform is for clinical research decision support and not a substitute for formal histopathological diagnosis.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  height: 1.35,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: GradientButton(
                  text: 'Enter Clinical Dashboard',
                  gradient: AppGradients.primaryButton,
                  onPressed: () {
                    onboarding.completeOnboarding();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.dashboard,
                      (route) => false,
                    );
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
      borderColor: AppColors.borderSubtle,
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
              color: AppColors.primaryTeal,
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
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
                    color: AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: 4),
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
