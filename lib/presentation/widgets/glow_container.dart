import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GlowContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? glowColor;
  final double glowRadius;
  final double borderWidth;
  final Color? borderColor;
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
    this.glowRadius = 10,
    this.borderWidth = 1.0,
    this.borderColor,
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
    final effectiveBorderColor = borderColor ??
        (isSelected
            ? AppColors.primaryTeal
            : AppColors.borderSubtle);

    final effectiveBackground = backgroundColor ?? AppColors.surfaceCard;

    final effectiveShadow = isSelected
        ? [
            BoxShadow(
              color: (glowColor ?? AppColors.primaryTeal).withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ]
        : [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: glowRadius,
              offset: const Offset(0, 3),
            ),
          ];

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundGradient == null ? effectiveBackground : null,
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: isSelected ? borderWidth * 1.5 : borderWidth,
        ),
        boxShadow: effectiveShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
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
