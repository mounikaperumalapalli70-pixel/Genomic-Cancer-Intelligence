import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  // Primary Clinical Action Button (Teal -> Mint Gradient)
  static const LinearGradient primaryButton = LinearGradient(
    colors: [
      Color(0xFF149C91),
      Color(0xFF18B6A4),
      Color(0xFF40D0A5),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Teal to Mint Gradient
  static const LinearGradient tealMint = LinearGradient(
    colors: [
      Color(0xFF149C91),
      Color(0xFF18B6A4),
      Color(0xFF40D0A5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Cyan to Blue Clinical Gradient
  static const LinearGradient cyanBlue = LinearGradient(
    colors: [
      Color(0xFF3AA7E8),
      Color(0xFF18B6A4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft Purple to Pink Tint
  static const LinearGradient purplePink = LinearGradient(
    colors: [
      Color(0xFF818CF8),
      Color(0xFFF472B6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Background Gradient (Clean Hospital White to Off-White)
  static const LinearGradient cardDark = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FCFC),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Male Card Gradient (Soft Light Blue Tint)
  static const LinearGradient maleCard = LinearGradient(
    colors: [
      Color(0xFFEAF7FF),
      Color(0xFFFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Female Card Gradient (Soft Rose / Pink Tint)
  static const LinearGradient femaleCard = LinearGradient(
    colors: [
      Color(0xFFFDF2F8),
      Color(0xFFFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Other Card Gradient (Soft Purple Tint)
  static const LinearGradient otherCard = LinearGradient(
    colors: [
      Color(0xFFF5F3FF),
      Color(0xFFFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Hero Card Gradient (Dashboard - Soft Clinical Blue-Mint)
  static const LinearGradient heroCard = LinearGradient(
    colors: [
      Color(0xFFEAF7FF),
      Color(0xFFE8FAF3),
      Color(0xFFFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Subtle Clinical Border
  static const LinearGradient subtleBorder = LinearGradient(
    colors: [
      Color(0xFFD5EBF0),
      Color(0xFFE2EFF3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glowing / Subtle Clinical Border Gradients
  static const LinearGradient neonBorderBluePurple = LinearGradient(
    colors: [
      AppColors.primaryTeal,
      AppColors.secondaryBlue,
      Color(0xFF818CF8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonBorderPink = LinearGradient(
    colors: [
      Color(0xFFF472B6),
      Color(0xFFFB7185),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonBorderCyan = LinearGradient(
    colors: [
      AppColors.primaryTeal,
      AppColors.secondaryBlue,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonBorderCyanGreen = LinearGradient(
    colors: [
      AppColors.primaryTeal,
      AppColors.mintGreen,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background Ambient Glow (Light Clean Radial)
  static const RadialGradient backgroundAura = RadialGradient(
    center: Alignment(0.0, -0.4),
    radius: 1.2,
    colors: [
      Color(0xFFF0F9FB),
      Color(0xFFF8FCFC),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
