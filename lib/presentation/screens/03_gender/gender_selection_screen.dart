import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/voice_assistant_service.dart';
import '../../../data/models/user_profile_model.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/ai_voice_assistant_sheet.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class GenderSelectionScreen extends StatelessWidget {
  const GenderSelectionScreen({super.key});

  void _openAiAssistant(BuildContext context, OnboardingProvider onboardingProvider) {
    AiVoiceAssistantSheet.show(
      context: context,
      mode: AssistantMode.genderSelection,
      initialLanguageCode: onboardingProvider.selectedLanguageCode,
      onGenderSelected: (gender) {
        onboardingProvider.selectGender(gender);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final selectedGender = onboardingProvider.selectedGender;

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
                      const SizedBox(height: 24),

                      // Title & Subtitle
                      Text(
                        'Tell Us About You',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your gender',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle,
                      ),

                      const SizedBox(height: 48),

                      // Male & Female Row Cards
                      Row(
                        children: [
                          // Male Card
                          Expanded(
                            child: _GenderCard(
                              label: 'Male',
                              icon: Icons.person_rounded,
                              isSelected: selectedGender == Gender.male,
                              accentColor: AppColors.neonCyan,
                              backgroundGradient: AppGradients.maleCard,
                              borderGradient: selectedGender == Gender.male
                                  ? AppGradients.neonBorderCyan
                                  : null,
                              glowColor: AppColors.neonCyan,
                              onTap: () => onboardingProvider.selectGender(Gender.male),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Female Card
                          Expanded(
                            child: _GenderCard(
                              label: 'Female',
                              icon: Icons.person_rounded,
                              isSelected: selectedGender == Gender.female,
                              accentColor: AppColors.neonMagenta,
                              backgroundGradient: AppGradients.femaleCard,
                              borderGradient: selectedGender == Gender.female
                                  ? AppGradients.neonBorderPink
                                  : null,
                              glowColor: AppColors.neonMagenta,
                              onTap: () => onboardingProvider.selectGender(Gender.female),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Other Card (Full Width)
                      _GenderCard(
                        label: 'Other',
                        icon: Icons.person_outline_rounded,
                        isSelected: selectedGender == Gender.other,
                        accentColor: AppColors.neonPurple,
                        backgroundGradient: AppGradients.otherCard,
                        borderGradient: selectedGender == Gender.other
                            ? AppGradients.primaryButton
                            : null,
                        glowColor: AppColors.neonPurple,
                        height: 130,
                        onTap: () => onboardingProvider.selectGender(Gender.other),
                      ),

                      const SizedBox(height: 24),

                      // Floating AI Assistant Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: AiAssistantFab(
                          onTap: () => _openAiAssistant(context, onboardingProvider),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: GradientButton(
                  text: 'Continue',
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.basicInfo);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final Gradient backgroundGradient;
  final Gradient? borderGradient;
  final Color glowColor;
  final double height;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.backgroundGradient,
    this.borderGradient,
    required this.glowColor,
    this.height = 150,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlowContainer(
      isSelected: isSelected,
      height: height,
      borderRadius: 18,
      backgroundGradient: backgroundGradient,
      borderGradient: borderGradient,
      glowColor: glowColor,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: isSelected ? 0.25 : 0.12),
              border: Border.all(
                color: accentColor.withValues(alpha: isSelected ? 0.8 : 0.3),
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              size: 26,
              color: isSelected ? Colors.white : accentColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: AppTypography.headingSmall.copyWith(
              fontSize: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


