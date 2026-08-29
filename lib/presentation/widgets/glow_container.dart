import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_gradients.dart';

class GlowContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? glowColor;
  final double glowRadius;
  final double borderWidth;
  final Gradient? borderGradient;
  final Gradient? backgroundGradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final double? width;
  final double? height;

  const GlowContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.glowColor,
    this.glowRadius = 12,
    this.borderWidth = 1.2,
    this.borderGradient,
    this.backgroundGradient,
    this.backgroundColor,
    this.onTap,
    this.isSelected = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlow = isSelected
        ? (glowColor ?? AppColors.neonCyan).withValues(alpha: 0.35)
        : (glowColor != null ? glowColor!.withValues(alpha: 0.18) : Colors.transparent);

    final effectiveBorderGradient = borderGradient ??
        (isSelected
            ? AppGradients.neonBorderBluePurple
            : LinearGradient(
                colors: [
                  AppColors.borderSubtle.withValues(alpha: 0.8),
                  AppColors.borderSubtle.withValues(alpha: 0.4),
                ],
              ));

    final effectiveBackground = backgroundGradient ??
        LinearGradient(
          colors: [
            backgroundColor ?? AppColors.surfaceCard,
            (backgroundColor ?? AppColors.surfaceCard).withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: effectiveGlow != Colors.transparent
            ? [
                BoxShadow(
                  color: effectiveGlow,
                  blurRadius: glowRadius,
                  spreadRadius: isSelected ? 1.0 : 0.0,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _GradientBorderPainter(
          gradient: effectiveBorderGradient,
          borderRadius: borderRadius,
          borderWidth: isSelected ? borderWidth * 1.3 : borderWidth,
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: effectiveBackground,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: container,
      );
    }

    return container;
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double borderRadius;
  final double borderWidth;

  _GradientBorderPainter({
    required this.gradient,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth;
  }
}
