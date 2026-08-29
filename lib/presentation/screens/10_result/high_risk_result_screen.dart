import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../providers/screening_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class HighRiskResultScreen extends StatelessWidget {
  const HighRiskResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final activeResult = screeningProvider.activeScreeningResult;

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
                title: 'Screening Completed',
                showBackButton: true,
                onBackPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Demo Notice Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neonAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.neonAmber.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'UI Demonstration Mode',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neonAmber,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // High Risk Alert Card
                      GlowContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(18),
                        backgroundColor: const Color(0xFF38141C),
                        borderGradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                        ),
                        glowColor: AppColors.neonRed,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5C1B28),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFEF4444),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'High Risk Detected',
                                    style: AppTypography.headingSmall.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFEF4444),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cancer may be present. Please consult a doctor for further evaluation.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Cancer Type & Confidence Card
                      GlowContainer(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(20),
                        backgroundColor: AppColors.surfaceCard,
                        borderGradient: AppGradients.neonBorderBluePurple,
                        glowColor: AppColors.neonPurple,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Likely Cancer Type',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      activeResult.likelyCancerType ?? 'Lung Cancer',
                                      style: AppTypography.headingMedium.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                // Lungs Bio-Graphic Visual
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.neonPurple.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.neonPurple.withValues(alpha: 0.5),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.air_rounded,
                                    size: 34,
                                    color: AppColors.neonMagenta,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Confidence Score Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Confidence Score',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${activeResult.confidenceScore ?? 87.6}%',
                                  style: AppTypography.headingSmall.copyWith(
                                    fontSize: 16,
                                    color: AppColors.neonCyan,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                height: 8,
                                color: AppColors.surfaceElevated,
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 0.876,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: AppGradients.purplePink,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Medical Disclaimer Banner
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
                                'This result is based on AI analysis of your genomic data and is not a definitive diagnosis.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
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

              // Bottom Actions: Download Report & View History & Food Guidance
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    GradientButton(
                      text: 'Personalized Food Guidance',
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.foodGuidance);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.borderSubtle),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.file_download_outlined, size: 18),
                            label: const Text('Download Report'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.surfaceElevated,
                                  content: Text('Downloading genomic screening PDF report...'),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.neonCyan,
                              side: const BorderSide(color: AppColors.borderSubtle),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('View History'),
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRoutes.screeningHistory);
                            },
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
      ),
    );
  }
}


