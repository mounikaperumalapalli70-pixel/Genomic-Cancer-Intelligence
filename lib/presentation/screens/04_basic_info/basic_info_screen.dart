import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/information_extraction_service.dart';
import '../../../core/services/voice_assistant_service.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/ai_voice_assistant_sheet.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedBloodGroup;
  String _assistantSpeech = "Nice! Let's get to know you better.\nPlease fill in your basic information.";

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<OnboardingProvider>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile.name ?? '');
    _ageController = TextEditingController(text: profile.age?.toString() ?? '');
    _heightController = TextEditingController(
      text: profile.heightCm != null ? profile.heightCm!.toInt().toString() : '',
    );
    _weightController = TextEditingController(
      text: profile.weightKg != null ? profile.weightKg!.toInt().toString() : '',
    );
    _selectedBloodGroup = profile.bloodGroup;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _openAiAssistant(BuildContext context) {
    final onboarding = Provider.of<OnboardingProvider>(context, listen: false);
    final currentInfo = ExtractedBasicInfo(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      age: int.tryParse(_ageController.text.trim()),
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      bloodGroup: _selectedBloodGroup,
    );

    AiVoiceAssistantSheet.show(
      context: context,
      mode: AssistantMode.basicInfo,
      initialLanguageCode: onboarding.selectedLanguageCode,
      currentInfo: currentInfo,
      onBasicInfoUpdated: (info) {
        setState(() {
          if (info.name != null && info.name!.isNotEmpty) {
            _nameController.text = info.name!;
          }
          if (info.age != null) {
            _ageController.text = info.age.toString();
          }
          if (info.heightCm != null) {
            _heightController.text = info.heightCm!.toInt().toString();
          }
          if (info.weightKg != null) {
            _weightController.text = info.weightKg!.toInt().toString();
          }
          if (info.bloodGroup != null && _bloodGroups.contains(info.bloodGroup)) {
            _selectedBloodGroup = info.bloodGroup;
          }
          _assistantSpeech = "Thank you, ${info.name ?? 'Patient'}! Information updated.";
        });
        onboarding.updateBasicInfo(
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text.trim()),
          heightCm: double.tryParse(_heightController.text.trim()),
          weightKg: double.tryParse(_weightController.text.trim()),
          bloodGroup: _selectedBloodGroup,
        );
      },
      onComplete: () {
        if (mounted) {
          _saveAndContinue();
        }
      },
    );
  }

  void _saveAndContinue() {
    final onboarding = Provider.of<OnboardingProvider>(context, listen: false);

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    onboarding.updateBasicInfo(
      name: name.isNotEmpty ? name : null,
      age: age,
      heightCm: height,
      weightKg: weight,
      bloodGroup: _selectedBloodGroup,
    );

    Navigator.of(context).pushNamed(AppRoutes.genderSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: AiAssistantFab(
        onTap: () => _openAiAssistant(context),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Step 2 Indicator
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLightBlue,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              'Step 2 of 4 • Basic Information',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // AI Assistant Header Guidance
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

                        // Form Section Header
                        Text(
                          'Basic Information',
                          style: AppTypography.headingLarge.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Accurate vitals help our precision oncology AI calibrate clinical benchmarks.',
                          style: AppTypography.subtitle,
                        ),

                        const SizedBox(height: 20),

                        // Full Name
                        CustomTextField(
                          label: 'Full Name',
                          hintText: 'e.g. John Doe',
                          icon: Icons.person_outline_rounded,
                          controller: _nameController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Age
                        CustomTextField(
                          label: 'Age',
                          hintText: 'e.g. 35',
                          icon: Icons.cake_outlined,
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your age';
                            }
                            final n = int.tryParse(val.trim());
                            if (n == null || n <= 0 || n > 120) {
                              return 'Please enter a valid age';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Height & Weight Row
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Height (cm)',
                                hintText: '175',
                                icon: Icons.height_rounded,
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: CustomTextField(
                                label: 'Weight (kg)',
                                hintText: '70',
                                icon: Icons.monitor_weight_outlined,
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Blood Group Selection
                        Text(
                          'Blood Group',
                          style: AppTypography.label.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _bloodGroups.map((bg) {
                            final isSelected = _selectedBloodGroup == bg;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedBloodGroup = bg;
                                });
                              },
                              child: Container(
                                width: 70,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.surfaceLightBlue : AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryTeal : AppColors.borderSubtle,
                                    width: isSelected ? 1.8 : 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    bg,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: isSelected ? AppColors.primaryTeal : AppColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        // Continue Button
                        GradientButton(
                          text: 'Continue',
                          gradient: AppGradients.primaryButton,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _saveAndContinue();
                            }
                          },
                        ),

                        const SizedBox(height: 80),
                      ],
                    ),
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
