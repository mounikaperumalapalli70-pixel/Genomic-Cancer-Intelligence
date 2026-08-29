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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Title & Subtitle
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Cancer Screening',
                              textAlign: TextAlign.center,
                              style: AppTypography.headingLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'What would you like to analyze?',
                              textAlign: TextAlign.center,
                              style: AppTypography.subtitle,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Option 1: Genomic Data Card
                      _buildScreeningOptionCard(
                        context: context,
                        title: 'Genomic Data',
                        subtitle:
                            'Upload blood / liquid-biopsy\ngenomic data for AI analysis.',
                        icon: Icons.biotech_rounded,
                        iconColor: AppColors.neonCyan,
                        iconBackground: const Color(0xFF0C2B4E),
                        borderGradient: AppGradients.neonBorderCyan,
                        glowColor: AppColors.neonCyan,
                        onTap: () {
                          screeningProvider.setActiveInputType(ScreeningInputType.genomicData);
                          Navigator.of(context).pushNamed(AppRoutes.genomicDataUpload);
                        },
                      ),

                      const SizedBox(height: 18),

                      // Option 2: Medical / Biopsy Scan Card
                      _buildScreeningOptionCard(
                        context: context,
                        title: 'Medical Image',
                        subtitle:
                            'Upload a supported medical\nimage or scan for AI analysis.',
                        icon: Icons.image_search_rounded,
                        iconColor: AppColors.neonPurple,
                        iconBackground: const Color(0xFF221344),
                        borderGradient: AppGradients.neonBorderBluePurple,
                        glowColor: AppColors.neonPurple,
                        onTap: () {
                          screeningProvider.setActiveInputType(ScreeningInputType.medicalImage);
                          Navigator.of(context).pushNamed(AppRoutes.medicalImageUpload);
                        },
                      ),

                      const SizedBox(height: 32),

                      // Supported Formats Section
                      GlowContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.surfaceCard,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.layers_outlined,
                                  color: AppColors.neonCyan,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Supported Formats',
                                  style: AppTypography.headingSmall.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'PDF, CSV, Excel (XLS, XLSX), TXT (Max 50MB)\nJPG, JPEG, PNG, DICOM (.dcm) (Max 50MB)',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Privacy / Guidance Note
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
                                'Use only your own medical data. This helps us provide accurate results.',
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
    required Gradient borderGradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return GlowContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      borderGradient: borderGradient,
      glowColor: glowColor,
      glowRadius: 14,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headingSmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ],
      ),
    );
  }
}


