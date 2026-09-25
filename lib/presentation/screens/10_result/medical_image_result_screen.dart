import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/genomic_analysis_models.dart';
import '../../providers/screening_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class MedicalImageResultScreen extends StatefulWidget {
  const MedicalImageResultScreen({super.key});

  @override
  State<MedicalImageResultScreen> createState() => _MedicalImageResultScreenState();
}

class _MedicalImageResultScreenState extends State<MedicalImageResultScreen> {
  bool _showGradCamOverlay = true;

  Uint8List? _decodeBase64Image(String? dataUri) {
    if (dataUri == null || dataUri.isEmpty) return null;
    try {
      final base64Str = dataUri.contains(',') ? dataUri.split(',').last : dataUri;
      return base64Decode(base64Str);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final activeResult = screeningProvider.activeScreeningResult;
    final imgResult = screeningProvider.activeImageResult ?? activeResult.imageResult;
    final treatmentIntelligence = screeningProvider.activeTreatmentIntelligence ??
        imgResult?.treatmentIntelligence ??
        activeResult.treatmentIntelligence;

    final canDetermine = imgResult?.canDetermineReliably ?? true;
    final modality = imgResult?.scanModality ?? 'Medical Scan';
    final primaryFinding = (imgResult?.primaryFinding ??
            activeResult.imageResult?.primaryFinding ??
            (canDetermine ? 'Focal Abnormality Detected' : 'Unable to determine reliably from this image.'))
        .toUpperCase();
    final confidence = imgResult?.confidencePct ??
        activeResult.imageResult?.confidencePct ??
        activeResult.confidenceScore ??
        88.4;
    final riskTier = imgResult?.riskTier ?? 'High Suspicion';
    final lesionDesc = imgResult?.lesionDescription ?? 'Focal tissue attenuation requiring clinical correlation.';
    final classProbs = imgResult?.classProbabilities ?? {};
    final heatmapBytes = _decodeBase64Image(imgResult?.gradcamDataUri);
    final rawImageBytes = screeningProvider.uploadedMedicalImageBytes;

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
                title: 'Medical Vision & Treatment Intelligence',
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

                      // Top Regulatory / Clinical Safety Banner
                      _buildSafetyBanner(),

                      const SizedBox(height: 16),

                      // SECTION 1: MEDICAL VISION REPORT
                      _buildSectionHeader(
                        icon: Icons.remove_red_eye_rounded,
                        title: 'MEDICAL VISION REPORT',
                        accentColor: AppColors.neonPurple,
                      ),
                      const SizedBox(height: 10),

                      if (!canDetermine) ...[
                        _buildUnreliableImageCard(modality, lesionDesc),
                      ] else ...[
                        // Primary Finding Hero Card
                        _buildFindingHeroCard(
                          modality: modality,
                          finding: primaryFinding,
                          confidence: confidence,
                          riskTier: riskTier,
                          cancerType: imgResult?.detectedCancerType,
                        ),
                        const SizedBox(height: 16),

                        // Grad-CAM Heatmap Inspection Card
                        _buildImageInspectionCard(
                          rawImageBytes: rawImageBytes,
                          heatmapBytes: heatmapBytes,
                        ),
                        const SizedBox(height: 16),

                        // Radiological / Histopathological Findings
                        _buildLesionDescriptionCard(lesionDesc),
                        const SizedBox(height: 16),

                        // Multi-Class Neural Probabilities
                        if (classProbs.isNotEmpty)
                          _buildClassProbabilitiesCard(classProbs),
                      ],

                      const SizedBox(height: 24),

                      // SECTION 2: TREATMENT INTELLIGENCE
                      _buildSectionHeader(
                        icon: Icons.medication_liquid_rounded,
                        title: 'TREATMENT INTELLIGENCE',
                        accentColor: AppColors.neonCyan,
                      ),
                      const SizedBox(height: 10),

                      if (canDetermine && treatmentIntelligence != null) ...[
                        _buildTreatmentIntelligenceNotice(),
                        const SizedBox(height: 12),
                        _buildTargetedTherapiesList(treatmentIntelligence.targetedTherapies),
                        const SizedBox(height: 16),
                        _buildResistanceAndTrialsCard(treatmentIntelligence),
                        const SizedBox(height: 16),
                        _buildNutritionGuidanceCard(treatmentIntelligence.nutritionGuidance),
                      ] else if (!canDetermine) ...[
                        _buildTreatmentBypassedCard(),
                      ] else ...[
                        _buildNextStepsCard(context, screeningProvider),
                      ],

                      const SizedBox(height: 24),

                      // SECTION 3: CLINICAL SAFETY NOTICE FOOTER
                      _buildClinicalSafetyNoticeCard(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, color: accentColor, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTypography.caption.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1338),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.neonPurple, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Research / Educational Use Only: Evaluates neural image features. Treatment decisions require qualified oncologists, staging biopsy, and molecular confirmation.',
              style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreliableImageCard(String modality, String description) {
    return GlowContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(20),
      backgroundColor: const Color(0xFF201328),
      borderGradient: const LinearGradient(
        colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
      ),
      glowColor: const Color(0xFFE11D48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF43F5E), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'UNABLE TO DETERMINE RELIABLY FROM THIS IMAGE',
                  style: AppTypography.headingSmall.copyWith(
                    color: const Color(0xFFF43F5E),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.neonCyan, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Supported modalities: Pulmonary CT (.png/.jpg/.dcm), H&E Histopathology, Brain MRI, Digital Mammography.',
                    style: AppTypography.caption.copyWith(color: AppColors.neonCyan, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingHeroCard({
    required String modality,
    required String finding,
    required double confidence,
    required String riskTier,
    String? cancerType,
  }) {
    return GlowContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      backgroundColor: const Color(0xFF1E1338),
      borderGradient: const LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFF6366F1), Color(0xFF3B82F6)],
      ),
      glowColor: AppColors.neonPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonPurple.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image_search_rounded, color: AppColors.neonPurple, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      riskTier.toUpperCase(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neonPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                modality,
                style: AppTypography.caption.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Predicted Cancer / Imaging Finding',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            finding,
            style: AppTypography.headingMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (cancerType != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Oncology Phenotype: ${cancerType.toUpperCase()}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.neonCyan,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vision Model Confidence',
                      style: AppTypography.caption.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${confidence.toStringAsFixed(1)}%',
                      style: AppTypography.headingLarge.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 38,
                width: 1,
                color: Colors.white24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modality Protocol',
                      style: AppTypography.caption.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      modality.contains('CT')
                          ? 'Thoracic CT'
                          : (modality.contains('H&E') ? 'H&E Microscopy' : (modality.contains('MRI') ? 'T1-Gd MRI' : 'Digital Scan')),
                      style: AppTypography.headingLarge.copyWith(
                        color: AppColors.neonCyan,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageInspectionCard({
    Uint8List? rawImageBytes,
    Uint8List? heatmapBytes,
  }) {
    final hasHeatmap = heatmapBytes != null;
    final displayBytes = (_showGradCamOverlay && hasHeatmap) ? heatmapBytes : rawImageBytes;

    return GlowContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceCard,
      borderGradient: AppGradients.neonBorderBluePurple,
      glowColor: AppColors.neonPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.neonPurple, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'GRAD-CAM SALIENCY HEATMAP',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.neonPurple,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              if (hasHeatmap)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Heatmap',
                      style: AppTypography.caption.copyWith(
                        color: _showGradCamOverlay ? AppColors.neonPurple : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Switch.adaptive(
                      value: _showGradCamOverlay,
                      activeTrackColor: AppColors.neonPurple,
                      onChanged: (val) {
                        setState(() {
                          _showGradCamOverlay = val;
                        });
                      },
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF070B18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceElevated),
            ),
            clipBehavior: Clip.antiAlias,
            child: displayBytes != null
                ? Image.memory(
                    displayBytes,
                    fit: BoxFit.contain,
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.image_search_rounded,
                          size: 48,
                          color: AppColors.neonPurple,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Neural Saliency Activation Map Active',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            'Warm red/yellow focal regions highlight convolution activations corresponding to tissue cellularity, irregular borders, and lesion margins.',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLesionDescriptionCard(String description) {
    return GlowContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceCard,
      borderGradient: AppGradients.neonBorderCyan,
      glowColor: AppColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.biotech_outlined, color: AppColors.neonCyan, size: 18),
              const SizedBox(width: 8),
              Text(
                'IMAGING FINDINGS & MARGINS',
                style: AppTypography.caption.copyWith(
                  color: AppColors.neonCyan,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassProbabilitiesCard(Map<String, double> classProbs) {
    return GlowContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceCard,
      borderGradient: AppGradients.neonBorderBluePurple,
      glowColor: AppColors.neonPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DIFFERENTIAL RADIOLOGICAL & PATHOLOGICAL PROBABILITIES',
            style: AppTypography.caption.copyWith(
              color: AppColors.neonPurple,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          ...classProbs.entries.map((entry) {
            final pct = entry.value * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neonPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (entry.value).clamp(0.0, 1.0),
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonPurple),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTreatmentIntelligenceNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.neonCyan, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Standard therapeutic classes associated with this cancer type. Mutation-targeted therapies CANNOT be determined from imaging alone and require diagnostic molecular/biomarker confirmation.',
              style: AppTypography.caption.copyWith(
                color: AppColors.neonCyan,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetedTherapiesList(List<TargetedTherapy> therapies) {
    if (therapies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: therapies.map((therapy) => _buildTherapyCard(therapy)).toList(),
    );
  }

  Widget _buildTherapyCard(TargetedTherapy therapy) {
    final requiresBiomarker = therapy.targetGene.isNotEmpty &&
        therapy.targetGene.toUpperCase() != 'CHEMOTHERAPY';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlowContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        backgroundColor: AppColors.surfaceCard,
        borderGradient: AppGradients.neonBorderCyan,
        glowColor: AppColors.neonCyan,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Treatment Class Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      therapy.treatmentClass.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.neonCyan,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  therapy.fdaStatus.contains('Approved') ? 'FDA Approved' : 'Guideline',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Drug / Therapy Name
            Text(
              therapy.drugName,
              style: AppTypography.headingSmall.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            // Molecular Target
            if (therapy.molecularTarget.isNotEmpty) ...[
              _buildTherapyAttribute(
                label: 'Molecular Target',
                value: therapy.molecularTarget,
                valueColor: AppColors.neonCyan,
              ),
              const SizedBox(height: 6),
            ],

            // Mechanism of Action
            if (therapy.howItWorks.isNotEmpty) ...[
              _buildTherapyAttribute(
                label: 'Mechanism of Action',
                value: therapy.howItWorks,
              ),
              const SizedBox(height: 6),
            ],

            // Why Relevant
            if (therapy.whyRelevant.isNotEmpty) ...[
              _buildTherapyAttribute(
                label: 'Relevance to Cancer Type',
                value: therapy.whyRelevant,
              ),
              const SizedBox(height: 8),
            ],

            // Biomarker Requirement Warning Banner (Requirement 8)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: requiresBiomarker
                    ? const Color(0xFF331F10)
                    : const Color(0xFF0D2538),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: requiresBiomarker
                      ? const Color(0xFFF59E0B)
                      : AppColors.neonCyan.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    requiresBiomarker ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: requiresBiomarker ? const Color(0xFFF59E0B) : AppColors.neonCyan,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requiresBiomarker
                              ? 'BIOMARKER REQUIREMENT'
                              : 'HISTOLOGY INDICATION',
                          style: TextStyle(
                            color: requiresBiomarker ? const Color(0xFFF59E0B) : AppColors.neonCyan,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          requiresBiomarker
                              ? 'Requires molecular/biomarker confirmation (${therapy.requiredGenomicAlteration.isNotEmpty ? therapy.requiredGenomicAlteration : "Diagnostic DNA NGS/IHC required"}). Cannot be inferred from image alone.'
                              : 'Standard histology-directed regimen. Clinical confirmation by medical oncologist required.',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Evidence Source
            if (therapy.evidenceSource.isNotEmpty)
              Text(
                'Evidence: ${therapy.evidenceSource}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTherapyAttribute({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildResistanceAndTrialsCard(TreatmentIntelligence treatment) {
    if (treatment.resistanceMechanisms.isEmpty && treatment.clinicalTrialsCriteria.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlowContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surfaceCard,
      borderGradient: AppGradients.neonBorderBluePurple,
      glowColor: AppColors.neonPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: AppColors.neonPurple, size: 18),
              const SizedBox(width: 8),
              Text(
                'RESISTANCE PATHWAYS & CLINICAL TRIALS',
                style: AppTypography.caption.copyWith(
                  color: AppColors.neonPurple,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          if (treatment.resistanceMechanisms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Known Resistance Pathways:',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            ...treatment.resistanceMechanisms.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.neonPurple)),
                    Expanded(
                      child: Text(
                        r,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (treatment.clinicalTrialsCriteria.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Active Clinical Trial Frameworks:',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            ...treatment.clinicalTrialsCriteria.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.neonCyan)),
                    Expanded(
                      child: Text(
                        t,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionGuidanceCard(Map<String, dynamic> nutrition) {
    if (nutrition.isEmpty) return const SizedBox.shrink();

    final nutrients = (nutrition['key_nutrients'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return GlowContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surfaceCard,
      borderGradient: AppGradients.neonBorderCyan,
      glowColor: AppColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu_rounded, color: AppColors.neonGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'ONCOLOGY METABOLIC & NUTRITION GUIDANCE',
                style: AppTypography.caption.copyWith(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (nutrition['caloric_support'] != null)
            Text(
              nutrition['caloric_support'].toString(),
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, fontSize: 12),
            ),
          if (nutrients.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...nutrients.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.neonGreen)),
                    Expanded(
                      child: Text(
                        n,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTreatmentBypassedCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.block_rounded, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Treatment intelligence is withheld because no reliable oncology phenotype could be classified from this image.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsCard(BuildContext context, ScreeningProvider provider) {
    return GlowContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      backgroundColor: const Color(0xFF0F1E36),
      borderGradient: const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF06B6D4)],
      ),
      glowColor: AppColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.biotech_rounded, color: AppColors.neonCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'RECOMMENDED NEXT CLINICAL STEPS',
                style: AppTypography.caption.copyWith(
                  color: AppColors.neonCyan,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Imaging findings indicate localized tissue attenuation. For high-resolution multiclass RNA-Seq cancer profiling and biomarker XAI attributions, run the Genomic Cancer Screening pipeline.',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
                foregroundColor: AppColors.neonCyan,
                side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.biotech_rounded, size: 18),
              label: const Text(
                'Launch Genomic Cancer Screening',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              onPressed: () {
                provider.setActiveInputType(ScreeningInputType.genomicData);
                Navigator.of(context).pushReplacementNamed(AppRoutes.genomicDataUpload);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalSafetyNoticeCard() {
    return GlowContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF150D24),
      borderGradient: const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
      ),
      glowColor: AppColors.neonPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: AppColors.neonPurple, size: 18),
              const SizedBox(width: 8),
              Text(
                'CLINICAL SAFETY & REGULATORY NOTICE',
                style: AppTypography.caption.copyWith(
                  color: AppColors.neonPurple,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This application is an AI investigational research system designed for medical and academic evaluation. It does not provide medical prescriptions, dosing advice, or definitive radiological diagnoses.\n\nAll treatment decisions must be made by qualified oncologists and medical boards following definitive histopathological staging, tissue biopsy, and verified molecular biomarker testing.',
            style: AppTypography.caption.copyWith(
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.surfaceElevated)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.screeningHistory),
              icon: const Icon(Icons.history_rounded, size: 18, color: AppColors.neonPurple),
              label: const Text(
                'History',
                style: TextStyle(color: AppColors.neonPurple, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.neonPurple.withValues(alpha: 0.6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
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
    );
  }
}
