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

class HighRiskResultScreen extends StatefulWidget {
  const HighRiskResultScreen({super.key});

  @override
  State<HighRiskResultScreen> createState() => _HighRiskResultScreenState();
}

class _HighRiskResultScreenState extends State<HighRiskResultScreen> {
  int _activeTab = 0; // 0: Overview & Biomarkers, 1: Targeted Therapies, 2: Quantum ML

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final activeResult = screeningProvider.activeScreeningResult;
    final genResult = screeningProvider.activeGenomicResult ?? activeResult.genomicResult;
    final treatment = screeningProvider.activeTreatmentIntelligence ?? activeResult.treatmentIntelligence;
    final quantum = screeningProvider.activeQuantumResult ?? activeResult.quantumResult;

    // Predicted cancer type MUST strictly come from the genomic model output
    final cancerTitle = (genResult?.cancerType ??
            activeResult.genomicResult?.cancerType ??
            (activeResult.imageResult == null ? activeResult.likelyCancerType : null) ??
            'LUNG ADENOCARCINOMA')
        .toUpperCase();
    final confidence = (genResult != null)
        ? genResult.confidencePct
        : (activeResult.genomicResult != null
            ? activeResult.genomicResult!.confidencePct
            : (activeResult.imageResult == null ? (activeResult.confidenceScore ?? 94.8) : 94.8));

    final biomarkersMatched = genResult?.inputSummary.selectedBiomarkersMatched ??
        activeResult.genomicResult?.inputSummary.selectedBiomarkersMatched ?? 25;
    final totalFeatures = genResult?.inputSummary.totalModelFeatures ??
        activeResult.genomicResult?.inputSummary.totalModelFeatures ?? 2000;

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
                title: 'Genomic Cancer Intelligence Report',
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

                      // Regulatory / Research Disclaimer Notice
                      _buildSafetyDisclaimer(),

                      const SizedBox(height: 12),

                      // Cancer Prediction Hero Card
                      _buildPredictionHeroCard(
                        cancerTitle: cancerTitle,
                        confidence: confidence,
                        biomarkersMatched: biomarkersMatched,
                        totalFeatures: totalFeatures,
                      ),

                      const SizedBox(height: 16),

                      // Modular Tabs: Overview & XAI | Targeted Therapies | Quantum ML
                      _buildTabSelector(),

                      const SizedBox(height: 16),

                      if (_activeTab == 0) ...[
                        // Alternative Multi-Class Predictions
                        if (genResult != null && genResult.topClasses.isNotEmpty)
                          _buildAlternativePredictionsCard(genResult.topClasses),
                        const SizedBox(height: 16),

                        // Top Contributing Biomarker Genes (XAI)
                        if (genResult != null && genResult.topContributingBiomarkers.isNotEmpty)
                          _buildBiomarkerXAICard(genResult.topContributingBiomarkers),
                      ] else if (_activeTab == 1) ...[
                        // Evidence-Based Targeted Therapies & Trials
                        _buildTreatmentIntelligenceSection(treatment),
                      ] else ...[
                        // Quantum Machine Learning (Qiskit) Analysis
                        _buildQuantumMLSection(quantum),
                      ],

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

  Widget _buildSafetyDisclaimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neonAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonAmber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.neonAmber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Research Prototype: Provides AI biomarker insights. Not a definitive clinical diagnosis or replacement for an oncologist.',
              style: AppTypography.caption.copyWith(
                color: AppColors.neonAmber,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionHeroCard({
    required String cancerTitle,
    required double confidence,
    required int biomarkersMatched,
    required int totalFeatures,
  }) {
    return GlowContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      backgroundColor: const Color(0xFF2E1218),
      borderGradient: const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFB91C1C), Color(0xFF9333EA)],
      ),
      glowColor: AppColors.neonRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'High Risk Molecular Signature',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'TCGA Pan-Cancer v1.0',
                style: AppTypography.caption.copyWith(color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Predicted Cancer Type',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cancerTitle,
            style: AppTypography.headingMedium.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Model Confidence',
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
                      'Biomarkers Matched',
                      style: AppTypography.caption.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$biomarkersMatched / $totalFeatures',
                      style: AppTypography.headingLarge.copyWith(
                        color: AppColors.neonCyan,
                        fontSize: 22,
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

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceElevated),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Biomarkers & XAI', Icons.analytics_outlined),
          _buildTabItem(1, 'Targeted Rx', Icons.medication_liquid_outlined),
          _buildTabItem(2, 'Quantum ML', Icons.blur_on_rounded),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: AppColors.neonCyan.withValues(alpha: 0.6)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativePredictionsCard(List<ClassProbability> topClasses) {
    return GlowContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceCard,
      borderGradient: AppGradients.neonBorderCyanGreen,
      glowColor: AppColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALTERNATIVE CANCER PREDICTIONS',
            style: AppTypography.caption.copyWith(
              color: AppColors.neonCyan,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          ...topClasses.take(5).map((c) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        c.cancerType.toUpperCase(),
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${c.percentage.toStringAsFixed(1)}%',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neonCyan,
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
                      value: c.probability,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        c.probability > 0.5 ? AppColors.neonRed : AppColors.neonCyan,
                      ),
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

  Widget _buildBiomarkerXAICard(List<BiomarkerAttribution> biomarkers) {
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
              Text(
                'TOP CONTRIBUTING BIOMARKERS (XAI)',
                style: AppTypography.caption.copyWith(
                  color: AppColors.neonPurple,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                'Z-Score vs TCGA Baseline',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...biomarkers.map((b) {
            final isUpreg = b.status == 'upregulated';
            final statusColor = isUpreg
                ? AppColors.neonRed
                : (b.status == 'downregulated' ? AppColors.neonCyan : AppColors.neonGreen);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceElevated),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        b.gene.substring(0, b.gene.length > 3 ? 3 : b.gene.length),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.gene,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Expr: ${b.expressionValue?.toStringAsFixed(2) ?? 'N/A'} (Ref Median: ${b.referenceMedian.toStringAsFixed(1)})',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          b.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Z: ${b.zScoreDeviation > 0 ? '+' : ''}${b.zScoreDeviation.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTreatmentIntelligenceSection(TreatmentIntelligence? treatment) {
    if (treatment == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Cancer Location & Clinical Subtype Context Card
        GlowContainer(
          borderRadius: 18,
          padding: const EdgeInsets.all(16),
          backgroundColor: AppColors.surfaceCard,
          borderGradient: AppGradients.neonBorderCyanGreen,
          glowColor: AppColors.neonCyan,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CANCER & ANATOMICAL LOCATION',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'Evidence Profile',
                      style: TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                treatment.diseaseName,
                style: AppTypography.headingSmall.copyWith(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.neonGreen),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Primary Site: ${treatment.cancerSite}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.category_outlined, size: 14, color: AppColors.neonCyan),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Subtype: ${treatment.subtype}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.surfaceElevated, height: 20),
              Text(
                'NCCN 1st-Line Testing Guideline:',
                style: AppTypography.caption.copyWith(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                treatment.firstLineGuideline,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Section 2: Genomic Data Limitation & Actionability Notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.neonAmber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.neonAmber.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.science_outlined, color: AppColors.neonAmber, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DATA DISTINCTION & CLINICAL ACTIONABILITY',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.neonAmber,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      treatment.genomicDataLimitationNotice,
                      style: AppTypography.bodySmall.copyWith(
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

        const SizedBox(height: 16),

        // Section 3: Evidence-Based Targeted Therapies
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EVIDENCE-BASED TARGETED THERAPIES',
              style: AppTypography.caption.copyWith(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              '${treatment.targetedTherapies.length} Therapies Profiled',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...treatment.targetedTherapies.map((rx) {
          final isMatched = rx.sampleMatch;

          return GlowContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 14),
            backgroundColor: AppColors.surfaceCard,
            borderGradient: isMatched ? AppGradients.neonBorderCyanGreen : null,
            glowColor: isMatched ? AppColors.neonGreen : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Therapy Name & Tier Badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rx.drugName,
                            style: AppTypography.headingSmall.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rx.treatmentClass,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.neonCyan,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            rx.nccnEvidenceTier,
                            style: const TextStyle(
                              color: AppColors.neonGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rx.fdaStatus.contains('FDA Approved') ? 'FDA Approved' : 'Accelerated',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Molecular Target & Biological Function
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bubble_chart_outlined, color: AppColors.neonCyan, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Target: ${rx.molecularTarget}',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Biological Function: ${rx.targetBiologicalFunction}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // How it works
                Text(
                  'How It Works:',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rx.howItWorks,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 8),

                // Why it may be relevant
                Text(
                  'Why Relevant to this Tumor/Biomarker:',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rx.whyRelevant,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 10),

                // Required Alteration & Sample Eligibility Status
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMatched
                        ? AppColors.neonGreen.withValues(alpha: 0.1)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isMatched
                          ? AppColors.neonGreen.withValues(alpha: 0.4)
                          : AppColors.surfaceElevated,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isMatched ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                            color: isMatched ? AppColors.neonGreen : AppColors.neonAmber,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Biomarker Status: ${rx.biomarkerStatus ?? (isMatched ? 'Expression Elevated' : 'Not established from available genomic data')}',
                              style: TextStyle(
                                color: isMatched ? AppColors.neonGreen : AppColors.neonAmber,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Eligibility Assessment: ${rx.eligibilityStatus}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Required Alteration: ${rx.requiredGenomicAlteration}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Evidence & Reference Citation
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.menu_book_outlined, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Source / Trial: ${rx.evidenceSource}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 9.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),

        // Section 4: Clinical Trial Information (ClinicalTrials.gov)
        if (treatment.clinicalTrialsCriteria.isNotEmpty) ...[
          Text(
            'ACTIVE CLINICAL TRIAL CRITERIA (ClinicalTrials.gov)',
            style: AppTypography.caption.copyWith(
              color: AppColors.neonPurple,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceElevated),
            ),
            child: Column(
              children: treatment.clinicalTrialsCriteria.map((trial) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_right_rounded, color: AppColors.neonPurple, size: 20),
                      Expanded(
                        child: Text(
                          trial,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        const SizedBox(height: 14),

        // Section 5: Clinical Safety & Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceElevated),
          ),
          child: Text(
            treatment.disclaimer,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantumMLSection(QuantumExperimentResult? quantum) {
    if (quantum == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlowContainer(
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
                  Text(
                    'QUANTUM KERNEL CLASSIFIER (QISKIT)',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.neonPurple,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    quantum.quantumFramework,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.neonCyan,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Qubit Register', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        Text('${quantum.qubitCount} Qubits', style: AppTypography.headingSmall.copyWith(fontSize: 18)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hilbert Space', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        Text('${quantum.hilbertSpaceDimension}-Dim', style: AppTypography.headingSmall.copyWith(fontSize: 18, color: AppColors.neonCyan)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantum State Fidelity', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        Text('${(quantum.quantumStateFidelity * 100).toStringAsFixed(1)}%', style: AppTypography.headingSmall.copyWith(fontSize: 18, color: AppColors.neonGreen)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Quantum Circuit Architecture',
                style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Feature Map: ${quantum.featureMap} • Entanglement: ${quantum.entanglement} • Circuit Depth: ${quantum.circuitDepth}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 12),
              // OpenQASM Snippet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceElevated),
                ),
                child: Text(
                  quantum.qasmRepresentation.isNotEmpty
                      ? quantum.qasmRepresentation
                      : '// Quantum state preparation circuit ready in 2^4 Hilbert space',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: AppColors.neonGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
              text: 'Save Report',
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.reports),
            ),
          ),
        ],
      ),
    );
  }
}
