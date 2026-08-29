import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class NoHighRiskResultScreen extends StatelessWidget {
  const NoHighRiskResultScreen({super.key});

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
                          color: AppColors.neonCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.neonCyan.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'UI Demonstration Mode',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neonCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Success / Clear Alert Card
                      GlowContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(18),
                        backgroundColor: const Color(0xFF0F3628),
                        borderGradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        glowColor: AppColors.neonGreen,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF165B43),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Color(0xFF10B981),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No Abnormality Detected',
                                    style: AppTypography.headingSmall.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'No signs of cancer detected by this screening model.',
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

                      const SizedBox(height: 24),

                      // Shield Emblem Visual
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonGreen.withValues(alpha: 0.12),
                          border: Border.all(
                            color: AppColors.neonGreen.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonGreen.withValues(alpha: 0.25),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.verified_user_rounded,
                            size: 58,
                            color: AppColors.neonGreen,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Supportive Lifestyle Encouragement Card
                      GlowContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(18),
                        backgroundColor: AppColors.surfaceCard,
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.neonCyan.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                Icons.sentiment_satisfied_alt_rounded,
                                size: 22,
                                color: AppColors.neonCyan,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Great! Your screening result looks good. Keep maintaining a healthy lifestyle.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Medical Disclaimer
                      Text(
                        'This is an AI-assisted screening result and not a final diagnosis.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Actions: Food Guidance, Download Report & History
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


