import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/food_guidance_model.dart';
import '../../../data/models/notification_item_model.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/screening_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class FoodGuidanceScreen extends StatefulWidget {
  const FoodGuidanceScreen({super.key});

  @override
  State<FoodGuidanceScreen> createState() => _FoodGuidanceScreenState();
}

class _FoodGuidanceScreenState extends State<FoodGuidanceScreen> {
  final TextEditingController _medicineNameController = TextEditingController();

  @override
  void dispose() {
    _medicineNameController.dispose();
    super.dispose();
  }

  void _showAddMedicineDialog(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);
    final onboarding = Provider.of<OnboardingProvider>(context, listen: false);

    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final now = DateTime.now();
          final dt = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
          final formattedTime = DateFormat('hh:mm a').format(dt);

          return AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.borderSubtle),
            ),
            title: Text(
              'Add Doctor-Prescribed Medicine',
              style: AppTypography.headingSmall.copyWith(fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medicine is strictly user-controlled. Enter only medications prescribed by your healthcare provider.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _medicineNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g. Paracetamol / Vitamin D3',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (pickerCtx, child) {
                        return Theme(
                          data: Theme.of(pickerCtx).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.neonCyan,
                              onPrimary: Colors.black,
                              surface: AppColors.surfaceElevated,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 18, color: AppColors.neonCyan),
                        const SizedBox(width: 8),
                        Text('Reminder Time: ', style: AppTypography.bodySmall),
                        Text(
                          formattedTime,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neonCyan,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.edit_calendar_rounded, size: 16, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final medicineName = _medicineNameController.text.trim();
                  if (medicineName.isNotEmpty) {
                    final rawName = onboarding.profile.name;
                    final firstName = (rawName != null && rawName.trim().isNotEmpty)
                        ? rawName.trim().split(RegExp(r'\s+')).first
                        : 'User';

                    final now = DateTime.now();
                    final dt = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                    final formattedTime = DateFormat('hh:mm a').format(dt);

                    // 1. Add to provider
                    screeningProvider.addUserMedicine(
                      medicineName: medicineName,
                      time: formattedTime,
                    );

                    // 2. Schedule real device notification
                    final notifId = (medicineName.hashCode + selectedTime.hour * 60 + selectedTime.minute).abs() % 1000000;
                    await NotificationService().requestPermissions();
                    await NotificationService().scheduleRepeatingDailyNotification(
                      id: notifId,
                      title: 'Medicine Reminder 💊',
                      body: '$firstName, it is time for your prescribed $medicineName.',
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                    );

                    // 3. Add to notifications history
                    screeningProvider.addNotification(
                      NotificationItemModel(
                        id: 'MED-$notifId',
                        title: 'Medicine Reminder',
                        message: '$firstName, it is time for your prescribed $medicineName.',
                        time: formattedTime,
                        type: NotificationType.medicine,
                        isUpcoming: true,
                        isRead: false,
                      ),
                    );

                    _medicineNameController.clear();
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surfaceElevated,
                          content: Text('Scheduled daily reminder for $medicineName at $formattedTime.'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save Reminder'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final onboarding = Provider.of<OnboardingProvider>(context);
    final activeResult = screeningProvider.activeScreeningResult;
    final cancerType = activeResult.likelyCancerType ?? 'Lung Cancer';
    final guidance = FoodGuidanceModel.getGuidanceForCancerType(cancerType);

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
                title: 'AI Food Guidance',
                showBackButton: true,
                onBackPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Header Overview Card
                      GlowContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(18),
                        backgroundGradient: AppGradients.heroCard,
                        borderGradient: AppGradients.neonBorderCyan,
                        glowColor: AppColors.neonCyan,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.neonCyan.withValues(alpha: 0.15),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_rounded,
                                    color: AppColors.neonCyan,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    guidance.cancerType,
                                    style: AppTypography.headingSmall.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              guidance.overview,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section 1: Foods to Include
                      _buildGuidanceSection(
                        title: 'Foods to Include',
                        icon: Icons.check_circle_outline_rounded,
                        accentColor: AppColors.neonGreen,
                        iconBg: const Color(0xFF0F382B),
                        items: guidance.foodsToInclude,
                      ),

                      const SizedBox(height: 18),

                      // Section 2: Foods to Limit
                      _buildGuidanceSection(
                        title: 'Foods to Limit',
                        icon: Icons.highlight_off_rounded,
                        accentColor: AppColors.neonRed,
                        iconBg: const Color(0xFF3B1520),
                        items: guidance.foodsToLimit,
                      ),

                      const SizedBox(height: 18),

                      // Section 3: Hydration
                      GlowContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.surfaceCard,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D2D44),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.water_drop_outlined,
                                    color: AppColors.statusInfo,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Hydration Guidance',
                                  style: AppTypography.headingSmall.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              guidance.hydrationAdvice,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Section 4: Meal Schedule & Patterns
                      _buildGuidanceSection(
                        title: 'Meal Timing & Schedule',
                        icon: Icons.schedule_rounded,
                        accentColor: AppColors.neonPurple,
                        iconBg: const Color(0xFF221344),
                        items: guidance.mealGuidance,
                      ),

                      const SizedBox(height: 20),

                      // Strict Medical Disclaimer Box
                      GlowContainer(
                        borderRadius: 14,
                        padding: const EdgeInsets.all(14),
                        backgroundColor: const Color(0xFF131B33),
                        borderGradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.verified_outlined,
                              color: AppColors.neonCyan,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                guidance.disclaimer,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // USER-CONTROLLED MEDICINE REMINDER SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Doctor-Prescribed Medicine',
                                style: AppTypography.headingSmall.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'User-controlled reminders (AI does not prescribe)',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.neonCyan,
                            ),
                            onPressed: () => _showAddMedicineDialog(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Medicine list
                      if (screeningProvider.userMedicines.isEmpty)
                        Text(
                          'No doctor-prescribed medicines added yet. Tap + to set a reminder.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: screeningProvider.userMedicines.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final med = screeningProvider.userMedicines[index];
                            final notifId = (med.medicineName.hashCode + med.time.hashCode).abs() % 1000000;

                            return GlowContainer(
                              borderRadius: 12,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              backgroundColor: AppColors.surfaceCard,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.medication_outlined,
                                    color: AppColors.neonPink,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          med.medicineName,
                                          style: AppTypography.bodyMedium.copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Scheduled: ${med.time}',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.neonCyan,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: med.reminderEnabled,
                                    activeThumbColor: AppColors.neonCyan,
                                    activeTrackColor: AppColors.neonBlue.withValues(alpha: 0.5),
                                    onChanged: (val) async {
                                      screeningProvider.toggleMedicineReminder(med.id);
                                      if (!val) {
                                        await NotificationService().cancelNotification(notifId);
                                      } else {
                                        final rawName = onboarding.profile.name;
                                        final firstName = (rawName != null && rawName.trim().isNotEmpty)
                                            ? rawName.trim().split(RegExp(r'\s+')).first
                                            : 'User';
                                        await NotificationService().showNotification(
                                          id: notifId,
                                          title: 'Medicine Reminder 💊',
                                          body: '$firstName, it is time for your prescribed ${med.medicineName}.',
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 18),
                                    onPressed: () async {
                                      await NotificationService().cancelNotification(notifId);
                                      screeningProvider.removeUserMedicine(med.id);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),

              // Bottom Action: Voice Care Assistant Launcher
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: GradientButton(
                  text: 'Open Voice Care Assistant',
                  icon: Icons.record_voice_over_rounded,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.voiceAssistant);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidanceSection({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Color iconBg,
    required List<String> items,
  }) {
    return GlowContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surfaceCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTypography.headingSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


