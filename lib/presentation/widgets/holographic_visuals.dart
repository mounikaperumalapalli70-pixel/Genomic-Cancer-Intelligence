import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HolographicHeroVisual extends StatefulWidget {
  final double width;
  final double height;

  const HolographicHeroVisual({
    super.key,
    this.width = 320,
    this.height = 360,
  });

  @override
  State<HolographicHeroVisual> createState() => _HolographicHeroVisualState();
}

class _HolographicHeroVisualState extends State<HolographicHeroVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _HolographicBioPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _HolographicBioPainter extends CustomPainter {
  final double progress;

  _HolographicBioPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final time = progress * 2 * math.pi;

    // 1. Ambient Background Glow Orbs
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.neonCyan.withValues(alpha: 0.15),
          AppColors.neonPurple.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.45));
    canvas.drawCircle(center, size.width * 0.45, glowPaint);

    // 2. Holographic Body Outline (Stylized Geometric/Wireframe Silhouette)
    _drawHolographicSilhouette(canvas, center, size);

    // 3. Glowing DNA Double Helix Strand (Right & Diagonal)
    _drawDnaHelix(canvas, size, time);

    // 4. Bio-Marker / Cancer Cell Glowing Orb (Right bottom side)
    _drawBiomarkerOrb(canvas, size, time);

    // 5. Floating Quantum / Genomic Particle Nodes
    _drawParticles(canvas, size, time);
  }

  void _drawHolographicSilhouette(Canvas canvas, Offset center, Size size) {
    final headCenter = Offset(center.dx - 20, center.dy - 90);
    final headRadius = 26.0;

    // Head glow & circle
    final headPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(headCenter, headRadius, headPaint);

    // Inner head grid line
    final gridPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(headCenter, headRadius * 0.6, gridPaint);

    // Torso and Arms Path
    final bodyPath = Path();
    bodyPath.moveTo(headCenter.dx - 12, headCenter.dy + headRadius + 4);
    // Neck to left shoulder
    bodyPath.lineTo(headCenter.dx - 55, headCenter.dy + headRadius + 30);
    // Left arm
    bodyPath.lineTo(headCenter.dx - 80, headCenter.dy + headRadius + 110);
    // Back to left waist
    bodyPath.lineTo(headCenter.dx - 35, headCenter.dy + headRadius + 105);
    // Left hip to leg
    bodyPath.lineTo(headCenter.dx - 30, headCenter.dy + headRadius + 190);
    // Inseam
    bodyPath.lineTo(headCenter.dx - 10, headCenter.dy + headRadius + 140);
    // Right hip to leg
    bodyPath.lineTo(headCenter.dx + 10, headCenter.dy + headRadius + 190);
    // Right waist
    bodyPath.lineTo(headCenter.dx + 15, headCenter.dy + headRadius + 105);
    // Right arm
    bodyPath.lineTo(headCenter.dx + 60, headCenter.dy + headRadius + 110);
    // Right shoulder
    bodyPath.lineTo(headCenter.dx + 35, headCenter.dy + headRadius + 30);
    bodyPath.close();

    final bodyGlowPaint = Paint()
      ..color = AppColors.neonBlue.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyGlowPaint);

    final bodyStrokePaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(bodyPath, bodyStrokePaint);

    // Horizontal Scanning Lines across torso
    final scanY = headCenter.dy + headRadius + 10 + (progress * 160) % 160;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.neonCyan.withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(headCenter.dx - 70, scanY, 140, 2))
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(headCenter.dx - 60, scanY),
      Offset(headCenter.dx + 50, scanY),
      scanPaint,
    );
  }

  void _drawDnaHelix(Canvas canvas, Size size, double time) {
    const numPoints = 22;
    const strandLength = 260.0;
    final startX = size.width * 0.72;
    final startY = size.height * 0.12;

    final strand1Paint = Paint()
      ..color = AppColors.neonCyan
      ..style = PaintingStyle.fill;

    final strand2Paint = Paint()
      ..color = AppColors.neonPurple
      ..style = PaintingStyle.fill;

    final rungPaint = Paint()
      ..color = AppColors.neonBlue.withValues(alpha: 0.45)
      ..strokeWidth = 1.2;

    for (int i = 0; i < numPoints; i++) {
      final t = i / numPoints;
      final y = startY + t * strandLength;
      final angle = t * 4 * math.pi + time;

      final xOffset = math.sin(angle) * 32.0;
      final zDepth1 = math.cos(angle);
      final zDepth2 = -zDepth1;

      final x1 = startX + xOffset;
      final x2 = startX - xOffset;

      // Draw horizontal connecting rung
      canvas.drawLine(Offset(x1, y), Offset(x2, y), rungPaint);

      // Draw Strand 1 Node
      final r1 = (zDepth1 > 0 ? 3.5 : 2.2) + math.sin(time + i) * 0.5;
      strand1Paint.color = zDepth1 > 0
          ? AppColors.neonCyan
          : AppColors.neonCyan.withValues(alpha: 0.4);
      canvas.drawCircle(Offset(x1, y), r1, strand1Paint);

      // Draw Strand 2 Node
      final r2 = (zDepth2 > 0 ? 3.5 : 2.2) + math.cos(time + i) * 0.5;
      strand2Paint.color = zDepth2 > 0
          ? AppColors.neonPurple
          : AppColors.neonPurple.withValues(alpha: 0.4);
      canvas.drawCircle(Offset(x2, y), r2, strand2Paint);
    }
  }

  void _drawBiomarkerOrb(Canvas canvas, Size size, double time) {
    final orbCenter = Offset(size.width * 0.78, size.height * 0.72);
    final baseRadius = 28.0;

    // Glowing core
    final coreShader = RadialGradient(
      colors: [
        AppColors.neonPink.withValues(alpha: 0.9),
        AppColors.neonPurple.withValues(alpha: 0.5),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: orbCenter, radius: baseRadius * 1.5));

    final corePaint = Paint()..shader = coreShader;
    canvas.drawCircle(orbCenter, baseRadius * 1.5, corePaint);

    // Spikes / Biomarker Receptors
    final spikePaint = Paint()
      ..color = AppColors.neonMagenta.withValues(alpha: 0.8)
      ..strokeWidth = 2.0;

    const numSpikes = 12;
    for (int i = 0; i < numSpikes; i++) {
      final angle = (i / numSpikes) * 2 * math.pi + time * 0.5;
      final inner = Offset(
        orbCenter.dx + math.cos(angle) * (baseRadius - 4),
        orbCenter.dy + math.sin(angle) * (baseRadius - 4),
      );
      final outer = Offset(
        orbCenter.dx + math.cos(angle) * (baseRadius + 8),
        orbCenter.dy + math.sin(angle) * (baseRadius + 8),
      );
      canvas.drawLine(inner, outer, spikePaint);
      canvas.drawCircle(outer, 2.5, spikePaint);
    }

    // Inner sphere
    final innerPaint = Paint()
      ..color = const Color(0xFF6B114D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(orbCenter, baseRadius - 6, innerPaint);
  }

  void _drawParticles(Canvas canvas, Size size, double time) {
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final randomOffsets = [
      const Offset(0.2, 0.25),
      const Offset(0.35, 0.15),
      const Offset(0.15, 0.75),
      const Offset(0.85, 0.35),
      const Offset(0.45, 0.85),
      const Offset(0.88, 0.88),
    ];

    for (int i = 0; i < randomOffsets.length; i++) {
      final base = randomOffsets[i];
      final px = (base.dx * size.width + math.sin(time + i) * 12) % size.width;
      final py = (base.dy * size.height + math.cos(time + i * 2) * 12) % size.height;

      particlePaint.color = i % 2 == 0
          ? AppColors.neonCyan.withValues(alpha: 0.6)
          : AppColors.neonPurple.withValues(alpha: 0.6);

      canvas.drawCircle(Offset(px, py), 2.0, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HolographicBioPainter oldDelegate) => true;
}
