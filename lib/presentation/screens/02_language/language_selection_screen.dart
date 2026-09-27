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

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _assistantSpeech = 'Great! 🌍\nPlease choose your preferred language to continue.';
  bool _isAutoProgressing = false;

  void _openAiAssistant(BuildContext context, OnboardingProvider onboardingProvider) {
    AiVoiceAssistantSheet.show(
      context: context,
      mode: AssistantMode.languageSelection,
      initialLanguageCode: onboardingProvider.selectedLanguageCode,
      onLanguageSelected: (langCode) {
        _handleLanguageSelection(langCode, onboardingProvider, isVoice: true);
      },
      onComplete: () {
        if (mounted) {
          Navigator.of(context).pushNamed(AppRoutes.basicInfo);
        }
      },
    );
  }

  void _handleLanguageSelection(
    String langCode,
    OnboardingProvider onboardingProvider, {
    bool isVoice = false,
  }) {
    if (_isAutoProgressing) return;
    onboardingProvider.selectLanguage(langCode);

    final lang = LanguageModel.supportedLanguages.firstWhere(
      (l) => l.code == langCode,
      orElse: () => LanguageModel.supportedLanguages.first,
    );

    setState(() {
      _assistantSpeech = 'Great! ${lang.name} (${lang.nativeName}) selected. Setting up your profile...';
      _isAutoProgressing = true;
    });

    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        Navigator.of(context).pushNamed(AppRoutes.basicInfo);
        setState(() {
          _isAutoProgressing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final selectedCode = onboardingProvider.selectedLanguageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: AiAssistantFab(
        onTap: () => _openAiAssistant(context, onboardingProvider),
      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Step 1 Progress indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLightBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          'Step 1 of 4 • Language',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // AI Assistant Guiding Card at Top
                      GlowContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.surfaceCard,
                        borderWidth: 1.2,
                        borderColor: AppColors.borderTeal.withValues(alpha: 0.3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.tealMint,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryTeal.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.smart_toy_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI Care Assistant',
                                    style: AppTypography.headingSmall.copyWith(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _assistantSpeech,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title & Subtitle
                      Text(
                        'Choose Your Language',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingLarge.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You can change this anytime in settings.',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle,
                      ),

                      const SizedBox(height: 20),

                      // Language Grid Cards
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: LanguageModel.supportedLanguages.length,
                        itemBuilder: (context, index) {
                          final language = LanguageModel.supportedLanguages[index];
                          final isSelected = language.code == selectedCode;

                          return GlowContainer(
                            borderRadius: 14,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            backgroundColor: isSelected
                                ? AppColors.surfaceLightBlue
                                : AppColors.surfaceCard,
                            isSelected: isSelected,
                            borderWidth: isSelected ? 1.8 : 1.0,
                            borderColor: isSelected
                                ? AppColors.primaryTeal
                                : AppColors.borderSubtle,
                            onTap: () {
                              _handleLanguageSelection(language.code, onboardingProvider);
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        language.name,
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.textHeading
                                              : AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        language.nativeName,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: isSelected
                                              ? AppColors.primaryTeal
                                              : AppColors.textSecondary,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryTeal,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Continue Button
                      GradientButton(
                        text: 'Continue',
                        gradient: AppGradients.primaryButton,
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.basicInfo);
                        },
                      ),

                      const SizedBox(height: 80),
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
}
