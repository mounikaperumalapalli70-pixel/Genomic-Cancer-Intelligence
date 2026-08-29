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
        final sizeBytes = await file.length();
        final sizeInMb = sizeBytes / (1024 * 1024);
        final formattedSize = sizeInMb >= 0.1
            ? '${sizeInMb.toStringAsFixed(1)} MB'
            : '${(sizeBytes / 1024).toStringAsFixed(0)} KB';

        screeningProvider.setUploadedMedicalImage(
          name: file.name,
          size: formattedSize,
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
                    children: [
                      const SizedBox(height: 10),

                      // Title & Subtitle
                      Text(
                        'Upload Medical Scan',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select your medical image or scan\n(X-ray, CT, MRI, Histopathology)',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle,
                      ),

                      const SizedBox(height: 32),

                      // Drag & Drop Upload Container (Opens Real File Picker for Images/DICOM)
                      _buildUploadDropZone(context, screeningProvider),

                      const SizedBox(height: 24),

                      // Uploaded File Card (Only shown if an image was selected)
                      if (screeningProvider.hasUploadedMedicalImage)
                        _buildUploadedFileCard(context, screeningProvider),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Action: Start Analysis Button (Disabled until scan selected)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: GradientButton(
                  text: 'Start Image Analysis',
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
          color: AppColors.surfaceCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonPurple.withValues(alpha: 0.5),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPurple.withValues(alpha: 0.12),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonPurple.withValues(alpha: 0.18),
                border: Border.all(
                  color: AppColors.neonPurple.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.neonPurple,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Drag & drop your medical scan here\nor click to browse',
              textAlign: TextAlign.center,
              style: AppTypography.headingSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Supported: JPG, JPEG, PNG, DICOM (.dcm)\n(Max 50MB)',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      backgroundColor: AppColors.surfaceCard,
      borderGradient: AppGradients.neonBorderBluePurple,
      glowColor: AppColors.neonPurple,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2E1344),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.neonPurple.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: AppColors.neonPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  screeningProvider.uploadedMedicalImageName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  screeningProvider.uploadedMedicalImageSize ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () {
              screeningProvider.removeUploadedMedicalImage();
            },
          ),
        ],
      ),
    );
  }
}


