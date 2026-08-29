import 'package:flutter/material.dart';

class ScreeningStepModel {
  final int stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  const ScreeningStepModel({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });
}
