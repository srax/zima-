/// Data model representing a user in the system
class UserModel {
  final String id;
  final String username;
  final String? email;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.username,
    this.email,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode ^ email.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email)';
  }
}
