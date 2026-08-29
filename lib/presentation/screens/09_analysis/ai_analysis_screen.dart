import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _progress = 15;
  Timer? _progressTimer;
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Smoothly increment progress from 15% to 100%
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress < 100) {
          _progress++;
        } else {
          _progressTimer?.cancel();
          if (!_hasNavigated) {
            _hasNavigated = true;
            // Wait approximately 1 second after reaching 100% then auto-navigate
            _navigationTimer = Timer(const Duration(milliseconds: 1000), () {
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.highRiskResult);
              }
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        'Analyzing your genomic data...',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle,
                      ),

                      const SizedBox(height: 28),

                      // Futuristic Circular DNA Radar Scanner
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
                                  child: const Icon(
                                    Icons.biotech_rounded,
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
                              child: Container(
                                height: 8,
                                color: AppColors.surfaceElevated,
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progress / 100,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: AppGradients.primaryButton,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '$_progress%',
                            style: AppTypography.headingSmall.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neonCyan,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // 4 Step Checklist Process
                      GlowContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        backgroundColor: AppColors.surfaceCard,
                        child: Column(
                          children: [
                            _buildChecklistItem(
                              label: 'Data preprocessing',
                              isDone: _progress >= 30,
                              isActive: _progress < 30,
                            ),
                            const SizedBox(height: 14),
                            _buildChecklistItem(
                              label: 'Feature extraction',
                              isDone: _progress >= 60,
                              isActive: _progress >= 30 && _progress < 60,
                            ),
                            const SizedBox(height: 14),
                            _buildChecklistItem(
                              label: 'AI model analysis',
                              isDone: _progress >= 85,
                              isActive: _progress >= 60 && _progress < 85,
                            ),
                            const SizedBox(height: 14),
                            _buildChecklistItem(
                              label: 'Generating result',
                              isDone: _progress >= 100,
                              isActive: _progress >= 85 && _progress < 100,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Disclaimer Note
                      Text(
                        'This may take a few minutes.\nPlease don\'t close the app.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
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

  Widget _buildChecklistItem({
    required String label,
    required bool isDone,
    required bool isActive,
  }) {
    return Row(
      children: [
        if (isDone)
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonGreen,
            ),
            child: const Icon(
              Icons.check,
              size: 14,
              color: Colors.white,
            ),
          )
        else if (isActive)
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neonCyan, width: 2),
            ),
            child: const Center(
              child: SizedBox(
                width: 8,
                height: 8,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.neonCyan,
                ),
              ),
            ),
          )
        else
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textDisabled,
                width: 1.5,
              ),
            ),
          ),
        const SizedBox(width: 14),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isDone || isActive ? Colors.white : AppColors.textDisabled,
            fontWeight: isDone || isActive ? FontWeight.w600 : FontWeight.w400,
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

    // Outer concentric rings
    for (int i = 1; i <= 3; i++) {
      final ringPaint = Paint()
        ..color = AppColors.neonCyan.withValues(alpha: 0.15 * i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, maxRadius * (i / 3), ringPaint);
    }

    // Rotating Radar Sweep Arc
    final sweepAngle = progress * 2 * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: FractionalOffset.center,
        startAngle: 0.0,
        endAngle: math.pi / 2,
        colors: [
          Colors.transparent,
          AppColors.neonCyan.withValues(alpha: 0.45),
        ],
        transform: GradientRotation(sweepAngle),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius, sweepPaint);

    // Glowing blip particles along the orbit
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + sweepAngle;
      final radius = maxRadius * 0.75;
      final blipCenter = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final blipPaint = Paint()
        ..color = AppColors.neonCyan
        ..style = PaintingStyle.fill;
      canvas.drawCircle(blipCenter, 3.0, blipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarDnaPainter oldDelegate) => true;
}


