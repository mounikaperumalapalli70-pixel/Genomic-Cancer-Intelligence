import 'package:flutter/material.dart';

enum ReminderType {
  medicine,
  breakfast,
  lunch,
  dinner,
  water,
  nutrition,
  doctorAppointment,
  custom,
}

enum ReminderFrequency {
  oneTime,
  daily,
  weekly,
}

class ReminderModel {
  final String id;
  final String title;
  final String message;
  final int hour;
  final int minute;
  final ReminderType type;
  final ReminderFrequency frequency;
  final bool isEnabled;
  final bool isAiSuggested;
  final DateTime? scheduledDate; // for oneTime reminders

  const ReminderModel({
    required this.id,
    required this.title,
    required this.message,
    required this.hour,
    required this.minute,
    required this.type,
    this.frequency = ReminderFrequency.daily,
    this.isEnabled = true,
    this.isAiSuggested = false,
    this.scheduledDate,
  });

  String get formattedTime {
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  String get frequencyLabel {
    switch (frequency) {
      case ReminderFrequency.oneTime:
        return 'One-time';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
    }
  }

  String get typeLabel {
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
        return 'Nutrition & Wellness';
      case ReminderType.doctorAppointment:
        return 'Doctor Appointment';
      case ReminderType.custom:
        return 'Custom Reminder';
    }
  }

  IconData get icon {
    switch (type) {
      case ReminderType.medicine:
        return Icons.medication_outlined;
      case ReminderType.breakfast:
        return Icons.free_breakfast_outlined;
      case ReminderType.lunch:
        return Icons.lunch_dining_outlined;
      case ReminderType.dinner:
        return Icons.dinner_dining_outlined;
      case ReminderType.water:
        return Icons.water_drop_outlined;
      case ReminderType.nutrition:
        return Icons.eco_outlined;
      case ReminderType.doctorAppointment:
        return Icons.calendar_today_outlined;
      case ReminderType.custom:
        return Icons.notifications_active_outlined;
    }
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    String? message,
    int? hour,
    int? minute,
    ReminderType? type,
    ReminderFrequency? frequency,
    bool? isEnabled,
    bool? isAiSuggested,
    DateTime? scheduledDate,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      isEnabled: isEnabled ?? this.isEnabled,
      isAiSuggested: isAiSuggested ?? this.isAiSuggested,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }
}
