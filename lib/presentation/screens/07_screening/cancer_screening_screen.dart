import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../providers/screening_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';

class CancerScreeningScreen extends StatelessWidget {
  const CancerScreeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Title & Subtitle
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Cancer Screening',
                              textAlign: TextAlign.center,
                              style: AppTypography.headingLarge.copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select diagnostic modality to begin AI pipeline',
                              textAlign: TextAlign.center,
                              style: AppTypography.subtitle,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Option 1: Genomic Data Card
                      _buildScreeningOptionCard(
                        context: context,
                        title: 'Genomic Data (RNA-Seq)',
                        subtitle:
                            'Upload blood / liquid-biopsy expression matrix for TCGA Pan-Cancer & Biomarker XAI.',
                        icon: Icons.biotech_rounded,
                        iconColor: AppColors.primaryTeal,
                        iconBackground: AppColors.surfaceMint,
                        badgeText: 'TCGA Benchmark ML',
                        onTap: () {
                          screeningProvider.setActiveInputType(ScreeningInputType.genomicData);
                          Navigator.of(context).pushNamed(AppRoutes.genomicDataUpload);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Option 2: Medical / Biopsy Scan Card
                      _buildScreeningOptionCard(
                        context: context,
                        title: 'Medical Image & Scans',
                        subtitle:
                            'Upload CT, MRI, or Histopathology scan for Neural Lesion Detection & Grad-CAM Heatmaps.',
                        icon: Icons.image_search_rounded,
                        iconColor: AppColors.secondaryBlue,
                        iconBackground: AppColors.surfaceLightBlue,
                        badgeText: 'Diagnostic Vision',
                        onTap: () {
                          screeningProvider.setActiveInputType(ScreeningInputType.medicalImage);
                          Navigator.of(context).pushNamed(AppRoutes.medicalImageUpload);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Supported Formats Section
                      GlowContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.surfaceCard,
                        borderColor: AppColors.borderSubtle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.layers_outlined,
                                  color: AppColors.primaryTeal,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Supported Formats',
                                  style: AppTypography.headingSmall.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textHeading,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Genomic: CSV, TSV, TXT (RNA-Seq expression values)\nImaging: PNG, JPG, JPEG, DICOM (.dcm, scans up to 50MB)',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Privacy / Guidance Note
                      GlowContainer(
                        borderRadius: 14,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        backgroundColor: AppColors.surfaceLightBlue,
                        borderColor: AppColors.borderTeal.withValues(alpha: 0.3),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryTeal.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                Icons.verified_user_outlined,
                                size: 16,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Data is processed securely through calibrated machine learning pipelines.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreeningOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return GlowContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceCard,
      borderColor: AppColors.borderSubtle,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 46,
                height: 46,
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
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  badgeText,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTypography.headingSmall.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Launch Pipeline',
                style: AppTypography.buttonText.copyWith(
                  color: AppColors.primaryTeal,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryTeal,
                size: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
