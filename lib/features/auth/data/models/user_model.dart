import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
      };

  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );
}
