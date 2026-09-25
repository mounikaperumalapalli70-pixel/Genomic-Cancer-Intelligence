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

class NoHighRiskResultScreen extends StatelessWidget {
  const NoHighRiskResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final activeResult = screeningProvider.activeScreeningResult;
    final genResult = screeningProvider.activeGenomicResult ?? activeResult.genomicResult;
    final confidence = (genResult != null)
        ? genResult.confidencePct
        : (activeResult.genomicResult != null
            ? activeResult.genomicResult!.confidencePct
            : (activeResult.imageResult == null ? (activeResult.confidenceScore ?? 98.1) : 98.1));

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

                      // Research Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.neonGreen.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'TCGA Pan-Cancer Model Evaluated',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neonGreen,
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
                                    'Expression profile aligns with healthy baseline references. No high-risk oncogenic signatures identified.',
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

                      const SizedBox(height: 20),

                      // Metrics Card
                      GlowContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(18),
                        backgroundColor: AppColors.surfaceCard,
                        borderGradient: AppGradients.neonBorderCyanGreen,
                        glowColor: AppColors.neonCyan,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Baseline Integrity', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text('${confidence.toStringAsFixed(1)}%', style: AppTypography.headingMedium.copyWith(color: AppColors.neonGreen, fontSize: 22)),
                              ],
                            ),
                            Container(height: 36, width: 1, color: AppColors.surfaceElevated),
                            Column(
                              children: [
                                Text('Biomarkers Tested', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text('${genResult?.inputSummary.selectedBiomarkersMatched ?? 25} Genes', style: AppTypography.headingMedium.copyWith(color: AppColors.neonCyan, fontSize: 22)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Lifestyle Recommendations Card
                      GlowContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(18),
                        backgroundColor: AppColors.surfaceCard,
                        borderGradient: AppGradients.neonBorderCyanGreen,
                        glowColor: AppColors.neonGreen,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PREVENTATIVE WELLNESS GUIDANCE',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.neonGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTip(Icons.eco_outlined, 'Maintain antioxidant and fiber-rich Mediterranean nutrition.'),
                            _buildTip(Icons.water_drop_outlined, 'Ensure optimal daily hydration (2.5 - 3.0 liters).'),
                            _buildTip(Icons.directions_run_outlined, '150 minutes of moderate weekly physical aerobic exercise.'),
                            _buildTip(Icons.schedule_outlined, 'Maintain regular annual routine health screenings.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border(top: BorderSide(color: AppColors.surfaceElevated)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.foodGuidance),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Nutritional Guidance', style: TextStyle(color: AppColors.neonCyan, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        text: 'Dashboard',
                        onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard),
                      ),
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

  Widget _buildTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.neonGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
