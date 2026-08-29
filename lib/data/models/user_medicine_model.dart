class UserMedicineModel {
  final String id;
  final String medicineName;
  final String time;
  final bool reminderEnabled;

  const UserMedicineModel({
    required this.id,
    required this.medicineName,
    required this.time,
    this.reminderEnabled = true,
  });

  UserMedicineModel copyWith({
    String? id,
    String? medicineName,
    String? time,
    bool? reminderEnabled,
  }) {
    return UserMedicineModel(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      time: time ?? this.time,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }
}
