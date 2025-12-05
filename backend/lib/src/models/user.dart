class User {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      passwordHash: json['passwordHash']?.toString() ?? '',
      createdAt: (json['createdAt'] is String &&
              json['createdAt'].toString().isNotEmpty)
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: (json['updatedAt'] is String &&
              json['updatedAt'].toString().isNotEmpty)
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
