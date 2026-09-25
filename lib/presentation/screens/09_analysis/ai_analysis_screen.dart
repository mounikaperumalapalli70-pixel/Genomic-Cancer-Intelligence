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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Title & Subtitle
                      Text(
                        'AI Analysis in Progress',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isImage
                            ? 'Analyzing medical scan & neural feature maps...'
                            : 'Analyzing TCGA 33-class genomic signatures...',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle,
                      ),

                      const SizedBox(height: 28),

                      // Circular DNA Radar Scanner
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _RadarDnaPainter(
                                progress: _animController.value,
                              ),
                              child: Center(
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.surfaceElevated.withValues(alpha: 0.8),
                                    border: Border.all(
                                      color: AppColors.neonCyan.withValues(alpha: 0.8),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neonCyan.withValues(alpha: 0.4),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isImage ? Icons.image_search_rounded : Icons.biotech_rounded,
                                    size: 44,
                                    color: AppColors.neonCyan,
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
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '$progress%',
                            style: AppTypography.headingSmall.copyWith(
                              color: AppColors.neonCyan,
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
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Error message if any
                      if (error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'Pipeline Notice: $error',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
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
                        borderGradient: AppGradients.neonBorderCyanGreen,
                        glowColor: AppColors.neonCyan,
                        child: Column(
                          children: [
                            _buildStepItem(
                              step: '1',
                              title: isImage
                                  ? 'Image Feature Extraction'
                                  : 'Genomic Matrix Normalization',
                              status: progress >= 25 ? 'Completed' : 'Processing',
                              isDone: progress >= 25,
                            ),
                            const Divider(color: AppColors.surfaceElevated, height: 20),
                            _buildStepItem(
                              step: '2',
                              title: isImage
                                  ? 'Neural Lesion Segmentation'
                                  : '2,000 TCGA Biomarkers Alignment',
                              status: progress >= 50 ? 'Completed' : (progress >= 25 ? 'Processing' : 'Pending'),
                              isDone: progress >= 50,
                            ),
                            const Divider(color: AppColors.surfaceElevated, height: 20),
                            _buildStepItem(
                              step: '3',
                              title: isImage
                                  ? 'Grad-CAM Saliency Heatmap Synthesis'
                                  : 'Calibrated Multiclass Model Inference',
                              status: progress >= 75 ? 'Completed' : (progress >= 50 ? 'Processing' : 'Pending'),
                              isDone: progress >= 75,
                            ),
                            const Divider(color: AppColors.surfaceElevated, height: 20),
                            _buildStepItem(
                              step: '4',
                              title: 'Precision Treatment & Quantum Synthesis',
                              status: progress >= 100 ? 'Completed' : (progress >= 75 ? 'Processing' : 'Pending'),
                              isDone: progress >= 100,
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

  Widget _buildStepItem({
    required String step,
    required String title,
    required String status,
    required bool isDone,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.neonGreen.withValues(alpha: 0.2) : AppColors.surfaceElevated,
            border: Border.all(
              color: isDone ? AppColors.neonGreen : AppColors.textSecondary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: AppColors.neonGreen)
                : Text(
                    step,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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
              color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          status,
          style: AppTypography.caption.copyWith(
            color: isDone ? AppColors.neonGreen : (status == 'Processing' ? AppColors.neonCyan : AppColors.textTertiary),
            fontWeight: FontWeight.w600,
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

    final ringPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Concentric rings
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, maxRadius * (i / 3), ringPaint);
    }

    // Crosshairs
    final linePaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);

    // Rotating Radar Sweep
    final sweepAngle = progress * 2 * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi / 2,
        colors: [
          AppColors.neonCyan.withValues(alpha: 0.5),
          AppColors.neonCyan.withValues(alpha: 0.0),
        ],
        transform: GradientRotation(sweepAngle - math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarDnaPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
