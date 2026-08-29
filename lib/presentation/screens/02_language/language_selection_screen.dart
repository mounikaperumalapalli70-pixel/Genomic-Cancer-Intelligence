import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/voice_assistant_service.dart';
import '../../../data/models/language_model.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/ai_voice_assistant_sheet.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  void _openAiAssistant(BuildContext context, OnboardingProvider onboardingProvider) {
    AiVoiceAssistantSheet.show(
      context: context,
      mode: AssistantMode.languageSelection,
      initialLanguageCode: onboardingProvider.selectedLanguageCode,
      onLanguageSelected: (langCode) {
        onboardingProvider.selectLanguage(langCode);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);

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

                      // Glowing Globe Wireframe Icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceElevated.withValues(alpha: 0.8),
                          border: Border.all(
                            color: AppColors.neonBlue.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonBlue.withValues(alpha: 0.35),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.language_rounded,
                            size: 38,
                            color: AppColors.neonCyan,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title & Subtitle
                      Text(
                        'Choose Your\nLanguage',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingLarge.copyWith(height: 1.2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your preferred language\nto continue',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle,
                      ),

                      const SizedBox(height: 28),

                      // Language List Options
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: LanguageModel.supportedLanguages.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final language = LanguageModel.supportedLanguages[index];
                          final isSelected =
                              language.code == onboardingProvider.selectedLanguageCode;

                          return GlowContainer(
                            isSelected: isSelected,
                            borderRadius: 14,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            backgroundColor: isSelected
                                ? const Color(0xFF132B5C)
                                : AppColors.surfaceCard,
                            borderGradient: isSelected
                                ? AppGradients.primaryButton
                                : null,
                            glowColor: isSelected ? AppColors.neonBlue : null,
                            onTap: () {
                              onboardingProvider.selectLanguage(language.code);
                            },
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.neonBlue.withValues(alpha: 0.3)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    index == 0
                                        ? Icons.language
                                        : Icons.record_voice_over_rounded,
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.neonCyan
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Language Names
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        language.name,
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      if (language.code != 'en') ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '(${language.nativeName})',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: isSelected
                                                ? AppColors.neonCyan
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Checkmark Indicator
                                if (isSelected)
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.neonBlue,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),

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
                    Navigator.of(context).pushNamed(AppRoutes.genderSelection);
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



