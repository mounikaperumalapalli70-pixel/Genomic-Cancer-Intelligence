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
import '../../widgets/gradient_button.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedBloodGroup;

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
        });
        onboarding.updateBasicInfo(
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text.trim()),
          heightCm: double.tryParse(_heightController.text.trim()),
          weightKg: double.tryParse(_weightController.text.trim()),
          bloodGroup: _selectedBloodGroup,
        );
      },
    );
  }

  void _saveAndProceed() {
    final onboarding = Provider.of<OnboardingProvider>(context, listen: false);
    onboarding.updateBasicInfo(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      bloodGroup: _selectedBloodGroup,
    );

    Navigator.of(context).pushNamed(AppRoutes.howItWorks);
  }

  @override
  Widget build(BuildContext context) {
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
                actions: [
                  // Top Right AI Assistant Pill Button
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _openAiAssistant(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.neonCyan.withValues(alpha: 0.6),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonBlue.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const RobotAvatar(size: 18, isGlowing: true),
                            const SizedBox(width: 6),
                            Text(
                              'AI Assistant',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Title & Subtitle
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Basic Information',
                              textAlign: TextAlign.center,
                              style: AppTypography.headingLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Please provide some basic details',
                              textAlign: TextAlign.center,
                              style: AppTypography.subtitle,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Name Field
                      CustomTextField(
                        label: 'Name',
                        hintText: 'Enter your name',
                        icon: Icons.person_outline_rounded,
                        controller: _nameController,
                      ),

                      const SizedBox(height: 18),

                      // Age Field
                      CustomTextField(
                        label: 'Age',
                        hintText: 'Enter your age',
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        controller: _ageController,
                      ),

                      const SizedBox(height: 18),

                      // Height Field
                      CustomTextField(
                        label: 'Height (cm)',
                        hintText: 'Enter your height',
                        icon: Icons.height_rounded,
                        keyboardType: TextInputType.number,
                        controller: _heightController,
                      ),

                      const SizedBox(height: 18),

                      // Weight Field
                      CustomTextField(
                        label: 'Weight (kg)',
                        hintText: 'Enter your weight',
                        icon: Icons.monitor_weight_outlined,
                        keyboardType: TextInputType.number,
                        controller: _weightController,
                      ),

                      const SizedBox(height: 18),

                      // Blood Group Field
                      _buildBloodGroupDropdown(),

                      const SizedBox(height: 24),

                      // Floating AI Assistant Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: AiAssistantFab(
                          onTap: () => _openAiAssistant(context),
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
                  onPressed: _saveAndProceed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.bloodtype_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Blood Group',
              style: AppTypography.label,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.8),
              width: 1.0,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBloodGroup,
              isExpanded: true,
              dropdownColor: AppColors.surfaceElevated,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              hint: Text(
                'Select blood group',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              items: _bloodGroups.map((group) {
                return DropdownMenuItem<String>(
                  value: group,
                  child: Text(
                    group,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedBloodGroup = val;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}


