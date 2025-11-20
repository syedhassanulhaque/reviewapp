// lib/models/user.dart
enum UserType { brand, influencer }

class User {
  final String id;
  final String email;
  final String displayName;
  final UserType type;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.type,
    required this.createdAt,
  });

  bool get isBrand => type == UserType.brand;
  bool get isInfluencer => type == UserType.influencer;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      type: UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.${json['type']}',
        orElse: () => UserType.influencer,
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}