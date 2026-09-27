import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/notification_item_model.dart';
import '../../../data/models/reminder_model.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/screening_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glow_container.dart';
import '../../widgets/gradient_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0; // 0: All, 1: Unread, 2: Upcoming, 3: Reminders

  void _triggerTestNotification(BuildContext context) async {
    final onboarding = Provider.of<OnboardingProvider>(context, listen: false);
    final screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);

    final rawName = onboarding.profile.name;
    final firstName = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim().split(RegExp(r'\s+')).first
        : 'User';

    // Request permissions first
    await NotificationService().requestPermissions();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notification_add_rounded, color: AppColors.primaryMedicalTeal),
                ),
                const SizedBox(width: 12),
                Text(
                  'Test Real Notifications',
                  style: AppTypography.headingSmall.copyWith(fontSize: 16, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Test real device notifications while app is open, in background, or locked.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              tileColor: AppColors.surfaceCard,
              leading: const Icon(Icons.flash_on_rounded, color: AppColors.primaryMedicalTeal),
              title: const Text('Instant Test Notification', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Triggers right now on your device', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                await NotificationService().showNotification(
                  id: notifId,
                  title: 'Medicine Reminder 💊',
                  body: '$firstName, it is time for your prescribed medicine.',
                );
                screeningProvider.addNotification(
                  NotificationItemModel(
                    id: 'NOTIF-$notifId',
                    title: 'Medicine Reminder',
                    message: '$firstName, it is time for your prescribed medicine.',
                    time: 'Just now',
                    type: NotificationType.medicine,
                    isUpcoming: false,
                    isRead: false,
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.textPrimary,
                      content: Text('Instant test notification sent to device.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              tileColor: AppColors.surfaceCard,
              leading: const Icon(Icons.timer_outlined, color: AppColors.secondaryBlue),
              title: const Text('Schedule in 1 Minute (Test while closed/locked)', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Close app & lock device to test background delivery', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final scheduledTime = DateTime.now().add(const Duration(minutes: 1));
                final notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                await NotificationService().scheduleNotification(
                  id: notifId,
                  title: 'Health Reminder 🩺',
                  body: 'Good day, $firstName. Remember to check your health guidance.',
                  scheduledDate: scheduledTime,
                );
                screeningProvider.addNotification(
                  NotificationItemModel(
                    id: 'NOTIF-$notifId',
                    title: 'Health Reminder',
                    message: 'Good day, $firstName. Remember to check your health guidance.',
                    time: 'In 1 min',
                    type: NotificationType.healthReminder,
                    isUpcoming: true,
                    isRead: false,
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.textPrimary,
                      content: Text('Notification scheduled for 1 min. You may close app and lock screen now.'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              tileColor: AppColors.surfaceCard,
              leading: const Icon(Icons.alarm_on_rounded, color: AppColors.warningOrange),
              title: const Text('Schedule in 2 Minutes (Test while closed/locked)', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Close app & lock device to test background delivery', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final scheduledTime = DateTime.now().add(const Duration(minutes: 2));
                final notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                await NotificationService().scheduleNotification(
                  id: notifId,
                  title: 'Medicine Reminder 💊',
                  body: '$firstName, this is your 2-minute reminder check.',
                  scheduledDate: scheduledTime,
                );
                screeningProvider.addNotification(
                  NotificationItemModel(
                    id: 'NOTIF-$notifId',
                    title: 'Medicine Reminder',
                    message: '$firstName, this is your 2-minute reminder check.',
                    time: 'In 2 mins',
                    type: NotificationType.medicine,
                    isUpcoming: true,
                    isRead: false,
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.textPrimary,
                      content: Text('Notification scheduled for 2 mins. You may close app and lock screen now.'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showAddEditReminderModal(BuildContext context, {ReminderModel? existingReminder}) {
    final screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);

    final titleController = TextEditingController(text: existingReminder?.title ?? '');
    final messageController = TextEditingController(text: existingReminder?.message ?? '');
    ReminderType selectedType = existingReminder?.type ?? ReminderType.medicine;
    ReminderFrequency selectedFrequency = existingReminder?.frequency ?? ReminderFrequency.daily;
    TimeOfDay selectedTime = TimeOfDay(
      hour: existingReminder?.hour ?? 8,
      minute: existingReminder?.minute ?? 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) {
          final now = DateTime.now();
          final dt = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
          final formattedTime = DateFormat('hh:mm a').format(dt);

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 16,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existingReminder == null ? 'Create Smart Reminder' : 'Edit Reminder',
                        style: AppTypography.headingSmall.copyWith(fontSize: 16, color: AppColors.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Quick AI Wellness Suggestions
                  Text(
                    'AI-Suggested Wellness Reminders',
                    style: AppTypography.label.copyWith(fontSize: 11, color: AppColors.primaryMedicalTealDark),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildAiSuggestionChip(
                          label: '🥗 Fiber-rich Nutrition',
                          onTap: () {
                            setModalState(() {
                              selectedType = ReminderType.nutrition;
                              titleController.text = 'Fiber-rich Nutrition 🥗';
                              messageController.text =
                                  'Consider including more fiber-rich foods (oats, whole grains, beans, lentils, vegetables, fruits) with your meal.';
                              selectedTime = const TimeOfDay(hour: 12, minute: 30);
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildAiSuggestionChip(
                          label: '💧 Hydration',
                          onTap: () {
                            setModalState(() {
                              selectedType = ReminderType.water;
                              titleController.text = 'Hydration Reminder 💧';
                              messageController.text = 'Remember to drink water and stay hydrated.';
                              selectedTime = const TimeOfDay(hour: 15, minute: 30);
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildAiSuggestionChip(
                          label: '🍽️ Balanced Meal',
                          onTap: () {
                            setModalState(() {
                              selectedType = ReminderType.dinner;
                              titleController.text = 'Balanced Dinner 🍽️';
                              messageController.text = 'Consider having a balanced and wholesome meal.';
                              selectedTime = const TimeOfDay(hour: 19, minute: 30);
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reminder Type Selection
                  Text('Reminder Category', style: AppTypography.label.copyWith(fontSize: 12, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ReminderType>(
                        value: selectedType,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        items: ReminderType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              _getReminderTypeTitle(type),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedType = val);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Title Input
                  Text('Reminder Title', style: AppTypography.label.copyWith(fontSize: 12, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. Drink coconut water / Take my medicine',
                      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Message Input
                  Text('Notification Message', style: AppTypography.label.copyWith(fontSize: 12, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: messageController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. Time for your coconut water refresher',
                      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Time and Frequency Row
                  Row(
                    children: [
                      // Time Picker Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setModalState(() => selectedTime = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primaryMedicalTeal),
                                const SizedBox(width: 6),
                                Text(
                                  formattedTime,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Frequency Dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ReminderFrequency>(
                              value: selectedFrequency,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              items: ReminderFrequency.values.map((freq) {
                                return DropdownMenuItem(
                                  value: freq,
                                  child: Text(
                                    freq == ReminderFrequency.oneTime
                                        ? 'One-time'
                                        : (freq == ReminderFrequency.daily ? 'Daily' : 'Weekly'),
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedFrequency = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Save Action Button
                  GradientButton(
                    text: existingReminder == null ? 'Set Reminder' : 'Update Reminder',
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final message = messageController.text.trim();
                      if (title.isEmpty) return;

                      // Request permissions first
                      await NotificationService().requestPermissions();

                      final reminder = ReminderModel(
                        id: existingReminder?.id ?? 'REM-${DateTime.now().millisecondsSinceEpoch}',
                        title: title,
                        message: message.isNotEmpty ? message : title,
                        hour: selectedTime.hour,
                        minute: selectedTime.minute,
                        type: selectedType,
                        frequency: selectedFrequency,
                        isEnabled: true,
                        isAiSuggested: existingReminder?.isAiSuggested ?? false,
                      );

                      if (existingReminder == null) {
                        screeningProvider.addReminder(reminder);
                      } else {
                        screeningProvider.updateReminder(reminder);
                      }

                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.textPrimary,
                            content: Text(
                              'Reminder scheduled for ${reminder.formattedTime} (${reminder.frequencyLabel}). Works in background/locked state.',
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAiSuggestionChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.lightCyan,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryMedicalTeal.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryMedicalTealDark,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getReminderTypeTitle(ReminderType type) {
    switch (type) {
      case ReminderType.medicine:
        return 'Medicine';
      case ReminderType.breakfast:
        return 'Breakfast';
      case ReminderType.lunch:
        return 'Lunch';
      case ReminderType.dinner:
        return 'Dinner';
      case ReminderType.water:
        return 'Water Hydration';
      case ReminderType.nutrition:
        return 'Nutrition';
      case ReminderType.doctorAppointment:
        return 'Doctor Appointment';
      case ReminderType.custom:
        return 'Custom Reminder';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final allNotifications = screeningProvider.notifications;
    final allReminders = screeningProvider.reminders;

    List<NotificationItemModel> displayedNotifications;
    switch (_selectedTab) {
      case 1: // Unread
        displayedNotifications = allNotifications.where((n) => !n.isRead).toList();
        break;
      case 2: // Upcoming
        displayedNotifications = allNotifications.where((n) => n.isUpcoming).toList();
        break;
      case 0: // All
      default:
        displayedNotifications = allNotifications;
        break;
    }

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
                title: 'Notifications & Reminders',
                showBackButton: true,
                onBackPressed: () => Navigator.of(context).maybePop(),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_alarm_rounded, color: AppColors.primaryMedicalTeal, size: 22),
                    tooltip: 'Add Smart Reminder',
                    onPressed: () => _showAddEditReminderModal(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.science_outlined, color: AppColors.primaryMedicalTeal, size: 20),
                    tooltip: 'Test Device Notification',
                    onPressed: () => _triggerTestNotification(context),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    onSelected: (val) {
                      if (val == 'read_all') {
                        screeningProvider.markAllAsRead();
                      } else if (val == 'clear_all') {
                        screeningProvider.clearAllNotifications();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'read_all',
                        child: Row(
                          children: [
                            Icon(Icons.done_all_rounded, size: 18, color: AppColors.primaryMedicalTeal),
                            SizedBox(width: 8),
                            Text('Mark all as read', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            Icon(Icons.delete_sweep_rounded, size: 18, color: AppColors.alertRed),
                            SizedBox(width: 8),
                            Text('Clear all', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Segmented Tab Controls (All, Unread, Upcoming, Reminders)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTabButton(
                                label: 'All (${allNotifications.length})',
                                isSelected: _selectedTab == 0,
                                onTap: () => setState(() => _selectedTab = 0),
                              ),
                            ),
                            Expanded(
                              child: _buildTabButton(
                                label: 'Unread (${screeningProvider.unreadNotificationsCount})',
                                isSelected: _selectedTab == 1,
                                onTap: () => setState(() => _selectedTab = 1),
                              ),
                            ),
                            Expanded(
                              child: _buildTabButton(
                                label: 'Upcoming',
                                isSelected: _selectedTab == 2,
                                onTap: () => setState(() => _selectedTab = 2),
                              ),
                            ),
                            Expanded(
                              child: _buildTabButton(
                                label: 'Reminders (${allReminders.length})',
                                isSelected: _selectedTab == 3,
                                onTap: () => setState(() => _selectedTab = 3),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Conditional view: Notifications list or Reminders manager
                      if (_selectedTab == 3)
                        _buildRemindersSection(context, screeningProvider, allReminders)
                      else if (displayedNotifications.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: GlowContainer(
                            borderRadius: 18,
                            padding: const EdgeInsets.all(28),
                            backgroundColor: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.surfaceCard,
                                    border: Border.all(color: AppColors.borderSubtle),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_off_outlined,
                                    color: AppColors.textSecondary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Notifications',
                                  style: AppTypography.headingSmall.copyWith(fontSize: 16, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'You are all caught up with your reminders and screening updates.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayedNotifications.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = displayedNotifications[index];
                            return Dismissible(
                              key: Key(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.alertRed.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: AppColors.alertRed),
                              ),
                              onDismissed: (_) {
                                screeningProvider.deleteNotification(item.id);
                              },
                              child: _buildNotificationCard(context, item, screeningProvider),
                            );
                          },
                        ),

                      const SizedBox(height: 24),
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

  Widget _buildRemindersSection(
    BuildContext context,
    ScreeningProvider screeningProvider,
    List<ReminderModel> reminders,
  ) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reminders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return GlowContainer(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              backgroundColor: Colors.white,
              borderGradient: reminder.isEnabled ? AppGradients.subtleBorder : null,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: reminder.isEnabled ? AppColors.lightCyan : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: reminder.isEnabled
                            ? AppColors.primaryMedicalTeal.withValues(alpha: 0.5)
                            : AppColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      reminder.icon,
                      color: reminder.isEnabled ? AppColors.primaryMedicalTealDark : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                reminder.title,
                                style: AppTypography.headingSmall.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: reminder.isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            if (reminder.isAiSuggested)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.mintLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'AI Suggested',
                                  style: TextStyle(
                                    color: AppColors.successGreen,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reminder.message,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              reminder.formattedTime,
                              style: TextStyle(
                                color: reminder.isEnabled ? AppColors.primaryMedicalTealDark : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${reminder.frequencyLabel}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Switch.adaptive(
                        value: reminder.isEnabled,
                        activeTrackColor: AppColors.primaryMedicalTeal,
                        onChanged: (val) {
                          screeningProvider.toggleReminder(reminder.id);
                        },
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _showAddEditReminderModal(context, existingReminder: reminder),
                            child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => screeningProvider.deleteReminder(reminder.id),
                            child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.alertRed),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        GradientButton(
          text: '+ Add New Reminder',
          onPressed: () => _showAddEditReminderModal(context),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMedicalTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationItemModel item,
    ScreeningProvider screeningProvider,
  ) {
    IconData iconData;
    Color iconColor;
    Color iconBg;

    switch (item.type) {
      case NotificationType.medicine:
        iconData = Icons.medication_outlined;
        iconColor = AppColors.secondaryBlue;
        iconBg = AppColors.lightBlue;
        break;
      case NotificationType.screeningReminder:
        iconData = Icons.science_outlined;
        iconColor = AppColors.primaryMedicalTeal;
        iconBg = AppColors.lightCyan;
        break;
      case NotificationType.healthReminder:
        iconData = Icons.favorite_border_rounded;
        iconColor = AppColors.successGreen;
        iconBg = AppColors.mintLight;
        break;
      case NotificationType.foodGuidance:
        iconData = Icons.restaurant_menu_rounded;
        iconColor = AppColors.primaryMedicalTeal;
        iconBg = AppColors.lightCyan;
        break;
      case NotificationType.healthyMeal:
        iconData = Icons.lunch_dining_rounded;
        iconColor = AppColors.warningOrange;
        iconBg = AppColors.warningOrange.withValues(alpha: 0.12);
        break;
      case NotificationType.water:
        iconData = Icons.water_drop_outlined;
        iconColor = AppColors.secondaryBlue;
        iconBg = AppColors.lightBlue;
        break;
      case NotificationType.screeningCompleted:
        iconData = Icons.verified_user_outlined;
        iconColor = AppColors.successGreen;
        iconBg = AppColors.mintLight;
        break;
    }

    return GlowContainer(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      backgroundColor: Colors.white,
      borderGradient: item.isRead ? null : AppGradients.subtleBorder,
      onTap: () {
        screeningProvider.markAsRead(item.id);
        screeningProvider.setActiveVoiceNotification(item);
        Navigator.of(context).pushNamed(AppRoutes.voiceAssistant);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.headingSmall.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryMedicalTeal,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.message,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.time,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primaryMedicalTealDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              // Quick action buttons: mark read / delete
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      screeningProvider.markAsRead(item.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceCard,
                      ),
                      child: Icon(
                        item.isRead ? Icons.done_rounded : Icons.check_circle_outline_rounded,
                        color: item.isRead ? AppColors.successGreen : AppColors.primaryMedicalTeal,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      screeningProvider.deleteNotification(item.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceCard,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
