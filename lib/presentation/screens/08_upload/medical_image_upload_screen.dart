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

class MedicalImageUploadScreen extends StatelessWidget {
  const MedicalImageUploadScreen({super.key});

  Future<void> _pickMedicalScan(
    BuildContext context,
    ScreeningProvider screeningProvider,
  ) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'dcm', 'dicom'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        final sizeBytes = await file.length();
        final sizeInMb = sizeBytes / (1024 * 1024);
        final formattedSize = sizeInMb >= 0.1
            ? '${sizeInMb.toStringAsFixed(1)} MB'
            : '${(sizeBytes / 1024).toStringAsFixed(0)} KB';

        screeningProvider.setUploadedMedicalImage(
          name: file.name,
          size: formattedSize,
          bytes: bytes,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryTeal,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Title & Subtitle
                      Text(
                        'Upload Medical Scan',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingLarge.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select your medical image or scan\n(X-ray, CT, MRI, Histopathology)',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle,
                      ),

                      const SizedBox(height: 28),

                      // Drag & Drop Upload Container
                      _buildUploadDropZone(context, screeningProvider),

                      const SizedBox(height: 20),

                      // Uploaded File Card
                      if (screeningProvider.hasUploadedMedicalImage)
                        _buildUploadedFileCard(context, screeningProvider),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Action: Start Analysis Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: GradientButton(
                  text: 'Start Image Analysis',
                  gradient: AppGradients.primaryButton,
                  onPressed: screeningProvider.hasUploadedMedicalImage
                      ? () {
                          screeningProvider.setActiveInputType(ScreeningInputType.medicalImage);
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

  Widget _buildUploadDropZone(
    BuildContext context,
    ScreeningProvider screeningProvider,
  ) {
    return GestureDetector(
      onTap: () => _pickMedicalScan(context, screeningProvider),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceLightBlue,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.secondaryBlue.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.secondaryBlue.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.image_search_rounded,
                color: AppColors.secondaryBlue,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Browse Medical Scan',
              style: AppTypography.headingSmall.copyWith(
                fontSize: 16,
                color: AppColors.secondaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Supported: JPG, PNG, DICOM (.dcm, max 50MB)',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
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
      padding: const EdgeInsets.all(14),
      backgroundColor: AppColors.surfaceCard,
      borderColor: AppColors.secondaryBlue,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceLightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: AppColors.secondaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  screeningProvider.uploadedMedicalImageName ?? 'scan.png',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${screeningProvider.uploadedMedicalImageSize ?? '3.5 MB'} • Ready for Grad-CAM',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: () => screeningProvider.clearUploadedMedicalImage(),
          ),
        ],
      ),
    );
  }
}
