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

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String _assistantSpeech = 'Almost there!\nPlease select your gender to continue.';
  bool _isAutoProgressing = false;

  void _openAiAssistant(BuildContext context, OnboardingProvider onboardingProvider) {
    AiVoiceAssistantSheet.show(
      context: context,
      mode: AssistantMode.genderSelection,
      initialLanguageCode: onboardingProvider.selectedLanguageCode,
      onGenderSelected: (gender) {
        _handleGenderSelection(gender, onboardingProvider, isVoice: true);
      },
      onComplete: () {
        if (mounted) {
          Navigator.of(context).pushNamed(AppRoutes.howItWorks);
        }
      },
    );
  }

  void _handleGenderSelection(
    Gender gender,
    OnboardingProvider onboardingProvider, {
    bool isVoice = false,
  }) {
    if (_isAutoProgressing) return;
    onboardingProvider.selectGender(gender);

    final genderLabel = gender == Gender.male
        ? 'Male'
        : (gender == Gender.female ? 'Female' : 'Other');

    setState(() {
      _assistantSpeech = 'Thank you! $genderLabel selected. Preparing your screening portal...';
      _isAutoProgressing = true;
    });

    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        Navigator.of(context).pushNamed(AppRoutes.howItWorks);
        setState(() {
          _isAutoProgressing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final selectedGender = onboardingProvider.selectedGender;

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

                      // Step 3 Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLightBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          'Step 3 of 4 • Gender',
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

                      const SizedBox(height: 24),

                      // Title & Subtitle
                      Text(
                        'Select Your Gender',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingLarge.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gender biomarkers assist in hormone receptor oncology models.',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle,
                      ),

                      const SizedBox(height: 32),

                      // Male & Female Cards
                      Row(
                        children: [
                          Expanded(
                            child: _GenderOptionCard(
                              label: 'Male',
                              icon: Icons.male_rounded,
                              isSelected: selectedGender == Gender.male,
                              accentColor: AppColors.secondaryBlue,
                              onTap: () => _handleGenderSelection(Gender.male, onboardingProvider),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _GenderOptionCard(
                              label: 'Female',
                              icon: Icons.female_rounded,
                              isSelected: selectedGender == Gender.female,
                              accentColor: const Color(0xFFE879F9),
                              onTap: () => _handleGenderSelection(Gender.female, onboardingProvider),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Other Card
                      _GenderOptionCard(
                        label: 'Other / Prefer not to say',
                        icon: Icons.transgender_rounded,
                        isSelected: selectedGender == Gender.other,
                        accentColor: AppColors.primaryTeal,
                        isFullWidth: true,
                        onTap: () => _handleGenderSelection(Gender.other, onboardingProvider),
                      ),

                      const SizedBox(height: 36),

                      // Continue Button
                      GradientButton(
                        text: 'Continue',
                        gradient: AppGradients.primaryButton,
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.howItWorks);
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

class _GenderOptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final bool isFullWidth;
  final VoidCallback onTap;

  const _GenderOptionCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    this.isFullWidth = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlowContainer(
      borderRadius: 16,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isFullWidth ? 16 : 24,
      ),
      backgroundColor: isSelected ? AppColors.surfaceLightBlue : AppColors.surfaceCard,
      isSelected: isSelected,
      borderWidth: isSelected ? 2.0 : 1.0,
      borderColor: isSelected ? AppColors.primaryTeal : AppColors.borderSubtle,
      onTap: onTap,
      child: isFullWidth
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppTypography.headingSmall.copyWith(
                    fontSize: 15,
                    color: isSelected ? AppColors.textHeading : AppColors.textPrimary,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primaryTeal.withValues(alpha: 0.15)
                        : AppColors.surfaceElevated,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryTeal : AppColors.borderSubtle,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: AppTypography.headingSmall.copyWith(
                    fontSize: 16,
                    color: isSelected ? AppColors.textHeading : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
    );
  }
}
