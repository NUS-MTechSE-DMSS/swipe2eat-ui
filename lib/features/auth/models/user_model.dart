// User model for authentication
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? gender;
  final DateTime? dateOfBirth;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.gender,
    this.dateOfBirth,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'gender': gender,
    'dateOfBirth': dateOfBirth?.toIso8601String().split('T').first,
  };
}
