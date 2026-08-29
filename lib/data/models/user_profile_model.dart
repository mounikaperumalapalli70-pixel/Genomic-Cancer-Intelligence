enum Gender { male, female, other }

class UserProfileModel {
  final String? languageCode;
  final Gender? gender;
  final String? name;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final String? bloodGroup;

  const UserProfileModel({
    this.languageCode = 'en',
    this.gender,
    this.name,
    this.age,
    this.heightCm,
    this.weightKg,
    this.bloodGroup,
  });

  UserProfileModel copyWith({
    String? languageCode,
    Gender? gender,
    String? name,
    int? age,
    double? heightCm,
    double? weightKg,
    String? bloodGroup,
  }) {
    return UserProfileModel(
      languageCode: languageCode ?? this.languageCode,
      gender: gender ?? this.gender,
      name: name ?? this.name,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bloodGroup: bloodGroup ?? this.bloodGroup,
    );
  }
}
