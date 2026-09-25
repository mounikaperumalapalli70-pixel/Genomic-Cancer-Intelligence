import 'package:file_picker/file_picker.dart';
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

class GenomicUploadScreen extends StatelessWidget {
  const GenomicUploadScreen({super.key});

  Future<void> _pickGenomicFile(
    BuildContext context,
    ScreeningProvider screeningProvider,
  ) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'tsv', 'txt', 'json'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        final sizeBytes = await file.length();
        final sizeInMb = sizeBytes / (1024 * 1024);
        final formattedSize = sizeInMb >= 0.1
            ? '${sizeInMb.toStringAsFixed(1)} MB'
            : '${(sizeBytes / 1024).toStringAsFixed(0)} KB';

        screeningProvider.setUploadedGenomicFile(
          name: file.name,
          size: formattedSize,
          bytes: bytes,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceElevated,
            content: Text('File picker notice: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context);

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
                        child: Text(
                          'Upload Genomic Data',
                          textAlign: TextAlign.center,
                          style: AppTypography.headingLarge,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Select your expression matrix or load a curated TCGA benchmark sample',
                          textAlign: TextAlign.center,
                          style: AppTypography.subtitle,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section A: 1-Click Curated TCGA Pan-Cancer Benchmark Samples
                      _buildCuratedSamplesSection(context, screeningProvider),

                      const SizedBox(height: 24),

                      // Section B: Custom File Upload (Drag & Drop Dropzone)
                      Text(
                        'OR UPLOAD CUSTOM FILE',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildUploadDropZone(context, screeningProvider),

                      const SizedBox(height: 20),

                      // Uploaded / Selected File Card
                      if (screeningProvider.hasUploadedGenomicFile)
                        _buildUploadedFileCard(context, screeningProvider),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Action: Start Analysis Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: GradientButton(
                  text: 'Start AI Analysis',
                  onPressed: screeningProvider.hasUploadedGenomicFile
                      ? () {
                          screeningProvider.setActiveInputType(ScreeningInputType.genomicData);
                          Navigator.of(context).pushNamed(AppRoutes.aiAnalysis);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCuratedSamplesSection(
    BuildContext context,
    ScreeningProvider screeningProvider,
  ) {
    final samples = screeningProvider.curatedSamples;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1-CLICK TCGA BENCHMARK SAMPLES',
              style: AppTypography.caption.copyWith(
                color: AppColors.neonCyan,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Trained Model Ready',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neonCyan,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 125,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: samples.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final sample = samples[index];
              final isSelected = screeningProvider.selectedCuratedSample?.id == sample.id;

              return GestureDetector(
                onTap: () => screeningProvider.selectCuratedSample(sample),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.neonCyan.withValues(alpha: 0.15)
                        : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.neonCyan
                          : AppColors.surfaceElevated,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.neonCyan.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.neonCyan
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              sample.id,
                              style: TextStyle(
                                color: isSelected ? Colors.black : AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.neonCyan,
                              size: 16,
                            ),
                        ],
                      ),
                      Text(
                        sample.cancerType.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${sample.expressionData.isNotEmpty ? sample.expressionData.length : 25} Driver Genes Matrix',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUploadDropZone(
    BuildContext context,
    ScreeningProvider screeningProvider,
  ) {
    return GestureDetector(
      onTap: () => _pickGenomicFile(context, screeningProvider),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonCyan.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withValues(alpha: 0.1),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonCyan.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: AppColors.neonCyan,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Browse Expression File',
              style: AppTypography.headingSmall.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Supports CSV, TSV, TXT, or JSON (Gene Symbol + log2 Expression)',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFileCard(
    BuildContext context,
    ScreeningProvider screeningProvider,
  ) {
    return GlowContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surfaceCard,
      borderGradient: AppGradients.neonBorderCyanGreen,
      glowColor: AppColors.neonCyan,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.biotech_rounded,
              color: AppColors.neonCyan,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  screeningProvider.uploadedGenomicFileName ?? 'expression_matrix.csv',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${screeningProvider.uploadedGenomicFileSize ?? '2.4 MB'} • Validated Profile',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neonGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: () => screeningProvider.clearUploadedGenomicFile(),
          ),
        ],
      ),
    );
  }
}
