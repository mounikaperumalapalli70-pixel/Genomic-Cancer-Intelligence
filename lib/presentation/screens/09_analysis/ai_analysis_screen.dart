import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/screening_record_model.dart';
import '../../providers/screening_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLivePipeline();
    });
  }

  Future<void> _startLivePipeline() async {
    if (_hasTriggered) return;
    _hasTriggered = true;

    final screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);
    bool success = false;

    if (screeningProvider.activeInputType == ScreeningInputType.medicalImage) {
      success = await screeningProvider.executeMedicalImageAnalysis();
    } else {
      success = await screeningProvider.executeGenomicAnalysis();
    }

    if (!mounted) return;

    if (success) {
      if (screeningProvider.activeInputType == ScreeningInputType.medicalImage) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.medicalImageResult);
      } else {
        final result = screeningProvider.activeScreeningResult;
        if (result.riskLevel == ScreeningRiskLevel.highRisk) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.highRiskResult);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.noHighRiskResult);
        }
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final isImage = screeningProvider.activeInputType == ScreeningInputType.medicalImage;
    final progress = screeningProvider.analysisProgress;
    final stageText = screeningProvider.analysisStage;
    final error = screeningProvider.analysisError;

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
                        'AI Analysis in Progress',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingLarge.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isImage
                            ? 'Analyzing medical scan & neural feature maps...'
                            : 'Analyzing TCGA 33-class genomic signatures...',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle,
                      ),

                      const SizedBox(height: 28),

                      // Circular Radar Scanner
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _RadarDnaPainter(
                                progress: _animController.value,
                              ),
                              child: Center(
                                child: Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: AppColors.primaryTeal,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryTeal.withValues(alpha: 0.25),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isImage ? Icons.image_search_rounded : Icons.biotech_rounded,
                                    size: 40,
                                    color: AppColors.primaryTeal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Progress Bar & Percentage
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                height: 8,
                                child: LinearProgressIndicator(
                                  value: progress / 100.0,
                                  backgroundColor: AppColors.surfaceElevated,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '$progress%',
                            style: AppTypography.headingSmall.copyWith(
                              color: AppColors.primaryTeal,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Real Stage Text
                      Text(
                        stageText,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textHeading,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Error message if any
                      if (error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.statusDanger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.statusDanger.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Pipeline Notice: $error',
                            style: const TextStyle(color: AppColors.statusDanger, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          text: 'Retry Analysis',
                          onPressed: () {
                            setState(() {
                              _hasTriggered = false;
                            });
                            _startLivePipeline();
                          },
                        ),
                      ],

                      // Pipeline Checklist
                      GlowContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.surfaceCard,
                        borderColor: AppColors.borderSubtle,
                        child: Column(
                          children: [
                            _buildStepItem(
                              step: '1',
                              title: isImage
                                  ? 'Image Feature Extraction & Normalization'
                                  : 'Genomic Matrix Normalization (Top 2,000 Genes)',
                              status: progress >= 25 ? 'Completed' : 'Processing',
                              isDone: progress >= 25,
                            ),
                            const Divider(color: AppColors.borderSubtle, height: 20),
                            _buildStepItem(
                              step: '2',
                              title: isImage
                                  ? 'Deep Neural Lesion Segmentation'
                                  : 'Pan-Cancer Multiclass Inference',
                              status: progress >= 60 ? 'Completed' : (progress >= 25 ? 'In Progress' : 'Pending'),
                              isDone: progress >= 60,
                            ),
                            const Divider(color: AppColors.borderSubtle, height: 20),
                            _buildStepItem(
                              step: '3',
                              title: isImage
                                  ? 'Grad-CAM Saliency Heatmap Generation'
                                  : 'Biomarker XAI Attribution & Z-Score Analysis',
                              status: progress >= 80 ? 'Completed' : (progress >= 60 ? 'In Progress' : 'Pending'),
                              isDone: progress >= 80,
                            ),
                            const Divider(color: AppColors.borderSubtle, height: 20),
                            _buildStepItem(
                              step: '4',
                              title: 'Precision Oncology & Quantum Verification',
                              status: progress >= 100 ? 'Completed' : (progress >= 80 ? 'In Progress' : 'Pending'),
                              isDone: progress >= 100,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
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

  Widget _buildStepItem({
    required String step,
    required String title,
    required String status,
    required bool isDone,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.primaryTeal : AppColors.surfaceElevated,
            border: Border.all(
              color: isDone ? AppColors.primaryTeal : AppColors.borderSubtle,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : Text(
                    step,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: isDone ? AppColors.textHeading : AppColors.textSecondary,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDone ? AppColors.surfaceMint : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isDone ? AppColors.darkTeal : AppColors.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _RadarDnaPainter extends CustomPainter {
  final double progress;

  _RadarDnaPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Rings
    final ringPaint = Paint()
      ..color = AppColors.primaryTeal.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, maxRadius * 0.45, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.7, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.95, ringPaint);

    // Rotating Sweep
    final sweepAngle = progress * 2 * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi * 0.6,
        colors: [
          AppColors.primaryTeal.withValues(alpha: 0.35),
          Colors.transparent,
        ],
        transform: GradientRotation(sweepAngle),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius * 0.95, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarDnaPainter oldDelegate) => true;
}
