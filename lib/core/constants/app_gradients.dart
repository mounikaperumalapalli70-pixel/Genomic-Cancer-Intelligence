import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  // Primary Action Button (Blue to Purple Neon)
  static const LinearGradient primaryButton = LinearGradient(
    colors: [
      Color(0xFF2563EB),
      Color(0xFF7C3AED),
      Color(0xFF9333EA),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Cyan to Blue Gradient
  static const LinearGradient cyanBlue = LinearGradient(
    colors: [
      AppColors.neonCyan,
      AppColors.neonBlue,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Purple to Pink Gradient
  static const LinearGradient purplePink = LinearGradient(
    colors: [
      AppColors.neonPurple,
      AppColors.neonMagenta,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Background Gradient
  static const LinearGradient cardDark = LinearGradient(
    colors: [
      Color(0xFF111D3E),
      Color(0xFF0B142B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Male Card Gradient (Cyan Tint)
  static const LinearGradient maleCard = LinearGradient(
    colors: [
      Color(0xFF0B2545),
      Color(0xFF09162E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Female Card Gradient (Pink Tint)
  static const LinearGradient femaleCard = LinearGradient(
    colors: [
      Color(0xFF33142D),
      Color(0xFF1B0B24),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Other Card Gradient (Purple Tint)
  static const LinearGradient otherCard = LinearGradient(
    colors: [
      Color(0xFF221544),
      Color(0xFF120C28),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Hero Card Gradient (Dashboard)
  static const LinearGradient heroCard = LinearGradient(
    colors: [
      Color(0xFF162553),
      Color(0xFF0E1A3D),
      Color(0xFF081028),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glowing Border Gradients
  static const LinearGradient neonBorderBluePurple = LinearGradient(
    colors: [
      AppColors.neonCyan,
      AppColors.neonBlue,
      AppColors.neonPurple,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonBorderPink = LinearGradient(
    colors: [
      AppColors.neonMagenta,
      Color(0xFFF43F5E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonBorderCyan = LinearGradient(
    colors: [
      AppColors.neonCyan,
      Color(0xFF38BDF8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background Ambient Glow (Radial)
  static const RadialGradient backgroundAura = RadialGradient(
    center: Alignment(0.0, -0.4),
    radius: 1.2,
    colors: [
      Color(0xFF132454),
      Color(0xFF080D21),
      Color(0xFF04060F),
    ],
    stops: [0.0, 0.6, 1.0],
  );
}
